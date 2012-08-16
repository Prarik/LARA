//
//  LARRadarPointsViewController.h
//  LARA
//
//  Created by Chris Stephan on 6/25/12.
//  Copyright (c) 2012 Endozemedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LARAddPointViewController.h"

@class LARAddPointViewController;
@class LARLocationManager;

@interface LARRadarPointsViewController : UITableViewController <NSFetchedResultsControllerDelegate, LARAddPointViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *fetchResults;
@property (nonatomic, strong) LARAddPointViewController *addItemController;
@property (nonatomic, strong) LARLocationManager *manager;

- (void)getData;

@end
