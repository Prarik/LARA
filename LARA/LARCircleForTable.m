//
//  LARCircleForTable.m
//  LARA
//
//  Created by Brian Thomas on 8/15/12.
//  Copyright (c) 2012 Endozemedia. All rights reserved.
//

#import "LARCircleForTable.h"

@implementation LARCircleForTable

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
    
    UIColor *currentColor = [UIColor lightGrayColor];
    CGContextSetStrokeColorWithColor(context, currentColor.CGColor);

    CGContextAddEllipseInRect(context, CGRectMake(2, 2, 36, 36));
    
    CGContextDrawPath(context, kCGPathFillStroke);
}


@end
