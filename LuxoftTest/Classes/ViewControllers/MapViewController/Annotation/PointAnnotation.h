//
//  PointAnnotation.h
//  LuxoftTest
//
//  Created by Artem on 19.04.15.
//  Copyright (c) 2015 ArtemK. All rights reserved.
//

#import <MapKit/MapKit.h>

@class CPoint;

@interface PointAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign)   CLLocationCoordinate2D coordinate;
@property (nonatomic, copy)     NSString *title;
@property (nonatomic, copy)     NSString *subtitle;
@property (nonatomic, strong)   CPoint *point;

@end
