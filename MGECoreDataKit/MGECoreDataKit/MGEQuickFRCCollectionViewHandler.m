//
//  MGEQuickFRCCollectionViewHandler.m
//  MGECoreDataKit
//
//  Created by Manu on 10/1/16.
//  Copyright © 2016 manuege. All rights reserved.
//

#import "MGEQuickFRCCollectionViewHandler.h"

@interface MGEQuickFRCCollectionViewHandler ()
@property (nonatomic, strong) UICollectionView * collectionView;

@property (nonatomic, strong) NSMutableArray * objectChanges;
@property (nonatomic, strong) NSMutableArray * sectionChanges;
@end

@implementation MGEQuickFRCCollectionViewHandler

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView {
    if (self = [super init]) {
        self.collectionView = collectionView;
    }
    
    return self;
}

#pragma mark - Fetched results controller delegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
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
    
    [self.objectChanges addObject:change];
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
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
    
    [self.sectionChanges addObject:change];
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    @try {
        [self applyChanges];
    }
    @catch (NSException *exception) {
        [self.collectionView reloadData];
    }
    @finally {
        self.sectionChanges = nil;
        self.objectChanges = nil;
    }
}

- (void) applyChanges {
    
    if ([self.sectionChanges count] > 0) {
        
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in self.sectionChanges)
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
    
    if ([self.objectChanges count] > 0 && [self.sectionChanges count] == 0) {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in self.objectChanges)
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
                    {
                        NSIndexPath * indexPath = obj[0];
                        NSIndexPath * newIndexPath = obj[1];
                        
                        if (indexPath.section != newIndexPath.section ||
                            indexPath.item != newIndexPath.item) {
                            
                            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                            [self.collectionView insertItemsAtIndexPaths:@[newIndexPath ]];
                        }
                        
                        else {
                            [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                        }
                        
                    }
                        break;
                        
                    default:
                        break;
                }
                
            }
        } completion:nil];
    }
}

#pragma mark - Overriden getters
- (NSMutableArray *) objectChanges
{
    if (_objectChanges == nil) {
        _objectChanges = [[NSMutableArray alloc] init];
    }
    
    return _objectChanges;
}

- (NSMutableArray *) sectionChanges
{
    if (_sectionChanges == nil) {
        _sectionChanges = [[NSMutableArray alloc] init];
    }
    
    return _sectionChanges;
}
@end
