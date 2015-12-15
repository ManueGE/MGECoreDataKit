//
//  NSManagedObjectContext+MGECoreDataKit.h
//  MGECoreDataKit
//
//  Created by Manue on 1/10/15.
//  Copyright © 2015 manuege. All rights reserved.
//

#import <CoreData/CoreData.h>

/*!
 Methods to make easier to handle with managed object contexts
 */
@interface NSManagedObjectContext (MGECoreDataKit)

#pragma mark - getting entity from classes
/*!
 Returns the entity description for given class has in the receiver context
 */
- (NSEntityDescription *) entityDescriptionForClass:(Class) aClass;

/*!
 Returns the entity name for given class has in the receiver context
 */
- (NSString *) entityNameForClass:(Class) aClass;

#pragma mark - Insert
/*!
 Insert an object of the given class in the receiver. 
 It will launch an exception if the given class can not be found in the receiver context
 \param aClass the class of the object we want to insert
 \return the inserted object
*/
- (id) insertObjectOfClass:(Class) aClass;

/*!
 Insert an object of the given entity in the receiver.
 It will launch an exception if the given class can not be found in the receiver context
 \param entityName the name of the entity of the object we want to insert
 \return the inserted object
 */
- (id) insertObjectOfEntityWithName:(NSString *) entityName;

#pragma mark - fetching


/*!
 Execute a fetch request to find a set of instances of the given class.
 \param class the class whose instances we want to retrieve
 \param predicate the predicate to filter the request
 \param sortDescriptors the sort descriptors to sort the response
 \param limit the maximum number of items we can get
 \param offset the request will skip over 'offset' number of matching entries.
 \param error will return an error if the process fails
 \return a NSArray of objects if the method finish successfully, nil otherwise
 */
- (NSArray *) fetchClass:(Class) aClass
		   withPredicate:(NSPredicate *) predicate
		 sortDescriptors:(NSArray *) sortDescriptors
				   limit:(NSInteger) limit
				  offset:(NSInteger) offset
				   error:(NSError **) error;

/*!
 Execute a fetch request to find a set of instances of the given class.
 \param class the class whose instances we want to retrieve
 \param predicate the predicate to filter the request
 \param sortDescriptors the sort descriptors to sort the response
 \param error will return an error if the process fails
 \return a NSArray of objects if the method finish successfully, nil otherwise
 */
- (NSArray *) fetchClass:(Class) aClass
		   withPredicate:(NSPredicate *) predicate
		 sortDescriptors:(NSArray *) sortDescriptors
				   error:(NSError **) error;

/*!
 Execute a fetch request to find all the instances of the given class
 \param class the class whose instances we want to retrieve
 \param error will return an error if the process fails
 \return a NSArray of objects if the method finish successfully, nil otherwise
 */
- (NSArray *) fetchClass:(Class) aClass error:(NSError **) error;

@end
