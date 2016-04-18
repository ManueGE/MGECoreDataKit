//
//  MGEQuickFRC.h
//
//  Created by Manuel García-Estañ Martínez on 20/09/14.
//  Copyright (c) 2014 Manuel García-Estañ Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class MGEQuickFRC;
typedef void(^MGEQuickFRCContentDidChangeBlock)(MGEQuickFRC * controller);

/*!
 This class tries to encapsulate the boilerplate code that usually is added to a view controller when using a `NSFetchedResultsController` object.
 A `UITableView` or a `UICollectionView` can be assigned to instances of this class, and then will be updated on every update, insertion or deletion in the data model.
 */
@interface MGEQuickFRC : NSObject

///The managed object context used by the instance
@property (nonatomic, strong, readonly) NSManagedObjectContext * managedObjectContext;

///The name of the entity managed by the instance
@property (nonatomic, copy, readonly) NSString * entityName;

/// The array containging the sort descriptros
@property (nonatomic, strong) NSArray * sortDescriptors;

///The optional parameters dictionary
@property (nonatomic, strong, readonly) NSDictionary * params;
/// The actual Fetched Results Controller object managed by the instance
@property (nonatomic, strong, readonly) NSFetchedResultsController * fetchedResultsController;
/// The table view which will be updated when the content changes
@property (nonatomic, strong) UITableView * tableView;
/// The collection view which will be updated when the content changes
@property (nonatomic, strong) UICollectionView * collectionView;
/// This block is called (if exists) when a change did occurred
@property (nonatomic, copy) MGEQuickFRCContentDidChangeBlock didChangeBlock;


/*!
 \param context The managed object context where the objects will be searched
 \param entitiyName The name of the entity 
 \param sortDescriptors The descriptors to sort the fetched objects. Must be an array of `NSSortDescriptor`objects
 \param paramas This is a NSDictionary with optional parameters.
	It may contains the following keys:
	`MGEQuickFRCParamsPredicateKey`,
	`MGEQuickFRCParamsSectionNameKeyPathKey`,
	`MGEQuickFRCParamsCacheNameKey`,
	`MGEQuickFRCFetchBatchSizeKey`
 \return the new instace
 */
- (instancetype) initWithManagedObjectContext:(NSManagedObjectContext *) context
								   entityName:(NSString *) entityName
							  sortDescriptors:(NSArray *) sortDescriptors
									   params:(NSDictionary *) params;


/*!
 \return the number of sections of the QuickFRC
 */
- (NSInteger) numberOfSections;

/*!
 \return the number of items (or rows) for the given section
 \pram section the section
 */
- (NSInteger) numberOfItmesForSection:(NSInteger) section;

/*!
 \return the object at the given index path
 \pram indexPath the index path
 */
- (id) objectAtIndexPath:(NSIndexPath *) indexPath;

/*!
 \return an array with all the fetched objects
 */
- (NSArray *) fetchedObjects;

@end

/// The key to store the request predicate. Must be a NSPredicate
extern NSString * const MGEQuickFRCParamsPredicateKey;

/// The key to store the fetch result controller section name key path. Must be a NSString
extern NSString * const MGEQuickFRCParamsSectionNameKeyPathKey;

/// The key to store the fetch result controller cache name. Must be a NSString
extern NSString * const MGEQuickFRCParamsCacheNameKey;

/// The key to store the fetch result controller batch size. Must be a NSNumber. If not specified, 20 will be used
extern NSString * const MGEQuickFRCFetchBatchSizeKey;