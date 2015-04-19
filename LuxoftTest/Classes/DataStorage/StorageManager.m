//
//  StorageManager.m
//  LuxoftTest
//
//  Created by Artem on 18.04.15.
//  Copyright (c) 2015 ArtemK. All rights reserved.
//

#import "StorageManager.h"
#import "CoreDataManager.h"
#import "CPartner+Extensions.h"
#import "CPoint+Extensions.h"
#import "NSManagedObject+Extensions.h"

NSString * const kPartnerId     = @"id";
NSString * const kName          = @"name";
NSString * const kPicture       = @"picture";
NSString * const kPartnerName   = @"partnerName";
NSString * const kLocation      = @"location";
NSString * const kLatitude      = @"latitude";
NSString * const kLongitude     = @"longitude";

@implementation StorageManager

#pragma mark - Public methods

+ (void)savePartners:(NSArray *)partners completion:(void(^)(BOOL isSuccess, NSError * error))completion
{
    if([partners isKindOfClass:[NSArray class]])
    {
        NSManagedObjectContext *mainContext = [[CoreDataManager sharedInstance] mainContext];
        NSManagedObjectContext *privateContext = [[CoreDataManager sharedInstance] privateContext];
        
        [privateContext performBlock:^{
          
            for(NSDictionary *dict in partners)
            {
                NSString *partnerId = dict[kPartnerId];
                CPartner *partner = [CPartner addPartnerWithId:partnerId context:privateContext];
                partner.name = dict[kName];
                partner.picture = dict[kPicture];
            }
            [self savePrivateContext:privateContext mainContext:mainContext completion:completion];
        }];
    }
}

+ (void)savePoints:(NSArray *)points completion:(void (^)(BOOL, NSError *))completion
{
    if([points isKindOfClass:[NSArray class]])
    {
        NSManagedObjectContext *mainContext = [[CoreDataManager sharedInstance] mainContext];
        NSManagedObjectContext *privateContext = [[CoreDataManager sharedInstance] privateContext];
        
        [privateContext performBlock:^{
           
            for(NSDictionary *dict in points)
            {
                NSString *partnerName = dict[kPartnerName];
                double latitude = [dict[kLocation][kLatitude] doubleValue];
                double longitude = [dict[kLocation][kLongitude] doubleValue];
                
                [CPoint addPointWithPartnerId:partnerName longitude:longitude latitude:latitude context:privateContext];
            }
            [self savePrivateContext:privateContext mainContext:mainContext completion:completion];            
        }];
    }
}

+ (void)fetchAllPointsWithCompletion:(void (^)(NSArray *objects, NSError *error))completion
{
    return [CPoint asyncFetchAllObjects:completion];
}

#pragma mark - Private methods

+ (void)savePrivateContext:(NSManagedObjectContext *)privateContext mainContext:(NSManagedObjectContext *)mainContext completion:(void (^)(BOOL, NSError *))completion
{
    NSError *error;
    [privateContext save:&error];
    
    if(!error)
    {
        [mainContext performBlock:^{
            NSError *error;
            [mainContext save:&error];
            
            if(!error)
                completion(YES, nil);
            else
                completion(NO, error);
        }];
    }
    else
        completion(NO, error);
}

@end
