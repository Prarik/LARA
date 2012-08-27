//
//  LARLocationManager.m
//  LARA
//
//  Created by Brian Thomas on 8/9/12.
//  Copyright (c) 2012 Endozemedia. All rights reserved.
//

#import "LARLocationManager.h"

@implementation LARLocationManager

@synthesize manager, currentLocation, currentHeading, hasInitializedPosition, hasInitivializedAuthorization, currentVerticalAccuracy, currentHorizontalAccuracy;

- (id) init
{
    if (self = [super init]) 
    {
        self.manager = [[CLLocationManager alloc] init];
        self.manager.delegate = self;
        self.hasInitializedPosition = NO;
        self.hasInitivializedAuthorization = NO;
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.currentLocation = newLocation;
    self.currentVerticalAccuracy = newLocation.verticalAccuracy;
    self.currentHorizontalAccuracy = newLocation.horizontalAccuracy;
    
    //NSLog(@"horizontal location accuracy: %f", newLocation.horizontalAccuracy);
    //NSLog(@"%u", (int)newLocation.horizontalAccuracy);
    
    if ((newLocation.verticalAccuracy < 40) & (newLocation.horizontalAccuracy < 40) & !hasInitializedPosition)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"locationInitialized" object:self];
        self.hasInitializedPosition = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    self.currentHeading = newHeading;
    //NSLog(@"%f", newHeading.magneticHeading);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (!hasInitivializedAuthorization)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"serviceStatusSet" object:self];
        self.hasInitivializedAuthorization = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return YES;
}

- (void)resetInitializer
{
    self.hasInitializedPosition = NO;
}

@end
