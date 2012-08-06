//
//  LARRadarPointsViewController.h
//  LARA
//
//  Created by Chris Stephan on 6/25/12.
//  Copyright (c) 2012 Endozemedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LARRadarPointsViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (strong, nonatomic) NSFetchedResultsController *fetchResults;

- (void)getData;

@end
