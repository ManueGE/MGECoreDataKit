//
//  NSManagedObjectContext+MGECoreDataKit.m
//  MGECoreDataKit
//
//  Created by Manue on 1/10/15.
//  Copyright © 2015 manuege. All rights reserved.
//

#import "NSManagedObjectContext+MGECoreDataKit.h"

@implementation NSManagedObjectContext (MGECoreDataKit)

#pragma mark - getting entity from classes
- (NSEntityDescription *)entityDescriptionForClass:(Class)aClass {
	NSEntityDescription * retVal = nil;
	NSString * entityName = NSStringFromClass(aClass);
	NSManagedObjectModel *model = self.persistentStoreCoordinator.managedObjectModel;
	for (NSEntityDescription *description in model.entities) {
		if ([description.managedObjectClassName isEqualToString:entityName]) {
			retVal = description;
			break;
		}
	}
	
	if (!retVal) {
		[NSException raise:NSInvalidArgumentException
					format:@"no entity found that uses %@ as its class", entityName];
	}
	
	return retVal;
}

- (NSString *)entityNameForClass:(Class)aClass {
	return [self entityDescriptionForClass:aClass].name;
}

#pragma mark - insert
- (id)insertObjectOfEntityWithName:(NSString *)entityName {
	return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self];
}

- (id)insertObjectOfClass:(Class)aClass {
	NSString * entityName = [self entityNameForClass:aClass];
	return [self insertObjectOfEntityWithName:entityName];
}


#pragma mark - fetch
- (NSArray *) fetchClass:(Class)aClass
		   withPredicate:(NSPredicate *)predicate
		 sortDescriptors:(NSArray *)sortDescriptors
				   limit:(NSInteger)limit
				  offset:(NSInteger)offset
				   error:(NSError **)error {
	
	NSString * entityName = [self entityNameForClass:aClass];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
	[fetchRequest setEntity:entity];
	
	fetchRequest.predicate = predicate;
	fetchRequest.sortDescriptors = sortDescriptors;
	fetchRequest.fetchLimit = limit;
	
	return [self executeFetchRequest:fetchRequest error:error];
}

- (NSArray *) fetchClass:(Class)aClass
		   withPredicate:(NSPredicate *)predicate
		 sortDescriptors:(NSArray *)sortDescriptors
				   error:(NSError **) error {
	
	return [self fetchClass:aClass
			  withPredicate:predicate
			sortDescriptors:sortDescriptors
					  limit:0
					 offset:0
					  error:error];
	
}

- (NSArray *)fetchClass:(Class)aClass error:(NSError **)error {
	return [self fetchClass:aClass
					  withPredicate:nil
			sortDescriptors:nil
					  error:error];
}

@end
