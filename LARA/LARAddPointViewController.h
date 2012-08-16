//
//  LARAddPointViewController.h
//  LARA
//
//  Created by Brian Thomas on 8/15/12.
//  Copyright (c) 2012 Endozemedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LARDisplayObject;
@protocol LARAddPointViewDelegate;

@interface LARAddPointViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *tickerTextField;
@property (strong, nonatomic) IBOutlet UIView *iconPresentationArea;
@property (strong, nonatomic) LARDisplayObject *currentDisplayObject;
@property (assign, nonatomic) id<LARAddPointViewDelegate> delegate;

@property (strong, nonatomic) NSString *thisName;
@property (strong, nonatomic) NSString *thisTicker;
@property (strong, nonatomic) NSString *thisShape;
@property (strong, nonatomic) NSString *thisColor;

- (IBAction)shapeSegmentedSelector:(id)sender;
- (IBAction)colorSegmentedSelector:(id)sender;
- (IBAction)nameDidEndEdit:(id)sender;
- (IBAction)tickerDidEndEdit:(id)sender;
- (IBAction)addItemButtonPressed;

@end


@protocol LARAddPointViewDelegate <NSObject>

- (void)addUsersItem;

@end