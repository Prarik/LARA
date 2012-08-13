//
//  LARDisplayObject.h
//  LARA
//
//  Created by Brian Thomas on 8/9/12.
//  Copyright (c) 2012 Endozemedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LARDisplayObject : UIView

@property (nonatomic, strong) UIView *icon;
@property (nonatomic, strong) NSString *iconType;
@property (nonatomic, strong) UILabel *ticker;
@property (nonatomic, assign) NSNumber *angleFromNorth;
@property (nonatomic) BOOL isFadingIn;

@end
