//
//  LARShapeIcon.m
//  LARA
//
//  Created by Brian Thomas on 8/16/12.
//  Copyright (c) 2012 Endozemedia. All rights reserved.
//

#import "LARShapeIcon.h"

@implementation LARShapeIcon

@synthesize drawColor;

- (id) initWithFrame:(CGRect)frame andColor:(NSString *)selectedColor
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.opaque = NO;
        self.alpha = 1;
        if ([selectedColor isEqualToString:@"red"]) 
        {
            self.drawColor = [UIColor redColor];
        }
        else if ([selectedColor isEqualToString:@"blue"]) 
        {
            self.drawColor = [UIColor blueColor];
        }
        else if ([selectedColor isEqualToString:@"yellow"]) 
        {
            self.drawColor = [UIColor yellowColor];
        }
        else if ([selectedColor isEqualToString:@"cyan"]) 
        {
            self.drawColor = [UIColor cyanColor];
        }
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.opaque = NO;
        self.alpha = 1;
        self.drawColor = [UIColor redColor];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
