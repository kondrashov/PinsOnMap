//
//  CPoint+Extensions.h
//  LuxoftTest
//
//  Created by Artem on 18.04.15.
//  Copyright (c) 2015 ArtemK. All rights reserved.
//

#import "CPoint.h"

@interface CPoint (Extensions)

+ (CPoint *)addPointWithPartnerId:(NSString *)partnerId
                        longitude:(double)longitude
                         latitude:(double)latitude
                          context:(NSManagedObjectContext *)context;
@end
