//
//  PointAnnotation.m
//  LuxoftTest
//
//  Created by Artem on 19.04.15.
//  Copyright (c) 2015 ArtemK. All rights reserved.
//

#import "PointAnnotation.h"

@implementation PointAnnotation

@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize point = _point;

- (id)init
{
    self = [super init];
    if (self)
    {
        _title = @"";
        _subtitle = @"";
        _point = nil;
        _coordinate = CLLocationCoordinate2DMake(0., 0.);
    }
    return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    if (newCoordinate.latitude != _coordinate.latitude || newCoordinate.longitude != _coordinate.longitude)
    {
        _coordinate = newCoordinate;
    }
}


@end
