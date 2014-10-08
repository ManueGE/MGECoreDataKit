//
//  MGECoreDataManager.h
//  Copyright (c) 2014 Manuel García-Estañ. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface MGECoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (void) setModelName:(NSString *) modelName;

+ (instancetype) sharedManager;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end
