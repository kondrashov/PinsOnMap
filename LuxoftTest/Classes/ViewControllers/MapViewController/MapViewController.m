//
//  ViewController.m
//  LuxoftTest
//
//  Created by Artem on 18.04.15.
//  Copyright (c) 2015 ArtemK. All rights reserved.
//

#import "MapViewController.h"
#import "NetworkManager.h"
#import "CPartner+Extensions.h"
#import "NSManagedObject+Extensions.h"

@interface MapViewController ()

@end

@implementation MapViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [NetworkManager loadPartnersWithCompletion:^(BOOL isSuccess, NSError *error)
    {
        [NetworkManager loadPointsAroundLongitude:@(37) latitude:@(55) radius:@(10000) completion:^(BOOL isSuccess, NSError *error) {
        }];
    }];
}

@end
