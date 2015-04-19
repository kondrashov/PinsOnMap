//
//  ViewController.m
//  LuxoftTest
//
//  Created by Artem on 18.04.15.
//  Copyright (c) 2015 ArtemK. All rights reserved.
//

#import "MapViewController.h"
#import "NetworkManager.h"
#import "StorageManager.h"
#import "PointAnnotation.h"
#import "PointAnnotationView.h"
#import "CPoint+Extensions.h"
#import <MapKit/MapKit.h>

@interface MapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showActivity];
    [NetworkManager loadPartnersWithCompletion:^(BOOL isSuccess, NSError *error)
    {
        [NetworkManager loadPointsAroundLongitude:@(37.618423) latitude:@(55.751244) radius:@(1000) completion:^(BOOL isSuccess, NSError *error)
        {
            [StorageManager fetchAllPointsWithCompletion:^(NSArray *objects, NSError *error)
            {
                for(CPoint *point in objects)
                {
                    PointAnnotation *pointAnnotation = [PointAnnotation new];
                    pointAnnotation.coordinate = CLLocationCoordinate2DMake([point.latitude doubleValue], [point.longitude doubleValue]);
                    pointAnnotation.point = point;
                    [self.mapView addAnnotation:pointAnnotation];
                }
                [self hideActivity];
            }];
        }];
    }];
}

#pragma mark - Methods

- (void)showActivity
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible])
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    });
}

- (void)hideActivity
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if([[UIApplication sharedApplication] isNetworkActivityIndicatorVisible])
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    });
}

#pragma mark - MKMapView delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[PointAnnotation class]])
    {
        NSString *reuseId = NSStringFromClass([PointAnnotationView class]);
        PointAnnotationView* pointAnnotationView = (PointAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
        
        if (pointAnnotationView)
        {
            pointAnnotationView.annotation = annotation;
            [pointAnnotationView updateUI];
        }
        else
        {
            pointAnnotationView = [[PointAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
            
        }
        return pointAnnotationView;
    }
    else
        return nil;
}

@end
