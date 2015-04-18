//
//  NSManagedObject+Extensions.h
//  PromUATest
//
//  Created by Artem on 07.04.15.
//  Copyright (c) 2015 ArtemK. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Extensions)

+ (instancetype)createNewObjectInContext:(NSManagedObjectContext *)context;
+ (NSManagedObjectContext *)moc;
+ (void)saveContext;

+ (NSArray *)fetchAllObjects;
+ (void)asyncFetchAllObjects:(void (^)(NSArray *objects, NSError *error))completion;

+ (NSArray *)fetchObjectsByPredicate:(NSString *)predicateString
                             sortKey:(NSString *)key
                           ascending:(BOOL)ascending
                             context:(NSManagedObjectContext *)context;

+ (void)asyncFetchObjectsByPredicate:(NSString *)predicateString
                             sortKey:(NSString *)key
                           ascending:(BOOL)ascending
                             context:(NSManagedObjectContext *)context
                          completion:(void (^)(NSArray *objects, NSError *error))completion;

+ (void)removeAllObjects;

@end
