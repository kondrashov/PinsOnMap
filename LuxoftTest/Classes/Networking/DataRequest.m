//
//  DataRequest.m
//  LuxoftTest
//
//  Created by Artem on 18.04.15.
//  Copyright (c) 2015 ArtemK. All rights reserved.
//

#import "DataRequest.h"

#define TIMEOUT_INTERVAL    60

@interface DataRequest () <NSURLConnectionDataDelegate>
{
    BOOL                _cacheEnabled;
    CGFloat             _expectedSize;
    
    NSMutableData       *_data;
    NSURLConnection     *_connection;
    NSString            *_requestIdentifier;
    dispatch_queue_t    _dataRequestQueee;
}

@property (copy, nonatomic) ProgressBlock   progressBlock;
@property (copy, nonatomic) CompletionBlock completionBlock;

@end

@implementation DataRequest

#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    if(self)
    {
        _dataRequestQueee = dispatch_queue_create("com.dataRequestQueee", DISPATCH_QUEUE_CONCURRENT);
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:50 * 1024 * 1024
                                                                 diskCapacity:50 * 1024 * 1024
                                                                     diskPath:nil];
            [NSURLCache setSharedURLCache:URLCache];
        });
    }
    return self;
}

#pragma mark - Public methods

- (NSString *)requestIdentifier
{
    return _requestIdentifier;
}

+ (instancetype)request
{
    return [self new];
}

+ (DataRequest *)loadDataWithStringURL:(NSString *)stringURL
                              progress:(ProgressBlock)progress
                            completion:(CompletionBlock)completion
                          cacheEnabled:(BOOL)cacheEnabled
                             requestId:(NSString *)requestId
{
    DataRequest *dataRequest = [DataRequest request];
    [dataRequest loadDataWithStringURL:stringURL progress:progress completion:completion cacheEnabled:cacheEnabled requestId:requestId];
    return dataRequest;
}

- (void)loadDataWithStringURL:(NSString *)stringURL
                     progress:(ProgressBlock)progress
                   completion:(CompletionBlock)completion
                 cacheEnabled:(BOOL)cacheEnabled
                    requestId:(NSString *)requestId
{
    NSURL *requestURL = [NSURL URLWithString:stringURL];
    [self loadDataWithURL:requestURL progress:progress completion:completion cacheEnabled:cacheEnabled requestId:requestId];
}

- (void)cancelRequest
{
    [_connection cancel];
}

#pragma mark - Private methods

- (void)loadDataWithURL:(NSURL *)dataURL
               progress:(ProgressBlock)progress
             completion:(CompletionBlock)completion
           cacheEnabled:(BOOL)cacheEnabled
              requestId:(NSString *)requestId
{
    self.progressBlock = progress;
    self.completionBlock = completion;
    _cacheEnabled = cacheEnabled;
    _requestIdentifier = requestId;
    
    if(_connection)
        [_connection cancel];
    
    NSURLRequestCachePolicy cachePolicy = _cacheEnabled ? NSURLRequestReloadRevalidatingCacheData : NSURLRequestReloadIgnoringCacheData;
    NSURLRequest *request = [NSURLRequest requestWithURL:dataURL cachePolicy:cachePolicy timeoutInterval:TIMEOUT_INTERVAL];
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    if(_cacheEnabled)
    {
        dispatch_async(_dataRequestQueee, ^{
            NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(cachedResponse != nil && cachedResponse.data.length > 0)
                {
                    if(self.progressBlock != NULL)
                        self.progressBlock(100);
                    
                    if(self.completionBlock != NULL)
                        self.completionBlock(cachedResponse.data, YES, self, nil);
                }
                else
                {
                    [_connection start];
                }
            });
        });
    }
    else
    {
        dispatch_async(_dataRequestQueee, ^{
            [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];

            dispatch_async(dispatch_get_main_queue(), ^{
                [_connection start];
            });
        });
    }
}

#pragma mark - NSURlConnection delegate

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    NSCachedURLResponse *cachedURLResponse = _cacheEnabled ? cachedResponse : nil;
    return cachedURLResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if(response)
    {
        _data = [NSMutableData data];
        _expectedSize = [response expectedContentLength];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(data)
    {
        [_data appendData:data];
        
        if(self.progressBlock != NULL)
        {
            CGFloat percentOfLoadingData = _expectedSize > 0 ? (_data.length / _expectedSize) * 100 : 0;
            self.progressBlock(percentOfLoadingData);
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _connection = nil;
    if(self.completionBlock != NULL)
        self.completionBlock(_data, NO, self, nil);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _connection = nil;
    if(self.completionBlock != NULL)
        self.completionBlock(nil, NO, self, error);
}

@end