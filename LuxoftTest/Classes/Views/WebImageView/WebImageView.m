//
//  WebImageView.m
//  LuxoftTest
//
//  Created by Artem on 19.04.15.
//  Copyright (c) 2015 ArtemK. All rights reserved.
//

#import "WebImageView.h"
#import "DataRequest.h"
#import "UIImage+Additions.h"

@interface WebImageView ()

@property (strong, nonatomic) DataRequest *dataRequest;
@property (strong, nonatomic) NSString *imageStringURL;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation WebImageView

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self setupView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.activityIndicator.center = CGPointMake(self.bounds.size.width / 2.f, self.bounds.size.height / 2.f);
}

- (void)dealloc
{
    [self cancelRequest];
}

#pragma mark - Private methods

- (void)setupView
{
    self.clipsToBounds = YES;
    self.contentMode = UIViewContentModeScaleAspectFit;
    
}

- (UIActivityIndicatorView *)activityIndicator
{
    if(!_activityIndicator)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_activityIndicator setHidesWhenStopped:YES];
        [self addSubview:_activityIndicator];
    }
    
    return _activityIndicator;
}

#pragma mark - Public methods

- (void)cancelRequest
{
    [self.dataRequest cancelRequest];
}

- (void)loadImageWithStringURL:(NSString *)stringURL completion:(void(^)(BOOL isSuccess))completion
{
    __weak typeof(self) weakSelf = self;
    
    void(^loadFailBlock)(void) = ^void(void)
    {
        [weakSelf.activityIndicator stopAnimating];
        weakSelf.image = [UIImage imageNamed:@"placeholder"];
        if(completion != NULL)
            completion(NO);
    };
    
    if(stringURL.length)
    {
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
        
        self.dataRequest = [DataRequest loadDataWithStringURL:stringURL progress:NULL completion:^(NSData *data, BOOL fromCache, NSError *error)
                            {
                                if(!error && data.length > 0)
                                {
                                    dispatch_queue_t dataQueee = dispatch_queue_create("com.dataQueee", DISPATCH_QUEUE_CONCURRENT);
                                    dispatch_async(dataQueee, ^{
                                        
                                        UIImage *image = [[UIImage imageWithData:data] imageWithLimitedSize];
                                        
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [weakSelf.activityIndicator stopAnimating];
                                            weakSelf.image = image;
                                            if(completion != NULL)
                                                completion(YES);
                                        });
                                    });
                                }
                                else
                                    loadFailBlock();
                                
                            } cacheEnabled:YES];
    }
    else
        loadFailBlock();
}
@end