//
//  LARRadarScan.m
//  LARA
//
//  Created by Brian Thomas on 6/27/12.
//  Copyright (c) 2012 Endozemedia. All rights reserved.
//

#import "LARRadarScan.h"

@implementation LARRadarScan

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 2, 2);
    
    CGContextClearRect(context, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
    
    UIColor *drawColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.4];
    CGContextSetStrokeColorWithColor(context, drawColor.CGColor);
    
    CGContextSetLineWidth(context, 2.5);
    CGContextStrokeEllipseInRect(context, CGRectMake(1, 1, self.frame.size.width-2, self.frame.size.height-2));
    
    CGContextSetLineWidth(context, 1.7);
    CGContextStrokeEllipseInRect(context, CGRectMake(4.4, 4.4, self.frame.size.width-8.8, self.frame.size.height-8.8));
    
    CGContextSetLineWidth(context, 1.0);
    CGContextStrokeEllipseInRect(context, CGRectMake(7.3, 7.3, self.frame.size.width-14.6, self.frame.size.height-14.6));
    
    CGContextSetLineWidth(context, 0.5);
    CGContextStrokeEllipseInRect(context, CGRectMake(10, 10, self.frame.size.width-20, self.frame.size.height-20));
    
    CGContextFillPath(context);
}


@end
