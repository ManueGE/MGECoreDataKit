//
//  MasterViewController.m
//  MGEQuickFRC
//
//  Created by Manue on 25/09/14.
//  Copyright (c) 2014 manuege. All rights reserved.
//

#import "MasterViewController.h"
#import "MGEQuickFRC.h"

@interface MasterViewController ()

@end

@implementation MasterViewController

- (void)awakeFromNib {
	[super awakeFromNib];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.title = nil;

	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
	UIBarButtonItem * deleteLastButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete last" style:UIBarButtonItemStylePlain target:self action:@selector(deleteLastObject:)];
	UIBarButtonItem * updateLastObject = [[UIBarButtonItem alloc] initWithTitle:@"Update last" style:UIBarButtonItemStylePlain target:self action:@selector(updateLastObject:)];
	
	self.navigationItem.rightBarButtonItems = @[addButton, deleteLastButton, updateLastObject];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - actions
- (void)insertNewObject:(id)sender {
	NSManagedObjectContext *context = self.managedObjectContext;
	NSString * entityName = self.quickFRC.entityName;
	NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
	    
	// If appropriate, configure the new managed object.
	// Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
	[newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
	    
	// Save the context.
	[self saveContext];
	
}

- (void)deleteLastObject:(id)sender {

	NSManagedObject * object = self.quickFRC.fetchedObjects.lastObject;
	[object.managedObjectContext deleteObject:object];
	
	// Save the context.
	[self saveContext];
}

- (void)updateLastObject:(id)sender {

	NSManagedObject * object = self.quickFRC.fetchedObjects.lastObject;
	[object setValue:[NSDate date] forKey:@"timeStamp"];
	
	// Save the context.
	[self saveContext];
}

- (void) saveContext
{
	NSError *error = nil;
	if (![self.managedObjectContext save:&error]) {
		// Replace this implementation with code to handle the error appropriately.
		// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.quickFRC.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.quickFRC numberOfItmesForSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	NSManagedObject *object = [self.quickFRC objectAtIndexPath:indexPath];
	cell.textLabel.text = [[object valueForKey:@"timeStamp"] description];
}

#pragma mark - Fetched results controller
- (MGEQuickFRC *) quickFRC
{
	if (_quickFRC) {
		return _quickFRC;
	}
	
	NSDictionary * params = nil;
	/*
	 Some params may be added:
	 params =
	 @{ MGEQuickFRCFetchBatchSizeKey : @20,
	 MGEQuickFRCParamsPredicateKey : [NSPredicate predicateWithFormat:@"..."],
	 MGEQuickFRCParamsSectionNameKeyPathKey : @"timestamp",
	 MGEQuickFRCParamsCacheNameKey : @"Root"
	 };
	 */
	
	_quickFRC = [[MGEQuickFRC alloc] initWithManagedObjectContext:self.managedObjectContext
													   entityName:@"Event"
												  sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES]]
														   params:params];
	
	//Set the tableview of the QuickFRC to get the updates
	_quickFRC.tableView = self.tableView;
	
	return _quickFRC;
	

}


@end
