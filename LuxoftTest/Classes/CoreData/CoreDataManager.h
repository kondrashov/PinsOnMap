//
//  CoreDataManager.h
//  LuxoftTest
//
//  Created by Artem on 18.04.15.
//  Copyright (c) 2015 ArtemK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject

+ (instancetype)sharedInstance;

- (NSManagedObjectContext *)mainContext;
- (NSManagedObjectContext *)privateContext;
- (void)saveContext;

@end
