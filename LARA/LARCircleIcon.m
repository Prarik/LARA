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
        self.opaque = NO;
        self.alpha = 1;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
 
    CGContextSetLineWidth(context, 2.0);
    
    CGRect currentEnclosingRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGContextClearRect(context, currentEnclosingRect);
    
    UIColor *drawColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:self.alpha];
    CGContextSetStrokeColorWithColor(context, drawColor.CGColor);
 
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    
    CGContextAddEllipseInRect(context, CGRectMake(0, 0, 16, 16));
    CGContextDrawPath(context, kCGPathFillStroke);
}


@end
