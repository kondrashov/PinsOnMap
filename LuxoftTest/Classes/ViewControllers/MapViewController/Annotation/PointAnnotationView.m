//
//  PointAnnotationView.m
//  LuxoftTest
//
//  Created by Artem on 19.04.15.
//  Copyright (c) 2015 ArtemK. All rights reserved.
//

#import "PointAnnotationView.h"
#import "NetworkManager.h"
#import "PointAnnotation.h"
#import "WebImageView.h"
#import "CPoint.h"
#import "CPartner.h"

#define ANNOTATION_SIZE     25

@interface PointAnnotationView ()
{
    WebImageView    *_webImageView;
}

@end

@implementation PointAnnotationView

#pragma mark - Lifecycle

- (instancetype)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    if([annotation isKindOfClass:[PointAnnotation class]])
    {
        self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
        if(self)
        {
            [self setupProperties];
            [self updateUI];

        }
        return self;
    }
    else
        return nil;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [_webImageView cancelRequest];
    _webImageView.image = nil;
}

#pragma mark - Private methods

+ (CGSize)defaultSize
{
    return CGSizeMake(ANNOTATION_SIZE, ANNOTATION_SIZE);
}

- (void)setupProperties
{
    self.canShowCallout = NO;
    CGSize size = [[self class] defaultSize];
    self.frame = CGRectMake(0, 0, size.width, size.height);
    self.backgroundColor = [UIColor clearColor];

    if(!_webImageView)
    {
        _webImageView = [[WebImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_webImageView];
    }
}

#pragma mark - Public methods

- (void)updateUI
{
    if(_webImageView)
    {
        PointAnnotation *annotation = self.annotation;
        NSString *imageStringURL = [NSString stringWithFormat:@"%@%@", kImageBaseURL, annotation.point.partner.picture];
        [_webImageView loadImageWithStringURL:imageStringURL completion:NULL];
    }
}

@end
