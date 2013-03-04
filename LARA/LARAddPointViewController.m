//
//  LARAddPointViewController.m
//  LARA
//
//  Created by Brian Thomas on 8/15/12.
//  Copyright (c) 2012 Endozemedia. All rights reserved.
//

#import "LARAddPointViewController.h"
#import "LARDisplayObject.h"
#import <QuartzCore/QuartzCore.h>

#define kCircle @"circle"
#define kSquare @"square"
#define kTriangle @"triangle"

#define kRed @"red"
#define kBlue @"blue"
#define kCyan @"cyan"
#define kYellow @"yellow"

#define kMaxTickerLength 3

@interface LARAddPointViewController ()

- (void)removeOldDisplayObject;
- (void)updateDisplayObject;

@end

@implementation LARAddPointViewController
@synthesize delegate;
@synthesize nameTextField;
@synthesize tickerTextField;
@synthesize iconPresentationArea;
@synthesize addItemButton;
@synthesize currentDisplayObject;
@synthesize pointName, pointTicker, pointShape, pointColor;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tickerTextField.delegate = self;
    self.pointShape = kSquare;
    self.pointColor = kRed;
    [self updateDisplayObject];
    // Do any additional setup after loading the view from its nib.
    
    //Set the background image
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"PointCellBackground@2x.png"]];
    
    // Set up the custom background for the add item button
    UIImage *buttonImage = [UIImage imageNamed:@"GrayButton.png"];
    UIImage *stretchableImage = [buttonImage stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    [self.addItemButton setBackgroundImage:stretchableImage forState:UIControlStateNormal];
    CALayer *layer = self.addItemButton.layer;
    layer.borderColor = [UIColor whiteColor].CGColor;
    layer.borderWidth = 2.0;
}

- (void)viewDidUnload
{
    [self setNameTextField:nil];
    [self setTickerTextField:nil];
    [self setIconPresentationArea:nil];
    [self setAddItemButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)removeOldDisplayObject
{
    [self.currentDisplayObject.view removeFromSuperview];
    self.currentDisplayObject = nil;
}

- (void)updateDisplayObject
{
    self.currentDisplayObject = [[LARDisplayObject alloc] initWithShape:self.pointShape andColor:self.pointColor];
    self.currentDisplayObject.ticker.text = self.pointTicker;
    self.currentDisplayObject.view.frame = CGRectMake(150, 45, 20, 29);
    [self.iconPresentationArea addSubview:self.currentDisplayObject.view];
}

- (IBAction)shapeSegmentedSelector:(id)sender 
{
    NSInteger choice = [sender selectedSegmentIndex];
    switch (choice)
    {
        case 0:
            self.pointShape = kSquare;
            break;
        case 1:
            self.pointShape = kCircle;
            break;
        case 2:
            self.pointShape = kTriangle;
            break;
        default:
            self.pointShape = kSquare;
            break;
    }
    [self removeOldDisplayObject];
    [self updateDisplayObject];
}

- (IBAction)colorSegmentedSelector:(id)sender 
{
    NSInteger choice = [sender selectedSegmentIndex];
    switch (choice)
    {
        case 0:
            self.pointColor = kRed;
            break;
        case 1:
            self.pointColor = kBlue;
            break;
        case 2:
            self.pointColor = kCyan;
            break;
        case 3:
            self.pointColor = kYellow;
            break;
        default:
            self.pointColor = kRed;
            break;
    }
    [self removeOldDisplayObject];
    [self updateDisplayObject];
}

- (IBAction)nameDidEndEdit:(id)sender 
{
    [self backgroundTap:sender];
}

- (IBAction)tickerDidEndEdit:(id)sender 
{
    [self backgroundTap:sender];
}

- (IBAction)addItemButtonPressed 
{
    if (([pointName length] > 0) & ([pointTicker length] > 0)) 
    {
        [self.navigationController popViewControllerAnimated:YES];
        
        [delegate addPointForName:self.pointName ticker:self.pointTicker shape:self.pointShape color:self.pointColor];
    }
    else 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!"
                                                        message:@"You are missing vital information!"
                                                       delegate:self cancelButtonTitle:@"OK."
                                              otherButtonTitles:nil];
        [alert show];
    }
}


#pragma -
#pragma UITextField Delegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string 
{
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    return newLength <= kMaxTickerLength;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

- (IBAction)backgroundTap:(id)sender
{
    self.pointName = self.nameTextField.text;
    self.pointTicker = self.tickerTextField.text;
    [self removeOldDisplayObject];
    [self updateDisplayObject];
    [self.nameTextField resignFirstResponder];
    [self.tickerTextField resignFirstResponder];
}

@end
