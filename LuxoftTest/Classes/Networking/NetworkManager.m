//
//  NetworkManager.m
//  LuxoftTest
//
//  Created by Artem on 18.04.15.
//  Copyright (c) 2015 ArtemK. All rights reserved.
//

#import "NetworkManager.h"
#import "StorageManager.h"
#import "DataRequest.h"

NSString * const baseURL = @"https://www-qa.tcsbank.ru/api/v1";
NSString * const partnersURL = @"/deposition_partners?accountType=Credit";
NSString * const pointsURL = @"/deposition_points";

NSString * const kPayload = @"payload";

@interface NetworkManager()
{
    NSMutableArray  *_requestsArray;
}
@end

@implementation NetworkManager

#pragma mark - Lifecycle

+ (instancetype)sharedInstance
{
    static NetworkManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NetworkManager new];
    });
    return instance;
}

#pragma mark - Public methods

+ (void)loadPartnersWithCompletion:(void(^)(BOOL isSuccess, NSError * error))completion
{
    NSString *stringURL = [NSString stringWithFormat:@"%@%@", baseURL, partnersURL];
    NetworkManager *networkManager = [self sharedInstance];
    DataRequest *dataRequest = [DataRequest loadDataWithStringURL:stringURL progress:NULL completion:^(NSData *data, BOOL fromCache, DataRequest *request, NSError *error)
    {
        if(data && data.length > 0)
        {
            [self parseData:data completion:^(NSArray *payloadArray)
            {
                if(payloadArray)
                {
                    [StorageManager savePartners:payloadArray completion:^(BOOL isSuccess, NSError *error)
                     {
                        [[networkManager requestsArray] removeObject:request];
                         completion(isSuccess, error);
                     }];
                }
                else
                {
                    [[networkManager requestsArray] removeObject:request];
                    completion(NO, nil);
                }
            }];
        }
        else
        {
            [[networkManager requestsArray] removeObject:request];
            completion(NO, error);
        }
    } cacheEnabled:NO requestId:kPartnersRequest];
    [[networkManager requestsArray] addObject:dataRequest];
}

+ (void)loadPointsAroundLongitude:(NSNumber *)longitude
                         latitude:(NSNumber *)latitude
                           radius:(NSNumber *)radius
                       completion:(void(^)(BOOL isSuccess, NSError * error))completion

{
    NSString *stringURL = [NSString stringWithFormat:@"%@%@?latitude=%@&longitude=%@&radius=%@", baseURL, pointsURL, latitude, longitude, radius];
    NetworkManager *networkManager = [self sharedInstance];
    DataRequest *dataRequest = [DataRequest loadDataWithStringURL:stringURL progress:NULL completion:^(NSData *data, BOOL fromCache, DataRequest *request, NSError *error)
     {
         if(data && data.length > 0)
         {
             [self parseData:data completion:^(NSArray *payloadArray)
             {
                 if(payloadArray && payloadArray.count > 0)
                 {
                      [StorageManager savePoints:payloadArray completion:^(BOOL isSuccess, NSError *error)
                      {
                          [[networkManager requestsArray] removeObject:request];
                          completion(isSuccess, error);
                      }];
                 }
                 else
                 {
                     [[networkManager requestsArray] removeObject:request];
                     completion(NO, nil);
                 }
             }];
         }
         else
         {
             [[networkManager requestsArray] removeObject:request];
             completion(NO, error);
         }
     } cacheEnabled:NO requestId:kPointsRequest];
    [[networkManager requestsArray] addObject:dataRequest];
}

+ (void)cancelRequestsWithId:(NSString *)requestsId
{
    NSMutableArray *requestsArray = [[self sharedInstance] requestsArray];
    for(DataRequest *request in [requestsArray copy])
    {
        if([request.requestIdentifier isEqualToString:requestsId])
        {
            [request cancelRequest];
            [requestsArray removeObject:request];
        }
    }
}

#pragma mark - Private methods

- (NSMutableArray *)requestsArray
{
    if(!_requestsArray)
        _requestsArray = [NSMutableArray array];

    return _requestsArray;
}

+ (void)parseData:(NSData *)data completion:(void(^)(NSArray *payloadArray))completion
{
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
        
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:nil];
        if([jsonDict isKindOfClass:[NSDictionary class]])
        {
            NSArray *payloadArray = jsonDict[kPayload];
            completion(payloadArray);
        }
        else
            completion(nil);
    });
}

@end
