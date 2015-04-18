//
//  NetworkManager.h
//  LuxoftTest
//
//  Created by Artem on 18.04.15.
//  Copyright (c) 2015 ArtemK. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NetworkManager : NSObject

+ (void)loadPartnersWithCompletion:(void(^)(BOOL isSuccess, NSError * error))completion;

+ (void)loadPointsAroundLongitude:(NSNumber *)longitude
                         latitude:(NSNumber *)latitude
                           radius:(NSNumber *)radius
                       completion:(void(^)(BOOL isSuccess, NSError * error))completion;

@end
