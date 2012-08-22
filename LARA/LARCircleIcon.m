//
//  LARCircleIcon.m
//  LARA
//
//  Created by Brian Thomas on 8/10/12.
//  Copyright (c) 2012 Endozemedia. All rights reserved.
//

#import "LARCircleIcon.h"

@implementation LARCircleIcon

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
 
    CGContextSetLineWidth(context, 2.0);
    
    CGRect currentEnclosingRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGContextClearRect(context, currentEnclosingRect);
    
    UIColor *currentColor = self.drawColor;
    CGContextSetStrokeColorWithColor(context, currentColor.CGColor);
 
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    
    CGContextAddEllipseInRect(context, CGRectMake(1, 1, 14, 14));
    CGContextDrawPath(context, kCGPathFillStroke);
}


@end
