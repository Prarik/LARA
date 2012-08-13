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
    }
    return self;
}

/*
- (void)drawRect:(CGRect)rect
{
 
}
*/

@end
