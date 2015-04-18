//
//  CPartner+Extensions.h
//  LuxoftTest
//
//  Created by Artem on 18.04.15.
//  Copyright (c) 2015 ArtemK. All rights reserved.
//

#import "CPartner.h"

@interface CPartner (Extensions)

+ (CPartner *)addPartnerWithId:(NSString *)partnerId context:(NSManagedObjectContext *)context;
+ (CPartner *)fetchPartnerWithId:(NSString *)partnerId context:(NSManagedObjectContext *)context;

@end
