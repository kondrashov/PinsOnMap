//
//  NSManagedObjectContext+Extensions.m
//  PromUATest
//
//  Created by Artem on 07.04.15.
//  Copyright (c) 2015 ArtemK. All rights reserved.
//

#import "NSManagedObjectContext+Extensions.h"

@implementation NSManagedObjectContext (Extensions)

- (void)executeAsyncFetchRequest:(NSFetchRequest *)request completion:(void (^)(NSArray *objects, NSError *error))completion
{
    if (completion == NULL)
        return;
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;    
    NSManagedObjectContext *backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];

    [backgroundContext performBlock:^{
        backgroundContext.persistentStoreCoordinator = coordinator;
        
        NSError *error = nil;
        NSArray *fetchedObjects = [backgroundContext executeFetchRequest:request error:&error];
        
        [self performBlock:^{
            if (fetchedObjects)
            {
                NSMutableArray *mutObjects = [[NSMutableArray alloc] initWithCapacity:[fetchedObjects count]];
                for(NSManagedObject *object in fetchedObjects)
                {
                    NSManagedObject *obj = [self objectWithID:object.objectID];
                    [mutObjects addObject:obj];
                }
                
                completion([mutObjects copy], nil);
            }
            else
                completion(nil, error);
        }];
    }];
}

@end
