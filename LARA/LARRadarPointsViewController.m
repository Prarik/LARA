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
#define kTitle @"Points"

@interface LARRadarPointsViewController ()

@end

@implementation LARRadarPointsViewController
@synthesize context = _context;
@synthesize fetchResults = _fetchResults;

#pragma mark - User Interaction Methods
- (void)addItem
{
//    NSLog(@"%@", @"pressed the add button");
    TrackedObject *trackedObject = [NSEntityDescription insertNewObjectForEntityForName:@"TrackedObject" inManagedObjectContext:self.context];
    trackedObject.name = @"Name";
    trackedObject.subtitle = @"SUB";
    trackedObject.lat = [NSNumber numberWithDouble:41.155484];
    trackedObject.lon = [NSNumber numberWithDouble:-85.138152];
    trackedObject.iconImageColor = @"RED";
    trackedObject.iconImageType = @"START";
//    trackedObject.shouldDisplay = YES;
    
    [self save];
}

- (void)editItem
{
    
}

#pragma mark - Core Data

- (void)getData
{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TrackedObject" inManagedObjectContext:self.context];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetch setFetchBatchSize:20];
    [fetch setEntity:entity];
    [fetch setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSFetchedResultsController *resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetch managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    
    self.fetchResults = resultsController;
    self.fetchResults.delegate = self;
    
    NSError *anyError = nil;
    [self.fetchResults performFetch:&anyError];
}

#pragma mark - Inherited

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
        self.title = kTitle;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    [self getData];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem)];
    
    [self.tableView setRowHeight:92];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSInteger counted = [[self.fetchResults sections] count];
    return counted;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchResults sections] objectAtIndex:section];
    NSInteger rowsInSection = [sectionInfo numberOfObjects];
    
    return rowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"RadarPointsCell";
    static BOOL nibsRegistered = NO;
    
    if (!nibsRegistered)
    {
        UINib *nib = [UINib nibWithNibName:@"LARRadarPointCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
        nibsRegistered = YES;
    }
    
    LARRadarPointCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    
    if (cell == nil) 
    {
        cell = [[LARRadarPointCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Configure the cell...
    TrackedObject *currentTrackedObject = [self.fetchResults objectAtIndexPath:indexPath];
    cell.nameLabel.text = currentTrackedObject.name;
    cell.subLabel.text = currentTrackedObject.subtitle;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source
        [self.context deleteObject: [self.fetchResults objectAtIndexPath:indexPath]];
        [self save];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

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
}

- (void)save
{
    
    NSError *error;
    
    [self.context save:&error];
    
    if(error)
    {
        NSLog(@"ERROR: %@", [error localizedDescription]);
    }
    
}

@end
