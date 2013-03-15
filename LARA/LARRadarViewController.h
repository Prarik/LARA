//
//  LARRadarViewController.h
//  LARA
//
//  Created by Chris Stephan on 6/25/12.
//  Copyright (c) 2012 Endozemedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LARRadarViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIImageView *radarScreen;
@property (nonatomic, strong) IBOutlet UIButton *radarButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (strong, nonatomic) IBOutlet UILabel *locationAccuracyLabel;
@property (strong, nonatomic) IBOutlet UILabel *headingAccuracyLabel;
@property (strong, nonatomic) IBOutlet UILabel *aquiringDesiredAccuracyLabel;
@property (nonatomic, strong) UITabBarItem *tabBarItem;
@property (nonatomic) BOOL isTheActiveScreen;
@property (nonatomic) BOOL isPreparedToSwitchViews;
@property (nonatomic) BOOL hasInitializerFired;
@property (nonatomic) BOOL viewDidAppearLock;


- (IBAction)radarButtonClicked;
- (BOOL)tabBarWillMakeInactive;
- (void)tabBarDidMakeActive;
- (void)authorizeCoreLocation;

@end
