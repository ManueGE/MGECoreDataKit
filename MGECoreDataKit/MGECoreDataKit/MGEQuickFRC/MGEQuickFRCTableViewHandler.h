//
//  MGEQuickFRCTableViewHandler.h
//  MGECoreDataKit
//
//  Created by Manu on 10/1/16.
//  Copyright © 2016 manuege. All rights reserved.
//

@import UIKit;
@import CoreData;

@interface MGEQuickFRCTableViewHandler : NSObject <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong, readonly) UITableView * tableView;
- (instancetype) initWithTableView:(UITableView *) tableView;
@end
