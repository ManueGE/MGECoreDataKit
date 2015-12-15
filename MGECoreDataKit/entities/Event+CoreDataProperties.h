//
//  Event+CoreDataProperties.h
//  MGECoreDataKit
//
//  Created by Manue on 1/10/15.
//  Copyright © 2015 manuege. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface Event (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *timeStamp;

@end

NS_ASSUME_NONNULL_END
