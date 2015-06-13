//
//  MGECoreDataStack.h
//  MGECoreDataKit
//
//  Created by Manue on 29/4/15.
//  Copyright (c) 2015 manuege. All rights reserved.
//

@import CoreData;

@interface MGECoreDataStack : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, readonly, getter=isTemporary) BOOL temporary;
@property (nonatomic, readonly) NSManagedObjectContextConcurrencyType concurrencyType;

/*!
 Set the default model name. If will be used when a stack is going to be created
 but a model name is not provided. If it is not set or it is nil, the library
 will merge all the available contexts.
 */
+ (void) setDefaultModelName:(NSString *) modelName;

/*!
 Returns the main stack. This stack will use the defined DefaultModelName or will
 merge all the available models if it is not set. The `NSManagedObjectContext` of
 the main stack will use `NSMainQueueConcurrencyType` as concurrency type
 \return the instance
 */
+ (instancetype) mainStack;

/*!
 Instantiate a no temporary new stack with the default model
 
 The `NSManagedObjectContext` of this instances will use `NSPrivateQueueConcurrencyType`
 as its concurrency type
 \return the instance
 */
+ (instancetype) stack;

/*!
 Instantiate a temporary new stack with the default model
 
 The `NSManagedObjectContext` of this instances will use `NSPrivateQueueConcurrencyType`
 as its concurrency type
 */
+ (instancetype) temporaryStack;

/*!
 Instantiates a child context of the managed object context.
 The `NSManagedObjectContext` will use `NSPrivateQueueConcurrencyType`
 \return the context
 */
- (NSManagedObjectContext *) createChildContext;

/*!
 Instantiates a child context of the managed object context.
 \return the context
 */
- (NSManagedObjectContext *) createChildContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType) concurrencyType;

/*!
 Save the managed object context
 \param error the pointer to the error that may occur during while saving
 \return YES if the context is saved, NO otherwise
 */
- (BOOL) saveContext:(NSError **) error;

@end
