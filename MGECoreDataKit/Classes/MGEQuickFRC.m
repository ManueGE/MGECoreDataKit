//
//  MGEQuickFRC.m
//
//  Created by Manuel García-Estañ Martínez on 20/09/14.
//  Copyright (c) 2014 Manuel García-Estañ Martínez. All rights reserved.
//

#import "MGEQuickFRC.h"

NSString * const MGEQuickFRCParamsPredicateKey = @"MGEQuickFRCParamsPredicateKey";
NSString * const MGEQuickFRCParamsSectionNameKeyPathKey = @"MGEQuickFRCParamsSectionNameKeyPathKey";
NSString * const MGEQuickFRCParamsCacheNameKey = @"MGEQuickFRCParamsCacheNameKey";
NSString * const MGEQuickFRCFetchBatchSizeKey = @"MGEQuickFRCFetchBatchSizeKey";

@interface MGEQuickFRC () <NSFetchedResultsControllerDelegate>
{
	NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
}
@property (nonatomic, strong) NSFetchedResultsController * fetchedResultsController;
@end

@implementation MGEQuickFRC
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Init
- (instancetype) initWithManagedObjectContext:(NSManagedObjectContext *) context
								   entityName:(NSString *) entityName
							  sortDescriptors:(NSArray *) sortDescriptors
									   params:(NSDictionary *) params;
{
    if (self = [super init]) {
        
        _entityName = entityName;
        _managedObjectContext = context;
		_sortDescriptors = sortDescriptors;
        _params = params.copy;
		
		_objectChanges = [NSMutableArray array];
		_sectionChanges = [NSMutableArray array];
		
    }
    
    return self;
}

- (void) dealloc
{
	self.fetchedResultsController.delegate = nil;
	self.fetchedResultsController = nil;
}

#pragma mark - FRC shortcuts
- (NSInteger) numberOfSections
{
    return [self.fetchedResultsController sections].count;
}

- (NSInteger) numberOfItmesForSection:(NSInteger)section
{
    id  sectionInfo =
    [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (id) objectAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (BOOL) performFetch:(NSError *__autoreleasing *)error
{
    BOOL success = [self.fetchedResultsController performFetch:error];
    return success;
}

- (NSArray *) fetchedObjects
{
	return self.fetchedResultsController.fetchedObjects;
}

#pragma mark - FRC creation
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    //Create fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:self.entityName
                                   inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
	fetchRequest.sortDescriptors = self.sortDescriptors;
    
    //Params
    NSInteger fetchBatchSize = 20;
    if (self.params[MGEQuickFRCFetchBatchSizeKey]) {
        fetchBatchSize = [self.params[MGEQuickFRCFetchBatchSizeKey] integerValue];
    }
    fetchRequest.fetchBatchSize = fetchBatchSize;
    
    NSPredicate * predicate = self.params[MGEQuickFRCParamsPredicateKey];
    if (predicate) {
        fetchRequest.predicate = predicate;
    }
    
    
    //Create fetch results controller
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:self.params[MGEQuickFRCParamsSectionNameKeyPathKey]
                                                   cacheName:self.params[MGEQuickFRCParamsCacheNameKey]];

    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
	
	[_fetchedResultsController performFetch:nil];
    
    return _fetchedResultsController;
    
}


#pragma mark FRC delegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    if (self.tableView) {
		[self.tableView beginUpdates];
	}
	

}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
	//Table view
    UITableView *tableView = self.tableView;
    if (tableView) {
		
		switch(type) {
				
			case NSFetchedResultsChangeInsert:
				[tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
				break;
				
			case NSFetchedResultsChangeDelete:
				[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
				break;
				
			case NSFetchedResultsChangeUpdate:
				[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
				break;
				
			case NSFetchedResultsChangeMove:
				[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
				[tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
				
				
				break;
		}
		
	}

	
	//Collection
	UICollectionView * collectionView = self.collectionView;
	if (collectionView) {
		
		NSMutableDictionary *change = [NSMutableDictionary new];
		switch(type)
		{
			case NSFetchedResultsChangeInsert:
				change[@(type)] = newIndexPath;
				break;
			case NSFetchedResultsChangeDelete:
				change[@(type)] = indexPath;
				break;
			case NSFetchedResultsChangeUpdate:
				change[@(type)] = indexPath;
				break;
			case NSFetchedResultsChangeMove:
				change[@(type)] = @[indexPath, newIndexPath];
				break;
		}
		[_objectChanges addObject:change];
		
	}
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
	//Table view
	if (self.tableView) {
		
		switch(type) {
				
			case NSFetchedResultsChangeInsert:
				[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
				break;
				
			case NSFetchedResultsChangeDelete:
				[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
				break;
				
			default:
				break;
		}
		
	}

	
	//Collection
	UICollectionView * collectionView = self.collectionView;
	if (collectionView) {
		
		NSMutableDictionary *change = [NSMutableDictionary new];
		
		switch(type) {
			case NSFetchedResultsChangeInsert:
				change[@(type)] = @(sectionIndex);
				break;
			case NSFetchedResultsChangeDelete:
				change[@(type)] = @(sectionIndex);
				break;
				
			default:
				break;
		}
		
		[_sectionChanges addObject:change];
		
	}

}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {

    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    if (self.tableView) {
		[self.tableView endUpdates];
	}
	
	
	if (self.collectionView) {
		if ([_sectionChanges count] > 0)
		{
			[self.collectionView performBatchUpdates:^{
				
				for (NSDictionary *change in _sectionChanges)
				{
					[change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
						
						NSFetchedResultsChangeType type = [key unsignedIntegerValue];
						switch (type)
						{
							case NSFetchedResultsChangeInsert:
								[self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
								break;
							case NSFetchedResultsChangeDelete:
								[self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
								break;
							case NSFetchedResultsChangeUpdate:
								[self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
								break;
								
							default:
								break;
						}
						
					}];
				}
			} completion:nil];
		}
		
		if ([_objectChanges count] > 0 && [_sectionChanges count] == 0)
		{
			[self.collectionView performBatchUpdates:^{
				
				for (NSDictionary *change in _objectChanges)
				{
					
					id key = change.allKeys.lastObject;
					id obj = change[key];
					
					NSFetchedResultsChangeType type = [key unsignedIntegerValue];
					switch (type)
					{
						case NSFetchedResultsChangeInsert:
							[self.collectionView insertItemsAtIndexPaths:@[obj]];
							break;
						case NSFetchedResultsChangeDelete:
							[self.collectionView deleteItemsAtIndexPaths:@[obj]];
							break;
						case NSFetchedResultsChangeUpdate:
							[self.collectionView reloadItemsAtIndexPaths:@[obj]];
							break;
						case NSFetchedResultsChangeMove:
							[self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
							break;
							
						default:
							break;
					}
					
				}
			} completion:nil];
		}
		
		[_sectionChanges removeAllObjects];
		[_objectChanges removeAllObjects];
	}
}



@end

