//
//  LARAppDelegate.m
//  LARA
//
//  Created by Chris Stephan on 6/25/12.
//  Copyright (c) 2012 Endozemedia. All rights reserved.
//

#import "LARAppDelegate.h"
#import "LARRadarViewController.h"
#import "LARRadarPointsViewController.h"
#import "LARLocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import "DDLog.h"

@implementation LARAppDelegate

@synthesize window = _window;
@synthesize rootController = _rootController;
@synthesize radarController = _radarController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize locationManager = _locationManager;

static const int ddLogLevel = LOG_LEVEL_ERROR;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self setUpLocationManager];
    
    LARRadarViewController *radarController = [[LARRadarViewController alloc] init];
    self.radarController = radarController;
    LARRadarPointsViewController *radarPoints = [[LARRadarPointsViewController alloc] initWithStyle:UITableViewStylePlain];
    radarController.context = self.managedObjectContext;
    radarPoints.context = self.managedObjectContext;
    radarPoints.manager = self.locationManager;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:radarPoints];
    navController.navigationBar.tintColor = [UIColor whiteColor];
    navController.navigationBar.barTintColor = [UIColor blackColor];
        
    self.rootController = [[UITabBarController alloc] init];
    self.rootController.delegate = self;
    
    NSArray *controllerArray = [[NSArray alloc] initWithObjects:radarController, navController, nil];
    
    self.rootController.viewControllers = controllerArray;
    self.rootController.tabBar.backgroundColor = [UIColor blackColor];
    self.rootController.tabBar.barTintColor = [UIColor blackColor];
    self.rootController.tabBar.tintColor = [UIColor whiteColor];
    
    //[self.window addSubview:self.rootController.view];
    self.window.rootViewController = _rootController;
    
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)setUpLocationManager
{
    self.locationManager = [[LARLocationManager alloc] init];
    self.locationManager.manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if ([self.rootController selectedViewController] == self.radarController) 
    {
        [self.radarController tabBarWillMakeInactive];
    }
    [self.rootController setSelectedViewController:self.radarController];
    [self.radarController viewDidAppear:NO];
    [self.radarController authorizeCoreLocation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"LARA" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"LARA.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {

        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - UITabBarControllerDelegate Methods

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if (self.radarController.isPreparedToSwitchViews)
    {
        if ((viewController == self.radarController) && (tabBarController.selectedViewController != self.radarController))
        {
            [self.radarController tabBarDidMakeActive];
        }
        else
        {
            if (viewController != self.radarController)
            {
                [self.radarController tabBarWillMakeInactive];
            }
        }
        return YES;
    }
    else 
    {
        CLAuthorizationStatus authorizationStat = [CLLocationManager authorizationStatus];
        if (authorizationStat == kCLAuthorizationStatusDenied || authorizationStat == kCLAuthorizationStatusNotDetermined || authorizationStat == kCLAuthorizationStatusRestricted) 
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please authorize location services to continue." delegate:self cancelButtonTitle:@"OK." otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please wait until the desired location accuracy is initialized." delegate:self cancelButtonTitle:@"OK." otherButtonTitles:nil];
            [alert show];
        }
        return NO;
    }
}

//- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
//{
//    if ((viewController == self.radarController) && (tabBarController.selectedViewController != viewController))
//    {
//        [self.radarController tabBarDidMakeActive];
//    }
//    else 
//    {
//        // do nada
//    }
//}

@end
