//
//  NSManagedObjectContext+Extensions.h
//  PromUATest
//
//  Created by Artem on 07.04.15.
//  Copyright (c) 2015 ArtemK. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Extensions)

- (void)executeAsyncFetchRequest:(NSFetchRequest *)request completion:(void (^)(NSArray *objects, NSError *error))completion;

@end
