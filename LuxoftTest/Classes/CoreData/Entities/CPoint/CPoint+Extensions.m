//
//  CPoint+Extensions.m
//  LuxoftTest
//
//  Created by Artem on 18.04.15.
//  Copyright (c) 2015 ArtemK. All rights reserved.
//

#import "CPoint+Extensions.h"
#import "CPartner+Extensions.h"
#include "NSManagedObject+Extensions.h"

@implementation CPoint (Extensions)

+ (CPoint *)addPointWithPartnerId:(NSString *)partnerId
                        longitude:(double)longitude
                         latitude:(double)latitude
                          context:(NSManagedObjectContext *)context;
{
    CPoint *point = [self fetchPointWithPartnerId:partnerId longitude:longitude latitude:latitude context:context];
    if(!point)
    {
        point = [self createNewObjectInContext:context];
        point.partner = [CPartner fetchPartnerWithId:partnerId context:context];
        point.longitude = @(longitude);
        point.latitude = @(latitude);
    }
    return point;
}

+ (CPoint *)fetchPointWithPartnerId:(NSString *)partnerId
                          longitude:(double)longitude
                           latitude:(double)latitude
                            context:(NSManagedObjectContext *)context
{
    const float epsilon = 0.000001;
    NSString *predicate = [NSString stringWithFormat:@"(partner.partnerId LIKE[c] \"%@\") AND (longitude > %f AND longitude < %f) AND (latitude > %f AND latitude < %f)", partnerId, longitude - epsilon, longitude + epsilon, latitude - epsilon, latitude + epsilon];
    
    NSArray *objects = [CPoint fetchObjectsByPredicate:predicate sortKey:nil ascending:NO context:context];
    NSAssert(objects.count < 2, @"Multiple identical points for partner %@ (longitude = %f, latitude = %f)", partnerId, longitude, latitude);
    return [objects firstObject];
}

@end
