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

@synthesize icon, iconType, ticker, angleFromNorth, isFadingIn;

- (id)init
{
    self = [super init];
    if (self)
    {
        // Initialization code
        self.icon = [[LARCircleIcon alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
        [self.view addSubview:self.icon];
        self.ticker = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, 16, 10)];
        [self.view addSubview:self.ticker];
        self.ticker.textColor = [UIColor whiteColor];
        self.angleFromNorth = [NSNumber numberWithDouble:0];
        [self.view setNeedsDisplay];
    }
    return self;
}

/*
- (void)drawRect:(CGRect)rect
{
 
}
*/

@end
