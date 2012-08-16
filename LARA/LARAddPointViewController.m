//
//  LARAddPointViewController.m
//  LARA
//
//  Created by Brian Thomas on 8/15/12.
//  Copyright (c) 2012 Endozemedia. All rights reserved.
//

#import "LARAddPointViewController.h"
#import "LARDisplayObject.h"

@interface LARAddPointViewController ()

- (void)removeOldDisplayObject;
- (void)updateDisplayObject;

@end

@implementation LARAddPointViewController
@synthesize delegate;
@synthesize nameTextField;
@synthesize tickerTextField;
@synthesize iconPresentationArea;
@synthesize currentDisplayObject;
@synthesize thisName, thisTicker, thisShape, thisColor;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tickerTextField.delegate = self;
    self.thisShape = @"square";
    self.thisColor = @"red";
    [self updateDisplayObject];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setNameTextField:nil];
    [self setTickerTextField:nil];
    [self setIconPresentationArea:nil];
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
    self.currentDisplayObject = [[LARDisplayObject alloc] initWithShape:self.thisShape andColor:self.thisColor];
    self.currentDisplayObject.ticker.text = self.thisTicker;
    self.currentDisplayObject.view.frame = CGRectMake(150, 45, 20, 29);
    [self.iconPresentationArea addSubview:self.currentDisplayObject.view];
}

- (IBAction)shapeSegmentedSelector:(id)sender 
{
    NSInteger choice = [sender selectedSegmentIndex];
    switch (choice) {
        case 0:
            self.thisShape = @"square";
            break;
        case 1:
            self.thisShape = @"circle";
            break;
        case 2:
            self.thisShape = @"triangle";
            break;
        default:
            self.thisShape = @"square";
            break;
    }
    [self removeOldDisplayObject];
    [self updateDisplayObject];
}

- (IBAction)colorSegmentedSelector:(id)sender 
{
    NSInteger choice = [sender selectedSegmentIndex];
    switch (choice) {
        case 0:
            self.thisColor = @"red";
            break;
        case 1:
            self.thisColor = @"blue";
            break;
        case 2:
            self.thisColor = @"cyan";
            break;
        case 3:
            self.thisColor = @"yellow";
            break;
        default:
            self.thisColor = @"red";
            break;
    }
    [self removeOldDisplayObject];
    [self updateDisplayObject];
}

- (IBAction)nameDidEndEdit:(id)sender 
{
    self.thisTicker = self.tickerTextField.text;
    UILabel *thisLabel = (UILabel *)sender;
    self.thisName = thisLabel.text;
    [self removeOldDisplayObject];
    [self updateDisplayObject];
    [sender resignFirstResponder];
}

- (IBAction)tickerDidEndEdit:(id)sender 
{
    self.thisName = self.nameTextField.text;
    UILabel *thisLabel = (UILabel *)sender;
    self.thisTicker = thisLabel.text;
    [self removeOldDisplayObject];
    [self updateDisplayObject];
    [sender resignFirstResponder];
}

- (IBAction)addItemButtonPressed 
{
    if (([thisName length] > 0) & ([thisTicker length] > 0)) 
    {
        [self.navigationController popViewControllerAnimated:YES];
        [delegate addUsersItem];
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
    
    return newLength <= 4;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

@end
