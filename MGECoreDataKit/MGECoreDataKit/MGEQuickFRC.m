//
//  MGEQuickFRC.m
//
//  Created by Manuel García-Estañ Martínez on 20/09/14.
//  Copyright (c) 2014 Manuel García-Estañ Martínez. All rights reserved.
//

#import "MGEQuickFRC.h"

#import "MGEQuickFRCTableViewHandler.h"
#import "MGEQuickFRCCollectionViewHandler.h"

NSString * const MGEQuickFRCParamsPredicateKey = @"MGEQuickFRCParamsPredicateKey";
NSString * const MGEQuickFRCParamsSectionNameKeyPathKey = @"MGEQuickFRCParamsSectionNameKeyPathKey";
NSString * const MGEQuickFRCParamsCacheNameKey = @"MGEQuickFRCParamsCacheNameKey";
NSString * const MGEQuickFRCFetchBatchSizeKey = @"MGEQuickFRCFetchBatchSizeKey";

@interface MGEQuickFRC () <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController * fetchedResultsController;
@property (nonatomic, strong) MGEQuickFRCTableViewHandler * tableViewHandler;
@property (nonatomic, strong) MGEQuickFRCCollectionViewHandler * collectionViewHandler;
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableViewHandler controllerWillChangeContent:controller];
        [self.collectionViewHandler controllerWillChangeContent:controller];
    });
    
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableViewHandler controller:controller
                          didChangeObject:anObject
                              atIndexPath:indexPath
                            forChangeType:type
                             newIndexPath:newIndexPath];
        
        [self.collectionViewHandler controller:controller
                               didChangeObject:anObject
                                   atIndexPath:indexPath
                                 forChangeType:type
                                  newIndexPath:newIndexPath];
    });
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableViewHandler controller:controller
                         didChangeSection:sectionInfo
                                  atIndex:sectionIndex
                            forChangeType:type];
        
        [self.collectionViewHandler controller:controller
                              didChangeSection:sectionInfo
                                       atIndex:sectionIndex
                                 forChangeType:type];
        
    });
    
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableViewHandler controllerDidChangeContent:controller];
        [self.collectionViewHandler controllerDidChangeContent:controller];
        
        if (self.didChangeBlock) {
            self.didChangeBlock(self);
        }
        
    });
}

#pragma mark - Handler accessors
- (void) setTableView:(UITableView *)tableView {
    
    MGEQuickFRCTableViewHandler * handler = nil;
    if (tableView) {
        handler = [[MGEQuickFRCTableViewHandler alloc] initWithTableView:tableView];
    }
    
    self.tableViewHandler = handler;
}

- (UITableView *)tableView {
    return self.tableViewHandler.tableView;
}

- (void)setCollectionView:(UICollectionView *)collectionView {
    MGEQuickFRCCollectionViewHandler * handler = nil;
    if (collectionView) {
        handler = [[MGEQuickFRCCollectionViewHandler alloc] initWithCollectionView:collectionView];
    }
    
    self.collectionViewHandler = handler;
}

- (UICollectionView *)collectionView {
    return self.collectionViewHandler.collectionView;
}
@end