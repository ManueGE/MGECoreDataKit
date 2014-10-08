//
//  MasterViewController.h
//  MGEQuickFRC
//
//  Created by Manue on 25/09/14.
//  Copyright (c) 2014 manuege. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
@class MGEQuickFRC;

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) MGEQuickFRC * quickFRC;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end

