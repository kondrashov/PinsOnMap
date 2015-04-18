//
//  CPartner+Extensions.m
//  LuxoftTest
//
//  Created by Artem on 18.04.15.
//  Copyright (c) 2015 ArtemK. All rights reserved.
//

#import "CPartner+Extensions.h"
#import "NSManagedObject+Extensions.h"

@implementation CPartner (Extensions)

+ (CPartner *)addPartnerWithId:(NSString *)partnerId context:(NSManagedObjectContext *)context
{
    CPartner *partner = [self fetchPartnerWithId:partnerId context:context];
    if(!partner)
    {
        partner = [self createNewObjectInContext:context];
        partner.partnerId = partnerId;
    }
    return partner;
}

+ (CPartner *)fetchPartnerWithId:(NSString *)partnerId context:(NSManagedObjectContext *)context
{
    NSString *predicate = [NSString stringWithFormat:@"partnerId LIKE[c] \"%@\"", partnerId];
    NSArray *objects = [CPartner fetchObjectsByPredicate:predicate sortKey:nil ascending:NO context:context];
    NSAssert(objects.count < 2, @"Multiple partners with id %@: %@", partnerId, objects);
    return [objects firstObject];
}

@end
