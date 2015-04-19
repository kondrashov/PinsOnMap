//
//  DataRequest.h
//  LuxoftTest
//
//  Created by Artem on 18.04.15.
//  Copyright (c) 2015 ArtemK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DataRequest;

typedef void (^ProgressBlock)(CGFloat progress);
typedef void (^CompletionBlock)(NSData *data, BOOL fromCache, DataRequest *request, NSError *error);

@interface DataRequest : NSObject

+ (instancetype)request;

+ (DataRequest *)loadDataWithStringURL:(NSString *)stringURL
                              progress:(ProgressBlock)progress
                            completion:(CompletionBlock)completion
                          cacheEnabled:(BOOL)cacheEnabled
                             requestId:(NSString *)requestId;

- (void)loadDataWithStringURL:(NSString *)stringURL
                     progress:(ProgressBlock)progress
                   completion:(CompletionBlock)completion
                 cacheEnabled:(BOOL)cacheEnabled
                    requestId:(NSString *)requestId;

- (void)cancelRequest;
- (NSString *)requestIdentifier;

@end
