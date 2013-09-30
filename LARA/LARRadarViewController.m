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
#import "DDLog.h"

#define kTitle @"Sensor"
#define kTrackedObject @"TrackedObject"
#define kCenterOfRadarX 160
#define kCenterOfRadarY 196

#define kLocationDistanceThreshold 1500
#define kReachedDistanceThreshold 20
#define kFirstRingDistanceThreshold 50
#define kSecondRingDistanceThreshold 150
#define kThirdRingDistanceThreshold 500
#define kLastRingDistanceThreshold 1500

#define kFirstRingMagnitude 40
#define kSecondRingMagnitude 75
#define kThirdRingMagnitude 115
#define kLastRingMagnitude 155

#define kMaximumRadarScan 480
#define kRadarScanOrigin CGRectMake(149, 180, 22, 22)

@interface LARRadarViewController ()

@property (nonatomic) BOOL isAnimatingRadar;
@property (nonatomic, strong) LARRadarScan *radarScan;
@property (nonatomic, strong) NSTimer *timerForRadar;
@property (nonatomic, strong) NSTimer *timerBeforeAnimation;
@property (nonatomic, strong) NSTimer *initialTimer;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) NSMutableArray *fetchedObjectsForDisplay;
@property (nonatomic, strong) NSArray *displayObjects;
@property (nonatomic, strong) CLLocation *mostRecentLocation;
@property (nonatomic, strong) CLHeading *mostRecentHeading;

@property (nonatomic, strong) NSArray *reachedDisplayObjects;
@property (nonatomic, strong) NSArray *firstRingDisplayObjects;
@property (nonatomic, strong) NSArray *secondRingDisplayObjects;
@property (nonatomic, strong) NSArray *thirdRingDisplayObjects;
@property (nonatomic, strong) NSArray *lastRingDisplayObjects;

@property (nonatomic) int centerOfRadarY;
@property (nonatomic) int centerOfRadarX;

- (void)loadRadarScan;
- (void)animateRadar;
- (void)animateObjectAlpha;

- (void)fetchRadarObjects;
- (void)prepareObjectsForDisplay;
- (void)addDisplayViewsToScreen;

- (void)initialLaunch;
- (void)servicesSettingsSelected;

- (BOOL)stopAnimatingRadar;
- (void)removeAllRadarPoints;
- (void)setUpAndAnimate;
- (void)waitForAccuracy;

@end

@implementation LARRadarViewController

@synthesize radarScreen;
@synthesize isAnimatingRadar;
@synthesize hasInitializerFired;
@synthesize isPreparedToSwitchViews;
@synthesize radarScan;
@synthesize radarButton;
@synthesize initialTimer;
@synthesize timerForRadar;
@synthesize timerBeforeAnimation;
@synthesize context;
@synthesize locationAccuracyLabel;
@synthesize headingAccuracyLabel;
@synthesize aquiringDesiredAccuracyLabel;
@synthesize resultsController;
@synthesize fetchedObjectsForDisplay;
@synthesize displayObjects;
@synthesize mostRecentLocation;
@synthesize mostRecentHeading;
@synthesize firstRingDisplayObjects;
@synthesize secondRingDisplayObjects;
@synthesize thirdRingDisplayObjects;
@synthesize lastRingDisplayObjects;
@synthesize activityIndicator;
@synthesize isTheActiveScreen;
@synthesize tabBarItem;

static const int ddLogLevel = LOG_LEVEL_ERROR;

#pragma mark - Life Cycle

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:kTitle image:[UIImage imageNamed:@"RadarTabIcon.png"] tag:1];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isPreparedToSwitchViews = NO;
    self.isTheActiveScreen = YES;
    self.isAnimatingRadar = NO;
    [self authorizeCoreLocation];
    
    DDLogInfo(@"viewDidLoad");
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!self.viewDidAppearLock) {
        
        self.viewDidAppearLock = YES;
        
        self.isPreparedToSwitchViews = NO;
        self.hasInitializerFired = NO;
        
        DDLogInfo(@"viewDidAppear");
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.viewDidAppearLock) {
        
        self.viewDidAppearLock = NO;
        
        DDLogInfo(@"viewDidDisappear");
    }
}

- (void)viewDidUnload
{
    [self setLocationAccuracyLabel:nil];
    [self setHeadingAccuracyLabel:nil];
    [self setAquiringDesiredAccuracyLabel:nil];
    [super viewDidUnload];
    self.radarScreen = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadRadarScan
{
    if (self.radarScan)
    {
        self.radarScan = nil;
    }
    self.radarScan = [[LARRadarScan alloc] initWithFrame:CGRectMake(_centerOfRadarX-11, _centerOfRadarY-11, 22, 22)];
    [self.view addSubview:radarScan];
}

#pragma mark - Launch Methods


- (void)authorizeCoreLocation
{
    CLAuthorizationStatus authorizationStat = [CLLocationManager authorizationStatus];
    if (authorizationStat == kCLAuthorizationStatusAuthorized) 
    {
        [self waitForAccuracy];
    }
    else if (authorizationStat == kCLAuthorizationStatusDenied)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services"
                                                        message:@"This application requires location services to function.  This authorization can be adjusted in the settings application on this device."
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else if (authorizationStat == kCLAuthorizationStatusRestricted) 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services"
                                                        message:@"This application requires location services to function."
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else if (authorizationStat == kCLAuthorizationStatusNotDetermined) 
    {
        LARAppDelegate *myAppDel = (LARAppDelegate *)[[UIApplication sharedApplication] delegate];
        LARLocationManager *manager = myAppDel.locationManager;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(servicesSettingsSelected) name:@"serviceStatusSet" object:nil];
        [manager.manager startUpdatingLocation];
        [manager.manager startUpdatingHeading];
    }
}

- (void)waitForAccuracy
{
    LARAppDelegate *myAppDel = (LARAppDelegate *)[[UIApplication sharedApplication] delegate];
    LARLocationManager *manager = myAppDel.locationManager;
    [self.activityIndicator startAnimating];
    self.aquiringDesiredAccuracyLabel.hidden = NO;
    self.hasInitializerFired = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initialLaunch) name:@"locationInitialized" object:nil];
    [manager.manager startUpdatingLocation];
    [manager.manager startUpdatingHeading];
    [manager resetInitializer];
    [self.initialTimer invalidate];
    self.initialTimer = nil;
    self.initialTimer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(initialLaunch) userInfo:nil repeats:NO];
}

- (void)initialLaunch
{
    DDLogInfo(@"initialLaunch: %d", hasInitializerFired);
    
    if (!hasInitializerFired)
    {
        [self.activityIndicator stopAnimating];
        self.isTheActiveScreen = YES;
        self.isPreparedToSwitchViews = YES;
        self.hasInitializerFired = YES;
        [self.timerBeforeAnimation invalidate];
        self.timerBeforeAnimation = nil;
        self.aquiringDesiredAccuracyLabel.hidden = YES;
        [self fetchRadarObjects];
        self.timerBeforeAnimation = [NSTimer scheduledTimerWithTimeInterval:1
                                                                     target:self
                                                                   selector:@selector(radarButtonClicked)
                                                                   userInfo:nil
                                                                    repeats:NO];
    }
}

- (void)servicesSettingsSelected
{
    [self authorizeCoreLocation];
}

#pragma mark - Animate Radar

- (IBAction)radarButtonClicked
{
    if (isTheActiveScreen) 
    {
        if (isAnimatingRadar)
        {
            self.isAnimatingRadar = NO;
            [self.radarScan removeFromSuperview];
            [self removeAllRadarPoints];
            self.radarScan = nil;
            [self.timerForRadar invalidate];
            self.timerForRadar = nil;
            self.timerBeforeAnimation = nil;
            self.timerBeforeAnimation = [NSTimer scheduledTimerWithTimeInterval:1
                                             target:self
                                           selector:@selector(radarButtonClicked)
                                           userInfo:nil
                                            repeats:NO];
        }
        else
        {
            self.isAnimatingRadar = YES;
            [self setUpAndAnimate];
        }
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
        temp = CGRectMake(temp.origin.x-3, temp.origin.y-3, temp.size.width+6, temp.size.height+6);
        self.radarScan.frame = temp;
        [self.radarScan setNeedsDisplay];
        [self animateObjectAlpha];
        
        if (isAnimatingRadar)
        {
            if (self.timerForRadar == nil)
            {
                timerForRadar = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                                 target:self
                                                               selector:@selector(animateRadar)
                                                               userInfo:nil
                                                                repeats:YES];
            }
        }
    }
}

- (void)animateObjectAlpha
{
    CGRect temp = self.radarScan.frame;
    NSNumber *magnitude = [NSNumber numberWithDouble:temp.size.height/2];
    if (([magnitude doubleValue] > 0) & !([magnitude doubleValue] > 40))
    {
        for (LARDisplayObject *each in self.reachedDisplayObjects)
        {
            each.view.alpha +=0.1;
        }
    }
    if (([magnitude doubleValue] > 35) & !([magnitude doubleValue] > 70)) 
    {
        for (LARDisplayObject *each in self.firstRingDisplayObjects) 
        {
            each.view.alpha +=0.1;
        }
    }
    if (([magnitude doubleValue] > 70) & !([magnitude doubleValue] > 110)) 
    {
        for (LARDisplayObject *each in self.secondRingDisplayObjects) 
        {
            each.view.alpha +=0.1;
        }
    }
    if (([magnitude doubleValue] > 110) & !([magnitude doubleValue] > 150)) 
    {
        for (LARDisplayObject *each in self.thirdRingDisplayObjects) 
        {
            each.view.alpha +=0.1;
        }
    }
    if (([magnitude doubleValue] > 150) & !([magnitude doubleValue] > 180)) 
    {
        for (LARDisplayObject *each in self.lastRingDisplayObjects) 
        {
            each.view.alpha +=0.1;
        }
    }
    if ([magnitude doubleValue] > 180) 
    {
        for (LARDisplayObject *each in self.firstRingDisplayObjects) 
        {
            each.view.alpha -=0.06;
        }
        for (LARDisplayObject *each in self.secondRingDisplayObjects) 
        {
            each.view.alpha -=0.06;
        }
        for (LARDisplayObject *each in self.thirdRingDisplayObjects) 
        {
            each.view.alpha -=0.06;
        }
        for (LARDisplayObject *each in self.lastRingDisplayObjects) 
        {
            each.view.alpha -=0.06;
        }
        for (LARDisplayObject *each in self.reachedDisplayObjects)
        {
            each.view.alpha -=0.06;
        }
    }
}

#pragma mark - Prepare Display

- (void)tabBarDidMakeActive
{
    [self authorizeCoreLocation];
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

    LARAppDelegate *myAppDel = (LARAppDelegate *)[[UIApplication sharedApplication] delegate];
    LARLocationManager *manager = myAppDel.locationManager;
    self.mostRecentLocation = manager.currentLocation;
    DDLogInfo(@"For mostRecent Lat = %f, Lon = %f", self.mostRecentLocation.coordinate.latitude, self.mostRecentLocation.coordinate.longitude);

    NSMutableArray *reachedDisplayHolder = [[NSMutableArray alloc] init];
    NSMutableArray *firstDisplayHolder = [[NSMutableArray alloc] init];
    NSMutableArray *secondDisplayHolder = [[NSMutableArray alloc] init];
    NSMutableArray *thirdDisplayHolder = [[NSMutableArray alloc] init];
    NSMutableArray *lastDisplayHolder = [[NSMutableArray alloc] init];
    NSNumber *currentLocationLat = [NSNumber numberWithDouble:self.mostRecentLocation.coordinate.latitude];
    NSNumber *currentLocationLon = [NSNumber numberWithDouble:self.mostRecentLocation.coordinate.longitude];
    DDLogInfo(@"%f", [currentLocationLat doubleValue]);
    
    for (TrackedObject *each in chosenObjects)
    {
        DDLogInfo(@"%f", [each.lat doubleValue]);
        CLLocation *trackedObjectsLocation = [[CLLocation alloc] initWithLatitude:[each.lat doubleValue] longitude:[each.lon doubleValue]];
        DDLogInfo(@"For Tracked After %f, %f", trackedObjectsLocation.coordinate.latitude, trackedObjectsLocation.coordinate.longitude);
        CLLocationDistance distanceFromCurrentLocation = [trackedObjectsLocation distanceFromLocation:self.mostRecentLocation];
        DDLogInfo(@"distance from %@: %f", each.name , distanceFromCurrentLocation);
        if ((distanceFromCurrentLocation < kLocationDistanceThreshold) & ([each.shouldDisplay boolValue]))
        {
            /////////////////////////////////////////////////////////////////////////// Set up a LARDisplayObject.
            
            LARDisplayObject *thisDisplayObject = [[LARDisplayObject alloc] initWithShape:each.iconImageType andColor:each.iconImageColor];
            DDLogInfo(@"%@ , %@", each.iconImageType, each.iconImageColor);
            thisDisplayObject.view.frame = CGRectMake(0, 0, 22, 29);
            thisDisplayObject.view.bounds = CGRectMake(0, 0, 22, 29);
            thisDisplayObject.ticker.text = each.subtitle;
            thisDisplayObject.view.alpha = 0;
            
            /////////////////////////////////////////////////////////////////////////// Find the angle from north.
            
            NSNumber *changeInLat = [NSNumber numberWithDouble:trackedObjectsLocation.coordinate.latitude - [currentLocationLat doubleValue]];
            NSNumber *changeInLon = [NSNumber numberWithDouble:trackedObjectsLocation.coordinate.longitude - [currentLocationLon doubleValue]];
            DDLogInfo(@"^Lat %f, ^Lon %f", [changeInLat doubleValue], [changeInLon doubleValue]);
            
            NSNumber *magnitudeOfChange = [NSNumber numberWithDouble:sqrt( pow( [changeInLat doubleValue] , 2 ) +
                                                                          pow( [changeInLon doubleValue] , 2 ))];
            DDLogInfo(@"%f", [magnitudeOfChange doubleValue]);
            
            ///// Protect against divison by 0
            if ([magnitudeOfChange doubleValue] == 0)
            {
                magnitudeOfChange = [NSNumber numberWithDouble:0.00001];
            }
            
            ///// Adjust changes to a unit vector in order to find appropriate angle
            changeInLat = [NSNumber numberWithDouble:[changeInLat doubleValue]/[magnitudeOfChange doubleValue]];
            changeInLon = [NSNumber numberWithDouble:[changeInLon doubleValue]/[magnitudeOfChange doubleValue]];
            DDLogInfo(@"^Lat %f, ^Lon %f", [changeInLat doubleValue], [changeInLon doubleValue]);
            DDLogInfo(@"%f", sqrt( pow( [changeInLat doubleValue] , 2 ) + pow( [changeInLon doubleValue] , 2 )));
            
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
                    DDLogInfo(@"Object's Angle From North = %f", [thisDisplayObject.angleFromNorth doubleValue]);
                }
            }
            
            /////////////////////////////////////////////////////////////////////////// Sort object into correct holding array.
            
            if (distanceFromCurrentLocation < kReachedDistanceThreshold)
            {
                [reachedDisplayHolder addObject:thisDisplayObject];
            }
            if ((distanceFromCurrentLocation < kFirstRingDistanceThreshold) & (distanceFromCurrentLocation >= kReachedDistanceThreshold))
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
    
    self.reachedDisplayObjects = [reachedDisplayHolder copy];
    self.firstRingDisplayObjects = [firstDisplayHolder copy];
    self.secondRingDisplayObjects = [secondDisplayHolder copy];
    self.thirdRingDisplayObjects = [thirdDisplayHolder copy];
    self.lastRingDisplayObjects = [lastDisplayHolder copy];
}

- (void)addDisplayViewsToScreen
{
    CGPoint centerForScan = radarScreen.center;
    _centerOfRadarX = centerForScan.x;
    _centerOfRadarY = centerForScan.y;
    
    LARAppDelegate *appDel = (LARAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.mostRecentHeading = appDel.locationManager.currentHeading;
    NSNumber *magneticHeading = [NSNumber numberWithDouble:appDel.locationManager.currentHeading.magneticHeading];
    
    int numberReached = [self.reachedDisplayObjects count];
    for (LARDisplayObject *each in self.reachedDisplayObjects)
    {
        // Adjust angle from true north by currentHeading to correctly place the view
        each.view.center = CGPointMake(_centerOfRadarX-2*(numberReached-1) + 4 * [self.reachedDisplayObjects indexOfObject:each], _centerOfRadarY);
        [self.view addSubview:each.view];
    }
    
    for (LARDisplayObject *each in self.firstRingDisplayObjects)
    {
        // Adjust angle from true north by currentHeading to correctly place the view
        NSNumber *adjustedHeading = [NSNumber numberWithDouble:(360-[magneticHeading intValue]+[each.angleFromNorth intValue]) % 360];
        
        each.view.center = CGPointMake(_centerOfRadarX+kFirstRingMagnitude*sin(M_PI/180*[adjustedHeading doubleValue]), _centerOfRadarY-kFirstRingMagnitude*cos(M_PI/180*[adjustedHeading doubleValue]));
        [self.view addSubview:each.view];
    }
     
    for (LARDisplayObject *each in self.secondRingDisplayObjects) 
    {
        // Adjust angle from true north by currentHeading to correctly place the view
        NSNumber *adjustedHeading = [NSNumber numberWithDouble:(360-[magneticHeading intValue]+[each.angleFromNorth intValue]) % 360];
        each.view.center = CGPointMake(_centerOfRadarX+kSecondRingMagnitude*sin(M_PI/180*[adjustedHeading doubleValue]), _centerOfRadarY-kSecondRingMagnitude*cos(M_PI/180*[adjustedHeading doubleValue]));
        [self.view addSubview:each.view];
    }
     
    for (LARDisplayObject *each in self.thirdRingDisplayObjects) 
    {
        // Adjust angle from true north by currentHeading to correctly place the view
        DDLogInfo(@"Magnetic Heading = %d, Angle of Object From North = %d", [magneticHeading intValue], [each.angleFromNorth intValue]); //, (360-[magneticHeading intValue]+[each.angleFromNorth intValue]) % 360);
        NSNumber *adjustedHeading = [NSNumber numberWithDouble:(360-[magneticHeading intValue]+[each.angleFromNorth intValue]) % 360];
        DDLogInfo(@"Adjusted Heading = %f", [adjustedHeading doubleValue]);
        each.view.center = CGPointMake(_centerOfRadarX+kThirdRingMagnitude*sin(M_PI/180*[adjustedHeading doubleValue]), _centerOfRadarY-kThirdRingMagnitude*cos(M_PI/180*[adjustedHeading doubleValue]));
        
        
        DDLogInfo(@"Sin: %f,Cos: %f", sin(M_PI/180*[adjustedHeading doubleValue]), cos(M_PI/180*[adjustedHeading doubleValue]));
        DDLogInfo(@"Sin wMag: %f,Cos wMag: %f", kThirdRingMagnitude*sin(M_PI/180*[adjustedHeading doubleValue]), kThirdRingMagnitude*cos(M_PI/180*[adjustedHeading doubleValue]));
        DDLogInfo(@"Object view X Coord = %f, Object View Y Coord = %f", each.view.center.x, each.view.center.y);
        DDLogInfo(@"--");
        DDLogInfo(@"--");
        DDLogInfo(@"--");
        [self.view addSubview:each.view];
    }
     
    for (LARDisplayObject *each in self.lastRingDisplayObjects) 
    {
        // Adjust angle from true north by currentHeading to correctly place the view
        NSNumber *adjustedHeading = [NSNumber numberWithDouble:(360-[magneticHeading intValue]+[each.angleFromNorth intValue]) % 360];
        each.view.center = CGPointMake(_centerOfRadarX+kLastRingMagnitude*sin(M_PI/180*[adjustedHeading doubleValue]), _centerOfRadarY-kLastRingMagnitude*cos(M_PI/180*[adjustedHeading doubleValue]));
        [self.view addSubview:each.view];
    }
    self.locationAccuracyLabel.text = [NSString stringWithFormat:@"%u meters", (int)self.mostRecentLocation.horizontalAccuracy];
    self.headingAccuracyLabel.text = [NSString stringWithFormat:@"%u degrees", (int)self.mostRecentHeading.headingAccuracy];
}

#pragma mark - Tear Down Display

- (BOOL)tabBarWillMakeInactive
{
    self.isTheActiveScreen = NO;
    [self.timerBeforeAnimation invalidate];
    self.timerBeforeAnimation = nil;
    return [self stopAnimatingRadar];
}

- (BOOL)stopAnimatingRadar
{
    if (isAnimatingRadar) 
    {
        self.isAnimatingRadar = NO;
        [self removeAllRadarPoints];
        [self.radarScan removeFromSuperview];
        self.radarScan = nil;
        [self.timerForRadar invalidate];
        self.timerForRadar = nil;
        self.resultsController = nil;
    }
    else 
    {
        self.resultsController = nil;
    }
    return YES;
}

- (void)removeAllRadarPoints
{
    for (LARDisplayObject *each in self.reachedDisplayObjects)
    {
        [each.view removeFromSuperview];
    }
    
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
    
    self.reachedDisplayObjects = nil;
    self.firstRingDisplayObjects = nil;
    self.secondRingDisplayObjects = nil;
    self.thirdRingDisplayObjects = nil;
    self.lastRingDisplayObjects = nil;
}

@end
