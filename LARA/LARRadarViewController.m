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
@property (nonatomic, strong) NSTimer *timerForRadar;
@property (strong, nonatomic) NSFetchedResultsController *resultsController;

- (void)loadBackgroundImage;
- (void)loadRadarScan;
- (void)animateRadar;
- (void)fetchRadarObjects;

@end

@implementation LARRadarViewController

@synthesize radarScreen;
@synthesize shouldAnimateRadar;
@synthesize radarScan;
@synthesize radarButton;
@synthesize timerForRadar;
@synthesize context;
@synthesize resultsController;

- (IBAction)radarButtonClicked{
    if (shouldAnimateRadar){
        self.shouldAnimateRadar = NO;
        [self.radarScan removeFromSuperview];
        self.radarScan = nil;
    }
    else {
        self.shouldAnimateRadar = YES;
        [self loadRadarScan];
        [self animateRadar];
    }
}

- (void)animateRadar{
//    if (timerForRadar) {
//        [timerForRadar invalidate];
//        self.timerForRadar = nil;
//    }
    
    CGRect temp = self.radarScan.frame;
    
    if (temp.size.width > 360) {
        [self radarButtonClicked];
        [self.timerForRadar invalidate];
        self.timerForRadar = nil;
    }
    else {
    temp = CGRectMake(temp.origin.x-2, temp.origin.y-2, temp.size.width+4, temp.size.height+4);
    self.radarScan.frame = temp;
    [self.radarScan setNeedsDisplay];
    
    if (shouldAnimateRadar)
        if (self.timerForRadar == nil) {
    timerForRadar = [NSTimer scheduledTimerWithTimeInterval:0.04 target:self selector:@selector(animateRadar) userInfo:nil repeats:YES];
        }
    }
}

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
    self.shouldAnimateRadar = NO;
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

- (void)loadRadarScan{
    if (self.radarScan) {
        self.radarScan = nil;
    }
    self.radarScan = [[LARRadarScan alloc] initWithFrame:CGRectMake(149, 210, 22, 22)];
    [self.view addSubview:radarScan];
}

- (void)fetchRadarObjects{
    NSEntityDescription *radarPoints = [NSEntityDescription entityForName:@"TrackedObject" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:radarPoints];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    self.resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    NSError *anyError = nil;
    [self.resultsController performFetch:&anyError];
    if (anyError) {
        //Handle Errors.
    }
}

@end
