//
//  LARRadarViewController.m
//  LARA
//
//  Created by Chris Stephan on 6/25/12.
//  Copyright (c) 2012 Endozemedia. All rights reserved.
//

#import "LARRadarViewController.h"
#import "LARRadarScan.h"
#define kTitle @"Sensor"

@interface LARRadarViewController ()

@property (nonatomic) BOOL shouldAnimateRadar;
@property (strong, nonatomic) LARRadarScan *radarScan;

- (void)loadBackgroundImage;

@end

@implementation LARRadarViewController

@synthesize radarScreen;
@synthesize shouldAnimateRadar;
@synthesize radarScan;

- (void)stopAnimatingRadar{
    self.shouldAnimateRadar = NO;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = kTitle;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.shouldAnimateRadar = YES;
    [self loadBackgroundImage];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.radarScreen = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadBackgroundImage{
    UIImage *radarBackground = [UIImage imageNamed:@"Radarprac2"];
    self.radarScreen.image = radarBackground;
    self.radarScreen.alpha = 0.6;
}

@end
