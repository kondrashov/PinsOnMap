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
#import <CoreLocation/CoreLocation.h>

#define     ZOOM_IN_SCALE       0.5
#define     ZOOM_OUT_SCALE      2.0

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
{
    BOOL _isPartnersLoaded;
    BOOL _isLocationDetected;
    BOOL _isLoading;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation MapViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self fetchPointsWithCompletion:NULL];
    [self.locationManager startUpdatingLocation];
    [self loadPartners];
}

#pragma mark - Methods

- (CLLocationManager *)locationManager
{
    if (_locationManager == nil)
    {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        _locationManager.activityType = CLActivityTypeFitness;
        
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
            [_locationManager requestWhenInUseAuthorization];
    }
    return _locationManager;
}

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

- (void)loadPartners
{
    [self showActivity];
    [NetworkManager loadPartnersWithCompletion:^(BOOL isSuccess, NSError *error)
     {
         _isPartnersLoaded = YES;
         [self loadPoints];
     }];
}

- (void)loadPoints
{
    if(_isPartnersLoaded && _isLocationDetected && !_isLoading)
    {
        NSInteger radius = [self mapRadius];
        CLLocationCoordinate2D center = [self mapCenterCoordinate];
        
        _isLoading = YES;
        [self showActivity];
        
        [NetworkManager loadPointsAroundLongitude:@(center.longitude) latitude:@(center.latitude) radius:@(radius) completion:^(BOOL isSuccess, NSError *error)
         {
             _isLoading = NO;
             [self fetchPointsWithCompletion:^{
                 [self hideActivity];
                 
             }];
         }];
    }
}

- (void)fetchPointsWithCompletion:(void(^)(void))completion
{
    [StorageManager fetchAllPointsWithCompletion:^(NSArray *objects, NSError *error)
     {
         [self.mapView removeAnnotations:self.mapView.annotations];
         
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             
             for(CPoint *point in objects)
             {
                 CLLocationCoordinate2D centerCoor = [self mapCenterCoordinate];
                 CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:centerCoor.latitude longitude:centerCoor.longitude];
                 CLLocation *pointLocation = [[CLLocation alloc] initWithLatitude:[point.latitude doubleValue] longitude:[point.longitude doubleValue]];
                 CLLocationDistance distance = [centerLocation distanceFromLocation:pointLocation];
                 
                 if(distance <= [self mapRadius])
                 {
                     PointAnnotation *pointAnnotation = [PointAnnotation new];
                     pointAnnotation.coordinate = CLLocationCoordinate2DMake([point.latitude doubleValue], [point.longitude doubleValue]);
                     pointAnnotation.point = point;
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self.mapView addAnnotation:pointAnnotation];
                     });
                 }
             }
             
             if(completion != NULL)
                 completion();
         });
     }];
}

- (CLLocationDistance)mapRadius
{
    CLLocationCoordinate2D centerCoor = [self mapCenterCoordinate];
    CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:centerCoor.latitude longitude:centerCoor.longitude];
    
    CLLocationCoordinate2D topCenterCoor = [self mapTopCenterCoordinate];
    CLLocation *topCenterLocation = [[CLLocation alloc] initWithLatitude:topCenterCoor.latitude longitude:topCenterCoor.longitude];
    
    CLLocationDistance radius = [centerLocation distanceFromLocation:topCenterLocation];
    
    return radius;
}

- (CLLocationCoordinate2D)mapCenterCoordinate
{
    CLLocationCoordinate2D centerCoor = [self.mapView centerCoordinate];
    return centerCoor;
}

- (CLLocationCoordinate2D)mapTopCenterCoordinate
{
    CLLocationCoordinate2D topCenterCoor = [self.mapView convertPoint:CGPointMake(self.mapView.frame.size.width / 2.0f, 0) toCoordinateFromView:self.mapView];
    return topCenterCoor;
}

- (void)zoomMap:(MKMapView*)mapView byDelta:(float)delta
{
    MKCoordinateRegion region = mapView.region;
    MKCoordinateSpan span = mapView.region.span;
    span.latitudeDelta *= delta;
    span.longitudeDelta *= delta;
    region.span = span;
    [mapView setRegion:region animated:YES];
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
    else if([annotation isKindOfClass:[MKUserLocation class]])
    {
        static NSString *annotationIdentifier = @"userAnnotationId";
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        
        if (!pinView)
        {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
            [pinView setPinColor:MKPinAnnotationColorRed];
        }
        else
            pinView.annotation = annotation;
        
        return pinView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self loadPoints];
}

#pragma mark - CLLocationManager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    MKCoordinateRegion neededRegion = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(.01, .01));
    [self.mapView setRegion:neededRegion animated:NO];
    self.mapView.showsUserLocation = YES;
    [self.locationManager stopUpdatingLocation];
    _isLocationDetected = YES;
    [self loadPoints];
}

#pragma mark - Actions

- (IBAction)locateMeButtonPressed:(id)sender
{
    [self.locationManager startUpdatingLocation];
}

- (IBAction)zoomInButtonPressed:(id)sender
{
    [self zoomMap:self.mapView byDelta:ZOOM_IN_SCALE];
}

- (IBAction)zoomOutButtonPressed:(id)sender
{
    [self zoomMap:self.mapView byDelta:ZOOM_OUT_SCALE];
}

@end
