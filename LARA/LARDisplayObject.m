//
//  LARDisplayObject.m
//  LARA
//
//  Created by Brian Thomas on 8/9/12.
//  Copyright (c) 2012 Endozemedia. All rights reserved.
//

#import "LARDisplayObject.h"
#import "LARCircleIcon.h"

@interface LARDisplayObject ()

@end

@implementation LARDisplayObject

@synthesize icon, iconType, ticker, isFadingIn;

- (void)updateFrameWithLocation:(CLLocation *)userLocation andHeading:(CLHeading *)userHeading{
    
}

- (void)updateAlphaFromRadarRadius:(NSUInteger)radarAnimationRadius{
    if (isFadingIn) {
        self.view.center;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    LARCircleIcon *iconForUse = [[LARCircleIcon alloc] init];
    self.icon = iconForUse;
    [self.view addSubview:self.icon];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
