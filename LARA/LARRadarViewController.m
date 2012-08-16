//
//  LARRadarViewController.m
//  LARA
//
//  Created by Chris Stephan on 6/25/12.
//  Copyright (c) 2012 Endozemedia. All rights reserved.
//

#import "LARRadarViewController.h"
#import "LARRadarScan.h"
#import "TrackedObject.h"
#import "LARDisplayObject.h"
#import "LARCircleIcon.h"
#import "LARSquareIcon.h"
#import "LARAppDelegate.h"
#import "LARLocationManager.h"

#define kTitle @"Sensor"
#define kTrackedObject @"TrackedObject"
#define kCenterOfRadarX 160
#define kCenterOfRadarY 186

#define kLocationDistanceThreshold 100000
#define kFirstRingDistanceThreshold 12
#define kSecondRingDistanceThreshold 100
#define kThirdRingDistanceThreshold 400
#define kLastRingDistanceThreshold 100000

#define kFirstRingMagnitude 40
#define kSecondRingMagnitude 75
#define kThirdRingMagnitude 115
#define kLastRingMagnitude 155

#define kMaximumRadarScan 360
#define kRadarScanOrigin CGRectMake(149, 170, 22, 22)

@interface LARRadarViewController ()

@property (nonatomic) BOOL shouldAnimateRadar;
@property (nonatomic, strong) LARRadarScan *radarScan;
@property (nonatomic, strong) NSTimer *timerForRadar;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) NSMutableArray *fetchedObjectsForDisplay;
@property (nonatomic, strong) NSArray *displayObjects;
@property (nonatomic, strong) CLLocation *mostRecentLocation;

@property (nonatomic, strong) NSArray *firstRingDisplayObjects;
@property (nonatomic, strong) NSArray *secondRingDisplayObjects;
@property (nonatomic, strong) NSArray *thirdRingDisplayObjects;
@property (nonatomic, strong) NSArray *lastRingDisplayObjects;

- (void)loadBackgroundImage;
- (void)loadRadarScan;
- (void)animateRadar;
- (void)fetchRadarObjects;
- (void)prepareObjectsForDisplay;
- (void)addDisplayViewsToScreen;
- (void)getLocationAndHeading;
- (void)removeAllRadarPoints;
- (void)setUpAndAnimate;

@end

@implementation LARRadarViewController

@synthesize radarScreen;
@synthesize shouldAnimateRadar;
@synthesize radarScan;
@synthesize radarButton;
@synthesize timerForRadar;
@synthesize context;
@synthesize resultsController;
@synthesize fetchedObjectsForDisplay;
@synthesize displayObjects;
@synthesize mostRecentLocation;
@synthesize firstRingDisplayObjects;
@synthesize secondRingDisplayObjects;
@synthesize thirdRingDisplayObjects;
@synthesize lastRingDisplayObjects;

- (IBAction)radarButtonClicked
{
    if (shouldAnimateRadar)
    {
        self.shouldAnimateRadar = NO;
        [self.radarScan removeFromSuperview];
        [self removeAllRadarPoints];
        self.radarScan = nil;
        [self.timerForRadar invalidate];
        self.timerForRadar = nil;
    }
    else
    {
        self.shouldAnimateRadar = YES;
        [self setUpAndAnimate];
    }
}

- (void)setUpAndAnimate
{
    [self prepareObjectsForDisplay];
    [self addDisplayViewsToScreen];
    [self loadRadarScan];
    [self animateRadar];
    return;
}

- (void)animateRadar
{
    
// check current size of radar scan
    CGRect temp = self.radarScan.frame;
    
// end the animation if it has reached a desired maximum size and resize radar if it has not.
    if (temp.size.width > kMaximumRadarScan)
    {
        [self radarButtonClicked];
    }
    else
    {
        temp = CGRectMake(temp.origin.x-2, temp.origin.y-2, temp.size.width+4, temp.size.height+4);
        self.radarScan.frame = temp;
        [self.radarScan setNeedsDisplay];
    
        if (shouldAnimateRadar)
        {
            if (self.timerForRadar == nil)
            {
                timerForRadar = [NSTimer scheduledTimerWithTimeInterval:0.04
                                                                 target:self
                                                               selector:@selector(animateRadar)
                                                               userInfo:nil
                                                                repeats:YES];
            }
        }
    }
}

- (BOOL)stopAnimatingRadar
{
    if (shouldAnimateRadar) 
    {
        self.shouldAnimateRadar = NO;
        [self removeAllRadarPoints];
        [self.radarScan removeFromSuperview];
        self.radarScan = nil;
        [self.timerForRadar invalidate];
        self.timerForRadar = nil;
        self.resultsController = nil;
    }
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
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
    [self fetchRadarObjects];
    //[self fetchRadarObjects];
    //NSLog(@"%f, %f", iconForScan.center.x, iconForScan.center.y);
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

- (void)loadBackgroundImage
{
    UIImage *radarBackground = [UIImage imageNamed:@"Radarprac2"];
    self.radarScreen.image = radarBackground;
    self.radarScreen.alpha = 0.6;
}

- (void)loadRadarScan
{
    if (self.radarScan)
    {
        self.radarScan = nil;
    }
    self.radarScan = [[LARRadarScan alloc] initWithFrame:kRadarScanOrigin];
    [self.view addSubview:radarScan];
}


#pragma mark
#pragma Prepare Display Views

- (void)getLocationAndHeading
{
    
}

- (void)fetchRadarObjects
{
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

- (void)prepareObjectsForDisplay
{
    
    NSArray *chosenObjects = [self.resultsController fetchedObjects];
    
    ////////////////////////////////////////// INSERT FAKE TRACKED OBJECTS HERE //////////////////////////////////////////
    LARAppDelegate *myAppDel = (LARAppDelegate *)[[UIApplication sharedApplication] delegate];
    LARLocationManager *manager = myAppDel.locationManager;
    self.mostRecentLocation = manager.currentLocation;
//    NSLog(@"For mostRecent Lat = %f, Lon = %f", self.mostRecentLocation.coordinate.latitude, self.mostRecentLocation.coordinate.longitude);
//    
//    TrackedObject *one = [NSEntityDescription insertNewObjectForEntityForName:kTrackedObject inManagedObjectContext:self.context];
//    one.name = @"Pontiac Sunfire";
//    one.subtitle = @"PSUN";
//    one.iconImageColor = @"red";
//    one.iconImageType = @"triangle";
//    one.lat = [[NSNumber alloc] initWithDouble:41.15778];
//    one.lon = [[NSNumber alloc] initWithDouble:-85.13868];
//    
//    TrackedObject *two = [NSEntityDescription insertNewObjectForEntityForName:kTrackedObject inManagedObjectContext:self.context];
//    two.name = @"Television";
//    two.subtitle = @"HMTV";
//    two.iconImageColor = @"yellow";
//    two.iconImageType = @"square";
//    two.lat = [[NSNumber alloc] initWithDouble:41.15578];
//    two.lon = [[NSNumber alloc] initWithDouble:-85.13768];
//    
//    TrackedObject *three = [NSEntityDescription insertNewObjectForEntityForName:kTrackedObject inManagedObjectContext:self.context];
//    three.name = @"Tree";
//    three.subtitle = @"TREE";
//    three.iconImageColor = @"cyan";
//    three.iconImageType = @"circle";
//    three.lat = [[NSNumber alloc] initWithDouble:41.15498];
//    three.lon = [[NSNumber alloc] initWithDouble:-85.13789];
//    
//    NSArray *chosenObjects = [[NSArray alloc] initWithObjects:one, two, three, nil];
    
    ////////////////////////////////////////// INSERT FAKE TRACKED OBJECTS HERE //////////////////////////////////////////
    
    NSMutableArray *firstDisplayHolder = [[NSMutableArray alloc] init];
    NSMutableArray *secondDisplayHolder = [[NSMutableArray alloc] init];
    NSMutableArray *thirdDisplayHolder = [[NSMutableArray alloc] init];
    NSMutableArray *lastDisplayHolder = [[NSMutableArray alloc] init];
    NSNumber *currentLocationLat = [NSNumber numberWithDouble:self.mostRecentLocation.coordinate.latitude];
    NSNumber *currentLocationLon = [NSNumber numberWithDouble:self.mostRecentLocation.coordinate.longitude];
    NSLog(@"%f", [currentLocationLat doubleValue]);
    
    for (TrackedObject *each in chosenObjects)
    {
        NSLog(@"%f", [each.lat doubleValue]);
        CLLocation *trackedObjectsLocation = [[CLLocation alloc] initWithLatitude:[each.lat doubleValue] longitude:[each.lon doubleValue]];
        //NSLog(@"For Tracked After %f, %f", trackedObjectsLocation.coordinate.latitude, trackedObjectsLocation.coordinate.longitude);
        CLLocationDistance distanceFromCurrentLocation = [trackedObjectsLocation distanceFromLocation:self.mostRecentLocation];
        NSLog(@"distance from %@: %f", each.name , distanceFromCurrentLocation);
        if (distanceFromCurrentLocation < kLocationDistanceThreshold)
        {
            /////////////////////////////////////////////////////////////////////////// Set up a LARDisplayObject.
            
            LARDisplayObject *thisDisplayObject = [[LARDisplayObject alloc] initWithShape:each.iconImageType andColor:each.iconImageColor];
            thisDisplayObject.view.frame = CGRectMake(0, 0, 20, 29);
            thisDisplayObject.view.bounds = CGRectMake(0, 0, 20, 29);
            thisDisplayObject.ticker.text = each.subtitle;
            thisDisplayObject.view.alpha = 1;
            
            
            /////////////////////////////////////////////////////////////////////////// Find the angle from north.
            
            NSNumber *changeInLat = [NSNumber numberWithDouble:trackedObjectsLocation.coordinate.latitude-[currentLocationLat doubleValue]];
            NSNumber *changeInLon = [NSNumber numberWithDouble:trackedObjectsLocation.coordinate.longitude-[currentLocationLon doubleValue]];
            //NSLog(@"^Lat %f, ^Lon %f", [changeInLat doubleValue], [changeInLon doubleValue]);
            
            NSNumber *magnitudeOfChange = [NSNumber numberWithDouble:sqrt( pow( [changeInLat doubleValue] , 2 ) + pow( [changeInLon doubleValue] , 2 ))];
            //NSLog(@"%f", [magnitudeOfChange doubleValue]);
            
            ///// Protect against divison by 0
            if ([magnitudeOfChange doubleValue] == 0) {
                magnitudeOfChange = [NSNumber numberWithDouble:0.00001];
            }
            
            ///// Adjust changes to a unit vector in order to find appropriate angle
            changeInLat = [NSNumber numberWithDouble:[changeInLat doubleValue]/[magnitudeOfChange doubleValue]];
            changeInLon = [NSNumber numberWithDouble:[changeInLon doubleValue]/[magnitudeOfChange doubleValue]];
            //NSLog(@"^Lat %f, ^Lon %f", [changeInLat doubleValue], [changeInLon doubleValue]);
            //NSLog(@"%f", sqrt( pow( [changeInLat doubleValue] , 2 ) + pow( [changeInLon doubleValue] , 2 )));
            
            ///// Large if to add up angles from true north
            {
                if (( [changeInLat doubleValue] > 0 ) & ( [changeInLon doubleValue] == 0) )
                {
                    thisDisplayObject.angleFromNorth = [NSNumber numberWithDouble:0];
                }
                else if (( [changeInLat doubleValue] > 0 ) & ( [changeInLon doubleValue] > 0) )
                {
                    thisDisplayObject.angleFromNorth = [NSNumber numberWithDouble:90-acos([changeInLon doubleValue])*(180/M_PI)];
                }
                else if (( [changeInLat doubleValue] == 0 ) & ( [changeInLon doubleValue] > 0) )
                {
                    thisDisplayObject.angleFromNorth = [NSNumber numberWithDouble:90];
                }
                else if (( [changeInLat doubleValue] < 0 ) & ( [changeInLon doubleValue] > 0) )
                {   
                    thisDisplayObject.angleFromNorth = [NSNumber numberWithDouble:acos([changeInLon doubleValue])*(180/M_PI)+90];
                }
                else if (( [changeInLat doubleValue] < 0 ) & ( [changeInLon doubleValue] == 0) )
                {
                    thisDisplayObject.angleFromNorth = [NSNumber numberWithDouble:180];
                }
                else if (( [changeInLat doubleValue] < 0 ) & ( [changeInLon doubleValue] < 0) )
                {
                    thisDisplayObject.angleFromNorth = [NSNumber numberWithDouble:acos([changeInLon doubleValue])*(180/M_PI)+90];
                }
                else if (( [changeInLat doubleValue] == 0 ) & ( [changeInLon doubleValue] < 0) )
                {
                    thisDisplayObject.angleFromNorth = [NSNumber numberWithDouble:270];
                }
                else if (( [changeInLat doubleValue] > 0 ) & ( [changeInLon doubleValue] < 0) )
                {
                    thisDisplayObject.angleFromNorth = [NSNumber numberWithDouble:450-acos([changeInLon doubleValue])*(180/M_PI)];
                    NSLog(@"Object's Angle From North = %f", [thisDisplayObject.angleFromNorth doubleValue]);
                }
            }
            
            /////////////////////////////////////////////////////////////////////////// Sort object into correct holding array.
            
            if (distanceFromCurrentLocation < kFirstRingDistanceThreshold)
            {
                [firstDisplayHolder addObject:thisDisplayObject];
            }
            else if ((distanceFromCurrentLocation < kSecondRingDistanceThreshold) & (distanceFromCurrentLocation >= kFirstRingDistanceThreshold))
            {
                [secondDisplayHolder addObject:thisDisplayObject];
            }
            else if ((distanceFromCurrentLocation < kThirdRingDistanceThreshold) & (distanceFromCurrentLocation >= kSecondRingDistanceThreshold))
            {
                [thirdDisplayHolder addObject:thisDisplayObject];
            }
            else if ((distanceFromCurrentLocation < kLastRingDistanceThreshold) & (distanceFromCurrentLocation >= kThirdRingDistanceThreshold))
            {
                [lastDisplayHolder addObject:thisDisplayObject];
            }
            
        }
    }
    
    /////////////////////////////////////////////////////////////////////////// Convert mutable holding arrays into corresponding NSArray properties for the coming animation.
    
    self.firstRingDisplayObjects = [firstDisplayHolder copy];
    self.secondRingDisplayObjects = [secondDisplayHolder copy];
    self.thirdRingDisplayObjects = [thirdDisplayHolder copy];
    self.lastRingDisplayObjects = [lastDisplayHolder copy];
}

#warning VVVVVV
////// SUBVIEWS ARE ADDED HERE YET THIS METHOD WILL BE CALLED IN A BACKGROUND THREAD - CHANGE WHERE IT IS CALLED OR DISPATCH TO MAIN THREAD.
- (void)addDisplayViewsToScreen
{ 
    LARAppDelegate *appDel = (LARAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber *magneticHeading = [NSNumber numberWithDouble:appDel.locationManager.currentHeading.magneticHeading];
    
    for (LARDisplayObject *each in self.firstRingDisplayObjects) 
    {
        // Adjust angle from true north by currentHeading to correctly place the view
        NSNumber *adjustedHeading = [NSNumber numberWithDouble:(360-[magneticHeading intValue]+[each.angleFromNorth intValue]) % 360];
        
        each.view.center = CGPointMake(kCenterOfRadarX+kFirstRingMagnitude*sin(M_PI/180*[adjustedHeading doubleValue]), kCenterOfRadarY-kFirstRingMagnitude*cos(M_PI/180*[adjustedHeading doubleValue]));
        [self.view addSubview:each.view];
    }
     
    for (LARDisplayObject *each in self.secondRingDisplayObjects) 
    {
        // Adjust angle from true north by currentHeading to correctly place the view
        NSNumber *adjustedHeading = [NSNumber numberWithDouble:(360-[magneticHeading intValue]+[each.angleFromNorth intValue]) % 360];
        each.view.center = CGPointMake(kCenterOfRadarX+kSecondRingMagnitude*sin(M_PI/180*[adjustedHeading doubleValue]), kCenterOfRadarY-kSecondRingMagnitude*cos(M_PI/180*[adjustedHeading doubleValue]));
        [self.view addSubview:each.view];
    }
     
    for (LARDisplayObject *each in self.thirdRingDisplayObjects) 
    {
        // Adjust angle from true north by currentHeading to correctly place the view
        NSLog(@"Magnetic Heading = %d, Angle of Object From North = %d", [magneticHeading intValue], [each.angleFromNorth intValue]); //, (360-[magneticHeading intValue]+[each.angleFromNorth intValue]) % 360);
        NSNumber *adjustedHeading = [NSNumber numberWithDouble:(360-[magneticHeading intValue]+[each.angleFromNorth intValue]) % 360];
        NSLog(@"Adjusted Heading = %f", [adjustedHeading doubleValue]);
        each.view.center = CGPointMake(kCenterOfRadarX+kThirdRingMagnitude*sin(M_PI/180*[adjustedHeading doubleValue]), kCenterOfRadarY-kThirdRingMagnitude*cos(M_PI/180*[adjustedHeading doubleValue]));
        
        
        NSLog(@"Sin: %f,Cos: %f", sin(M_PI/180*[adjustedHeading doubleValue]), cos(M_PI/180*[adjustedHeading doubleValue]));
        NSLog(@"Sin wMag: %f,Cos wMag: %f", kThirdRingMagnitude*sin(M_PI/180*[adjustedHeading doubleValue]), kThirdRingMagnitude*cos(M_PI/180*[adjustedHeading doubleValue]));
        NSLog(@"Object view X Coord = %f, Object View Y Coord = %f", each.view.center.x, each.view.center.y);
        NSLog(@"--");
        NSLog(@"--");
        NSLog(@"--");
        [self.view addSubview:each.view];
    }
     
    for (LARDisplayObject *each in self.lastRingDisplayObjects) 
    {
        // Adjust angle from true north by currentHeading to correctly place the view
        NSNumber *adjustedHeading = [NSNumber numberWithDouble:(360-[magneticHeading intValue]+[each.angleFromNorth intValue]) % 360];
        each.view.center = CGPointMake(kCenterOfRadarX+kLastRingMagnitude*sin(M_PI/180*[adjustedHeading doubleValue]), kCenterOfRadarY-kLastRingMagnitude*cos(M_PI/180*[adjustedHeading doubleValue]));
        [self.view addSubview:each.view];
    }
}

- (void)removeAllRadarPoints{
    for (LARDisplayObject *each in self.firstRingDisplayObjects) 
    {
        [each.view removeFromSuperview];
    }
    
    for (LARDisplayObject *each in self.secondRingDisplayObjects) 
    {
        [each.view removeFromSuperview];
    }
    
    for (LARDisplayObject *each in self.thirdRingDisplayObjects) 
    {
        [each.view removeFromSuperview];
    }
    
    for (LARDisplayObject *each in self.lastRingDisplayObjects) 
    {
        [each.view removeFromSuperview];
    }
    
    self.firstRingDisplayObjects = nil;
    self.secondRingDisplayObjects = nil;
    self.thirdRingDisplayObjects = nil;
    self.lastRingDisplayObjects = nil;
}

@end
























