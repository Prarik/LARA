//
//  LARAddPointViewController.h
//  LARA
//
//  Created by Brian Thomas on 8/15/12.
//  Copyright (c) 2012 Endozemedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackedObject.h"

@class LARDisplayObject;
@protocol LARAddPointViewDelegate;

@interface LARAddPointViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *tickerTextField;
@property (strong, nonatomic) IBOutlet UIView *iconPresentationArea;
@property (weak, nonatomic) IBOutlet UIButton *addItemButton;
@property (strong, nonatomic) LARDisplayObject *currentDisplayObject;
@property (assign, nonatomic) id<LARAddPointViewDelegate> delegate;

@property (strong, nonatomic) NSString *pointName;
@property (strong, nonatomic) NSString *pointTicker;
@property (strong, nonatomic) NSString *pointShape;
@property (strong, nonatomic) NSString *pointColor;

- (IBAction)shapeSegmentedSelector:(id)sender;
- (IBAction)colorSegmentedSelector:(id)sender;
- (IBAction)nameDidEndEdit:(id)sender;
- (IBAction)tickerDidEndEdit:(id)sender;
- (IBAction)addItemButtonPressed;
- (IBAction)backgroundTap:(id)sender;


@end


@protocol LARAddPointViewDelegate <NSObject>

- (void)addPointForName:(NSString *)pointName ticker:(NSString *)pointTicker shape:(NSString *)pointShape color:(NSString *)pointColor;

@end