//
//  LARRadarPointsViewController.m
//  LARA
//
//  Created by Chris Stephan on 6/25/12.
//  Copyright (c) 2012 Endozemedia. All rights reserved.
//

#import "LARRadarPointsViewController.h"
#import "TrackedObject.h"
#import "LARRadarPointCell.h"
#import "LARAddPointViewController.h"
#import "LARCircleIcon.h"
#import "LARSquareIcon.h"
#import "LARTriangleIcon.h"
#import "LARLocationManager.h"
#import "LARRadarPointCell.h"
#import "DDLog.h"

#define kTitle @"Points"

#define kCircle @"circle"
#define kSquare @"square"
#define kTriangle @"triangle"

#define kHide @"Hide"
#define kDisplay @"Display"

#define kSortKey @"viewPosition"

#define kRowHeight 92

#define kIconRect CGRectMake(0, 0, 16, 16)

#define kTrackedObject @"TrackedObject"

#define kLARPointsCell @"LARRadarPointCell"
#define kCellIdentifier @"RadarPointCell"
#define kLARAddPointViewController @"LARAddPointViewController"

@interface LARRadarPointsViewController ()

- (IBAction)cellUpdateButtonTapped:(id)sender;
- (IBAction)cellDisplayRemoveButtonTapped:(id)sender;
- (void)addButtonPressed;
- (UIView *)iconForCellOfTrackedObject:(TrackedObject *)currentObject;

@end

@implementation LARRadarPointsViewController
@synthesize context = _context;
@synthesize fetchResults = _fetchResults;
@synthesize addItemController;
@synthesize manager = _manager;
@synthesize tabBarItem;

static const int ddLogLevel = LOG_LEVEL_ERROR;

#pragma mark - User Interaction Methods

- (void)addButtonPressed
{
    if (self.addItemController == nil) 
    {
        self.addItemController = [[LARAddPointViewController alloc] initWithNibName:kLARAddPointViewController bundle:nil];
        self.addItemController.delegate = self;
    }
    [self.navigationController pushViewController:self.addItemController animated:YES];
}

#pragma mark - Core Data

- (void)getData
{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTrackedObject inManagedObjectContext:self.context];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:kSortKey ascending:YES];
    [fetch setFetchBatchSize:20];
    [fetch setEntity:entity];
    [fetch setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSFetchedResultsController *resultsController = [[NSFetchedResultsController alloc]
                                                     initWithFetchRequest:fetch
                                                     managedObjectContext:self.context
                                                     sectionNameKeyPath:nil
                                                     cacheName:nil];
    
    self.fetchResults = resultsController;
    self.fetchResults.delegate = self;
    
    NSError *anyError = nil;
    [self.fetchResults performFetch:&anyError];
    
    self.trackedObjectsArray = [[self.fetchResults fetchedObjects] mutableCopy];
}

#pragma mark - Inherited

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
        self.title = kTitle;
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:kTitle image:[UIImage imageNamed:@"PointsTabBarIcon.png"] tag:2];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    [self getData];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                              target:self
                                              action:@selector(addButtonPressed)];
    
    [self.tableView setRowHeight:kRowHeight];
    
    [self.tableView setBackgroundColor:[UIColor blackColor]];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    /*NSInteger counted = [[self.fetchResults sections] count];
    return counted;*/
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchResults sections] objectAtIndex:section];
    NSInteger rowsInSection = [sectionInfo numberOfObjects];
    
    return rowsInSection;*/
    
    return [self.trackedObjectsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = kCellIdentifier;
    static BOOL nibsRegistered = NO;
    
    if (!nibsRegistered)
    {
        UINib *nib = [UINib nibWithNibName:kLARPointsCell bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
        nibsRegistered = YES;
    }
    
    LARRadarPointCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[LARRadarPointCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.showsReorderControl = YES;
    }
    
    // Configure the cell...
    TrackedObject *currentTrackedObject = [self.trackedObjectsArray objectAtIndex:indexPath.row];
    cell.nameLabel.text = currentTrackedObject.name;
    cell.subLabel.text = currentTrackedObject.subtitle;
        
    // Set up the custom backgrounds for the buttons
    UIImage *buttonImage = [UIImage imageNamed:@"GrayButton.png"];
    UIImage *stretchableImage = [buttonImage stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    [cell.updateButton setBackgroundImage:stretchableImage forState:UIControlStateNormal];
    [cell.removeButton setBackgroundImage:stretchableImage forState:UIControlStateNormal];
    
    // Add the appropriate selectors to the buttons
    [cell.updateButton addTarget:self action:@selector(cellUpdateButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cell.removeButton addTarget:self action:@selector(cellDisplayRemoveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([currentTrackedObject.shouldDisplay boolValue]) 
    {
        [cell.removeButton setTitle:kHide forState:UIControlStateNormal];
    }
    else 
    {
        [cell.removeButton setTitle:kDisplay forState:UIControlStateNormal];
    }
    
    // Remove the old icon
    [[cell viewWithTag:4] removeFromSuperview];
    
    // Create a new icon
    UIView *icon = [self iconForCellOfTrackedObject:currentTrackedObject];
    [icon setTag:4];
    
    // Add icon to cell
    [cell.iconView addSubview:icon];
    
    //Set the background view
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PointCellBackground@2x.png"]];
    
    return cell;
}

- (UIView *)iconForCellOfTrackedObject:(TrackedObject *)currentObject
{
    UIView *icon;
    
    if ([currentObject.iconImageType isEqualToString:kCircle])
    {
        icon = [[LARCircleIcon alloc] initWithFrame:kIconRect andColor:currentObject.iconImageColor];
    }
    else if ([currentObject.iconImageType isEqualToString:kSquare])
    {
        icon = [[LARSquareIcon alloc] initWithFrame:kIconRect andColor:currentObject.iconImageColor];
    }
    else if ([currentObject.iconImageType isEqualToString:kTriangle])
    {
        icon = [[LARTriangleIcon alloc] initWithFrame:kIconRect andColor:currentObject.iconImageColor];
    }
    
    return icon;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // The tracked object to delete
        TrackedObject *trackedObject = [self.trackedObjectsArray objectAtIndex:indexPath.row];
        
        // Delete the row from the data source
        [self.context deleteObject:trackedObject];
        
        // Delete the row from the tracked objects array which populates the table view
        [self.trackedObjectsArray removeObject:trackedObject];
        
        // Delete the row from the table view
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
        
    [self.tableView endUpdates];
    
    [self save];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;
{    
    // Grab the item we're moving.
    TrackedObject *trackedObject = [self.trackedObjectsArray objectAtIndex:sourceIndexPath.row];
    
    // Remove the object we're moving from the array.
    [self.trackedObjectsArray removeObject:trackedObject];
    
    // Now re-insert it at the destination.
    [self.trackedObjectsArray insertObject:trackedObject atIndex:[destinationIndexPath row]];
    
    // All of the objects are now in their correct order. Update each
    // object's displayOrder field by iterating through the array.
    int i = 0;
    for (TrackedObject *each in self.trackedObjectsArray)
    {
        each.viewPosition = [NSNumber numberWithInt:i++];
    }

    [self save];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   
    return;
}

/*#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationTop];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                  withRowAnimation:UITableViewRowAnimationTop];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                  withRowAnimation:UITableViewRowAnimationTop];
            
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section]
                          withRowAnimation:UITableViewRowAnimationTop];
            break;
        case NSFetchedResultsChangeUpdate:
        {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            LARRadarPointCell *larCell = (LARRadarPointCell *)cell;
            
            TrackedObject *trackedObject = [controller objectAtIndexPath:indexPath];
            
            larCell.nameLabel.text = trackedObject.name;
            larCell.subLabel.text = trackedObject.subtitle;       
        }
            break;
        default:
            break;
    }
}*/

- (void)save
{
    
    NSError *error;
    
    [self.context save:&error];
    
    if(error)
    {
        DDLogError(@"ERROR: %@", [error localizedDescription]);
    }
    
}

#pragma mark - LARAddItemDelegate Methods

- (void)addPointForName:(NSString *)pointName ticker:(NSString *)pointTicker shape:(NSString *)pointShape color:(NSString *)pointColor
{
    CLLocation *gottenLocation = self.manager.currentLocation;
    TrackedObject *trackedObject = [NSEntityDescription insertNewObjectForEntityForName:kTrackedObject inManagedObjectContext:self.context];
    trackedObject.name = pointName;
    trackedObject.subtitle = pointTicker;
    trackedObject.lat = [NSNumber numberWithDouble:gottenLocation.coordinate.latitude];
    trackedObject.lon = [NSNumber numberWithDouble:gottenLocation.coordinate.longitude];
    trackedObject.iconImageColor = pointColor;
    trackedObject.iconImageType = pointShape;
    trackedObject.shouldDisplay = [NSNumber numberWithBool:YES];
    
    // Set the new tracked object's view position to be the last row
    trackedObject.viewPosition = [NSNumber numberWithInt:[self.trackedObjectsArray count]];
    
    // Create a new index path for the new row to be inserted
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.trackedObjectsArray count] inSection:0];
    
    //Add the tracked object to the tracked objects array so that the table view has the new row
    [self.trackedObjectsArray addObject:trackedObject];
        
    [self.tableView beginUpdates];
    
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    
    [self.tableView endUpdates];
        
    [self save];

    self.addItemController = nil;
}

#pragma mark - Manipulating TableViewCell With Tags

- (IBAction)cellUpdateButtonTapped:(id)sender
{
    // Find the row of the button tapped.
    UIButton *senderButton = (UIButton *)sender;
    
    UITableViewCell *buttonCell = (UITableViewCell *)[[senderButton superview] superview];
    NSIndexPath *indexPathForButton = [self.tableView indexPathForCell:buttonCell];
    // Get the tracked Object associated with it and update it's location.
    TrackedObject *trackedObject = [self.trackedObjectsArray objectAtIndex:indexPathForButton.row];
    DDLogInfo(@"%@", trackedObject.name);
    CLLocation *gottenLocation = self.manager.currentLocation;

    trackedObject.lat = [NSNumber numberWithFloat:gottenLocation.coordinate.latitude];
    trackedObject.lon = [NSNumber numberWithFloat:gottenLocation.coordinate.longitude];
    [self save];
    
    // Display the accuracy to the user.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Updated"
                                                    message:[NSString stringWithFormat:@"With an accuracy of %d meters",
                                                             (int)self.manager.currentHorizontalAccuracy]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)cellDisplayRemoveButtonTapped:(id)sender
{
    UIButton *senderButton = (UIButton *)sender;
    UITableViewCell *buttonCell = (UITableViewCell *)[[senderButton superview] superview];
    NSIndexPath *indexPathForButton = [self.tableView indexPathForCell:buttonCell];
    TrackedObject *trackedObject = [self.trackedObjectsArray objectAtIndex:indexPathForButton.row];
    if ([trackedObject.shouldDisplay boolValue]) 
    {
        trackedObject.shouldDisplay = [NSNumber numberWithBool:NO];
    }
    else 
    {
        trackedObject.shouldDisplay = [NSNumber numberWithBool:YES];
    }
    [self save];
    [self.tableView reloadData];
}

@end
