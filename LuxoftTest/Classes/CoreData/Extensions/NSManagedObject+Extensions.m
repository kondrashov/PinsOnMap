//
//  NSManagedObject+Extensions.m
//  PromUATest
//
//  Created by Artem on 07.04.15.
//  Copyright (c) 2015 ArtemK. All rights reserved.
//

#import "NSManagedObject+Extensions.h"
#import "NSManagedObjectContext+Extensions.h"
#import "CoreDataManager.h"

@implementation NSManagedObject (Extensions)

+ (instancetype)createNewObjectInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
}

+ (NSManagedObjectContext *)moc
{
    return [[CoreDataManager sharedInstance] mainContext];
}

+ (void)saveContext
{
    [[CoreDataManager sharedInstance] saveContext];
}

+ (NSFetchRequest *)baseRequest
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:[self moc]];
    NSFetchRequest *request = [NSFetchRequest new];
    [request setEntity:entityDescription];
    return request;
}

+ (NSFetchRequest *)requestWithPredicate:(NSString *)predicateString sortKey:(NSString *)key ascending:(BOOL)ascending
{
    NSFetchRequest *request = [self baseRequest];

    if(predicateString.length > 0)
        [request setPredicate:[NSPredicate predicateWithFormat:predicateString]];
    
    if (key.length > 0)
    {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:ascending];
        [request setSortDescriptors:@[sortDescriptor]];
    }
    
    return request;
}

+ (NSArray *)fetchAllObjects
{
    NSError *error;
    NSArray *fetchedObjects = [[self moc] executeFetchRequest:[self baseRequest] error:&error];
    return fetchedObjects;
}

+ (void)asyncFetchAllObjects:(void (^)(NSArray *objects, NSError *error))completion
{
    [[self moc] executeAsyncFetchRequest:[self baseRequest] completion:completion];
}

+ (NSArray *)fetchObjectsByPredicate:(NSString *)predicateString
                             sortKey:(NSString *)key
                           ascending:(BOOL)ascending
                             context:(NSManagedObjectContext *)context
{
    NSError *error;
    NSFetchRequest *request = [self requestWithPredicate:predicateString sortKey:key ascending:ascending];
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];
    return fetchedObjects;
}


+ (void)asyncFetchObjectsByPredicate:(NSString *)predicateString
                        sortKey:(NSString *)key
                      ascending:(BOOL)ascending
                        context:(NSManagedObjectContext *)context
                     completion:(void (^)(NSArray *objects, NSError *error))completion
{
    NSFetchRequest *request = [self requestWithPredicate:predicateString sortKey:key ascending:ascending];
    [context executeAsyncFetchRequest:request completion:completion];
}

+ (void)removeAllObjects
{
    [self asyncFetchAllObjects:^(NSArray *objects, NSError *error)
     {
         for(NSManagedObject* object in objects)
             [[self moc] deleteObject:object];
         
         [self saveContext];
     }];
}

@end
