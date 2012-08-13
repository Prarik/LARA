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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.opaque = NO;
        self.alpha = 1;
        self.icon = [[LARCircleIcon alloc] init];
        self.ticker = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, 16, 10)];
        [self addSubview:self.ticker];
        self.ticker.textColor = [UIColor whiteColor];
    }
    return self;
}

/*
- (void)drawRect:(CGRect)rect
{
 
}
*/

@end
