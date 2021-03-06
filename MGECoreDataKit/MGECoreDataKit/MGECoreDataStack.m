//
//  MGECoreDataStack.m
//  MGECoreDataKit
//
//  Created by Manue on 29/4/15.
//  Copyright (c) 2015 manuege. All rights reserved.
//

#import "MGECoreDataStack.h"

static NSString * DefaultModelName;

@implementation MGECoreDataStack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Class initializer
+ (void) setDefaultModelName:(NSString *)modelName
{
    DefaultModelName = modelName;
}

#pragma marl - initializers
- (instancetype)initWithConcurrencyType:(NSManagedObjectContextConcurrencyType) concurrencyType temporary:(BOOL)temporary {
    
    if (self = [super init]) {
        _concurrencyType = concurrencyType;
        _temporary = temporary;
    }
    
    return self;
}

+ (instancetype)stack {
    return [[MGECoreDataStack alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType temporary:NO];
}

+ (instancetype)temporaryStack {
    return [[MGECoreDataStack alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType temporary:YES];
}

+ (instancetype) mainStack {
    
    static dispatch_once_t onceToken;
    static MGECoreDataStack *mainStack = nil;
    dispatch_once(&onceToken, ^{
        mainStack = [[MGECoreDataStack alloc] initWithConcurrencyType:NSMainQueueConcurrencyType
                                                            temporary:NO];
    });
    return mainStack;
}

#pragma mark - helpers

- (BOOL)saveContext:(NSError *__autoreleasing *)error
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if ([managedObjectContext hasChanges]) {
        return [managedObjectContext save:error];
    }
    
    return YES;
}

- (NSManagedObjectContext *)createChildContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType {
    NSManagedObjectContext * context = [[NSManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
    context.parentContext = self.managedObjectContext;
    return context;
}

- (NSManagedObjectContext *)createChildContext {
    return [self createChildContextWithConcurrencyType:NSPrivateQueueConcurrencyType];
}

#pragma mark - Core Data stack
// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    _managedObjectModel = nil;
    
    if (DefaultModelName) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:DefaultModelName withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    
    else {
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    }
    
    return _managedObjectModel;
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSString * sqliteFilename = [DefaultModelName ?: @"coredata_store" stringByAppendingPathExtension:@"sqlite"];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:sqliteFilename];
    
    
    NSDictionary * options =  @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES};
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:self.temporary ? NSInMemoryStoreType : NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options
                                                           error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - clean
- (void)clean:(NSError *__autoreleasing *)error {
    MGECoreDataStack * stack = self;
    NSPersistentStoreCoordinator * coordinator = stack.persistentStoreCoordinator;
    // NSManagedObjectModel * model = stack.managedObjectModel;
    NSURL * storeURL = coordinator.persistentStores.firstObject.URL;
    
    if ([coordinator respondsToSelector:@selector(destroyPersistentStoreAtURL:withType:options:error:)]) {
        [coordinator destroyPersistentStoreAtURL:storeURL
                                        withType:NSSQLiteStoreType
                                         options:nil
                                           error:error];
    }
    
    else {
        NSFileManager * manager = [NSFileManager defaultManager];
        [coordinator performBlockAndWait:^{
            [coordinator removePersistentStore:coordinator.persistentStores.firstObject
                                         error:error];
            [manager removeItemAtURL:storeURL error:error];
            [manager removeItemAtURL:[storeURL URLByAppendingPathComponent:@"-shm"] error:nil];
            [manager removeItemAtURL:[storeURL URLByAppendingPathComponent:@"-wal"] error:nil];
        }];
    }
    
    // Setup new stack
    stack->_persistentStoreCoordinator = nil;
    stack->_managedObjectModel = nil;
    stack->_managedObjectContext = nil;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
}


@end
