//
//  LARTriangleIcon.h
//  LARA
//
//  Created by Brian Thomas on 8/15/12.
//  Copyright (c) 2012 Endozemedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LARTriangleIcon : UIView

@property (nonatomic, strong) UIColor *drawColor;

- (id)initWithFrame:(CGRect)frame andColor:(NSString *)selectedColor;

@end
