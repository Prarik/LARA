//
//  TrackedObject.h
//  LARA
//
//  Created by Brian Thomas on 8/16/12.
//  Copyright (c) 2012 Endozemedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TrackedObject : NSManagedObject

@property (nonatomic, retain) NSString * iconImageColor;
@property (nonatomic, retain) NSString * iconImageType;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lon;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSNumber * viewPosition;
@property (nonatomic, retain) NSNumber * shouldDisplay;

@end
