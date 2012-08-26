//
//  LARDisplayObject.m
//  LARA
//
//  Created by Brian Thomas on 8/9/12.
//  Copyright (c) 2012 Endozemedia. All rights reserved.
//

#import "LARDisplayObject.h"
#import "LARCircleIcon.h"
#import "LARSquareIcon.h"
#import "LARTriangleIcon.h"

@interface LARDisplayObject ()

@end

@implementation LARDisplayObject

@synthesize icon, iconType, ticker, angleFromNorth, isFadingIn;

- (id)initWithShape:(NSString *)shapeName andColor:(NSString *)colorName
{
    self = [super init];
    if (self)
    {
        // Initialization code
        if ([shapeName isEqualToString:@"circle"]) 
        {
            self.icon = [[LARCircleIcon alloc] initWithFrame:CGRectMake(3, 0, 16, 16) andColor:colorName];
            [self.view addSubview:self.icon];
        }
        else if ([shapeName isEqualToString:@"square"])
        {
            self.icon = [[LARSquareIcon alloc] initWithFrame:CGRectMake(3, 0, 16, 16) andColor:colorName];
            [self.view addSubview:self.icon];
        }
        else if ([shapeName isEqualToString:@"triangle"])
        {
            self.icon = [[LARTriangleIcon alloc] initWithFrame:CGRectMake(3, 0, 16, 16) andColor:colorName];
            [self.view addSubview:self.icon];
        }
        self.ticker = [[UILabel alloc] initWithFrame:CGRectMake(0, 17, 23, 12)];
        self.ticker.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:self.ticker];
        self.ticker.textColor = [UIColor whiteColor];
        self.ticker.backgroundColor = [UIColor clearColor];
        NSArray *fontArray = [UIFont fontNamesForFamilyName:@"American Typewriter"];
        self.ticker.font = [UIFont fontWithName:[fontArray objectAtIndex:3] size:11];
        
        self.ticker.textColor = [UIColor whiteColor];
        self.ticker.textAlignment = UITextAlignmentCenter;
        self.angleFromNorth = [NSNumber numberWithDouble:0];
        [self.view setNeedsDisplay];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        // Initialization code
        self.icon = [[LARCircleIcon alloc] initWithFrame:CGRectMake(2, 0, 16, 16)];
        [self.view addSubview:self.icon];
        self.ticker = [[UILabel alloc] initWithFrame:CGRectMake(0, 17, 20, 12)];
        [self.view addSubview:self.ticker];
        self.ticker.textColor = [UIColor whiteColor];
        self.ticker.backgroundColor = [UIColor clearColor];
        self.ticker.font = [UIFont systemFontOfSize:7];
        self.ticker.textAlignment = UITextAlignmentCenter;
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
