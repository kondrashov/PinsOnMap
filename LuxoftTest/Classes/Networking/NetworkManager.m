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

@implementation NetworkManager

#pragma mark - Public methods

+ (void)loadPartnersWithCompletion:(void(^)(BOOL isSuccess, NSError * error))completion
{
    NSString *stringURL = [NSString stringWithFormat:@"%@%@", baseURL, partnersURL];
    [DataRequest loadDataWithStringURL:stringURL progress:NULL completion:^(NSData *data, BOOL fromCache, NSError *error)
    {
        if(data && data.length > 0)
        {
            [self parseData:data completion:^(NSArray *payloadArray)
            {
                if(payloadArray)
                    [StorageManager savePartners:payloadArray completion:completion];
                else
                    completion(NO, nil);
            }];
        }
        else
        {
            completion(NO, error);
        }
    } cacheEnabled:NO];
}

+ (void)loadPointsAroundLongitude:(NSNumber *)longitude
                         latitude:(NSNumber *)latitude
                           radius:(NSNumber *)radius
                       completion:(void(^)(BOOL isSuccess, NSError * error))completion

{
    NSString *stringURL = [NSString stringWithFormat:@"%@%@?latitude=%@&longitude=%@&radius=%@", baseURL, pointsURL, latitude, longitude, radius];
    [DataRequest loadDataWithStringURL:stringURL progress:NULL completion:^(NSData *data, BOOL fromCache, NSError *error)
     {
         if(data && data.length > 0)
         {
             [self parseData:data completion:^(NSArray *payloadArray)
             {
                 if(payloadArray)
                      [StorageManager savePoints:payloadArray completion:completion];
                 else
                     completion(NO, nil);
             }];
         }
         else
         {
             completion(NO, error);
         }
     } cacheEnabled:NO];
}

#pragma mark - Private methods

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
