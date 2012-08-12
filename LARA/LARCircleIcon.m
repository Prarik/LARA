//
//  LARCircleIcon.m
//  LARA
//
//  Created by Brian Thomas on 8/10/12.
//  Copyright (c) 2012 Endozemedia. All rights reserved.
//

#import "LARCircleIcon.h"

@implementation LARCircleIcon

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
 
    CGContextSetLineWidth(context, 2.0);
    
    UIColor *drawColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:self.alpha];
    CGContextSetStrokeColorWithColor(context, drawColor.CGColor);
 
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    
    CGContextAddEllipseInRect(context, CGRectMake(0, 0, 15, 15));
    CGContextDrawPath(context, kCGPathFillStroke);
}


@end
