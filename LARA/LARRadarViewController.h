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
@property (nonatomic, strong) NSManagedObjectContext *context;

- (IBAction)radarButtonClicked;
- (BOOL)stopAnimatingRadar;

@end
