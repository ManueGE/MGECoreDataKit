//
//  MGEQuickFRCCollectionViewHandler.h
//  MGECoreDataKit
//
//  Created by Manu on 10/1/16.
//  Copyright © 2016 manuege. All rights reserved.
//

@import UIKit;
@import CoreData;

@interface MGEQuickFRCCollectionViewHandler : NSObject <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong, readonly) UICollectionView * collectionView;
- (instancetype) initWithCollectionView:(UICollectionView *) collectionView;
@end
