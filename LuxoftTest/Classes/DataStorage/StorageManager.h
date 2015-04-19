//
//  StorageManager.h
//  LuxoftTest
//
//  Created by Artem on 18.04.15.
//  Copyright (c) 2015 ArtemK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StorageManager : NSObject

+ (void)savePartners:(NSArray *)partners
          completion:(void(^)(BOOL isSuccess, NSError * error))completion;

+ (void)savePoints:(NSArray *)points
        completion:(void(^)(BOOL isSuccess, NSError * error))completion;

+ (void)fetchAllPointsWithCompletion:(void (^)(NSArray *objects, NSError *error))completion;

@end
