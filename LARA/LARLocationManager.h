//
//  LARLocationManager.h
//  LARA
//
//  Created by Brian Thomas on 8/9/12.
//  Copyright (c) 2012 Endozemedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LARLocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLHeading *currentHeading;
@property (nonatomic) CLLocationAccuracy currentVerticalAccuracy;
@property (nonatomic) CLLocationAccuracy currentHorizontalAccuracy;
@property (nonatomic) BOOL hasInitializedPosition;

@end
