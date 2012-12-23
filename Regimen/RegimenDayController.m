//
//  RegimenDayController.m
//  Regimen
//
//  Created by Sayem Islam on 10/3/12.
//  Copyright (c) 2012 HatTrick Labs, LLC. All rights reserved.
//

#import "RegimenDayController.h"
#import <QuartzCore/QuartzCore.h>

@implementation RegimenDayController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSError *error;
    
	if (![self.fetchedResultsController performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);
	}
    
    UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [leftRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [_tableView addGestureRecognizer:leftRecognizer];

    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [rightRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [_tableView addGestureRecognizer:rightRecognizer];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"calendar.png"] forState:UIControlStateNormal];
    button.frame=CGRectMake(0,0, 29, 29);
    [button addTarget:self action:@selector(locationButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithCustomView:button];

    UINavigationItem *nav = [self navigationItem];
    nav.leftBarButtonItem = btnDone;
    
    [self setNavTitle];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.fetchedResultsController = nil;
}

- (void)setNavTitle
{
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d"];
    NSString *date = [formatter stringFromDate:now];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    
    int goalsCount; int completedCount;

    if (_tableView.numberOfSections > 1) {
        goalsCount = [_tableView numberOfRowsInSection:0];
        completedCount = [_tableView numberOfRowsInSection:1];
    }
    else if (_tableView.numberOfSections == 1) {
        RegimenGoal *goal = [self.fetchedResultsController.fetchedObjects objectAtIndex:0];

        if (goal.completed.boolValue) {
            goalsCount = 0;
            completedCount = [_tableView numberOfRowsInSection:0];
        }
        else {
            goalsCount = [_tableView numberOfRowsInSection:0];
            completedCount = 0;
        }
    }
    else {
        goalsCount = 0;
        completedCount = 0;
    }
    
    if ([self.fetchedResultsController.fetchedObjects count] > 0) {
        NSInteger progress = ((float)completedCount / ((float)goalsCount + completedCount))*100;
        NSString *navTitle = [NSString stringWithFormat:@"%@  (%i%%)", date, progress];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:navTitle];
        
        NSInteger progressStart = date.length + 2;
        NSInteger progressEnd = navTitle.length - progressStart;
        float colorVal = ((float) progress / 100.0);
    
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, progressStart)];
        [str addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:18] range:NSMakeRange(0, progressStart)];
        
        if (progress < 50) {
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed: 1.0 green:colorVal blue: 0.0 alpha:1.0] range:NSMakeRange(progressStart, progressEnd)];
        }
        else if (progress < 75) {
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed: 0.75 green:colorVal blue: 0.0 alpha:1.0] range:NSMakeRange(progressStart, progressEnd)];
        }
        else {
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed: 0.5 green:colorVal blue: 0.0 alpha:1.0] range:NSMakeRange(progressStart, progressEnd)];
        }
        
        label.attributedText = str;
    }
    else {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:date];
        
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, date.length)];
        [str addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:18] range:NSMakeRange(0, date.length)];
        label.attributedText = str;
    }
    
    self.navigationItem.titleView = label;
    [label sizeToFit];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (void)configureCell:(RegimenCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    RegimenGoal *goal = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.label.text = goal.text;
    [cell formatCell:goal.completed.intValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RegimenGoal *goal = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"%@", goal.dateCreated];
    RegimenCell *cell = (RegimenCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[RegimenCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)goalViewControllerDidCancel:(GoalViewController *)controller
{
    [_tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)goalViewController:(GoalViewController *)controller didFinishAddingGoal:(NSString *)goal
{
    NSError *error;
    
    NSFetchRequest *dayRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *dayEntity = [NSEntityDescription entityForName:@"RegimenTime" inManagedObjectContext:_managedObjectContext];
    [dayRequest setEntity:dayEntity];
    NSPredicate *dayPredicate = [NSPredicate predicateWithFormat:@"duration == %@", @"Day"];
    [dayRequest setPredicate:dayPredicate];
    
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:dayRequest error:&error];
    RegimenTime *timeDay = [fetchedObjects objectAtIndex:0];
    
    RegimenGoal *addGoal = [NSEntityDescription insertNewObjectForEntityForName:@"RegimenGoal" inManagedObjectContext:_managedObjectContext];
    addGoal.text = goal;
    addGoal.dateCreated = [NSDate date];
    addGoal.time = timeDay;

    [addGoal.managedObjectContext save:&error];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self setNavTitle];
}

- (void)goalViewController:(GoalViewController *)controller didFinishEditingGoal:(RegimenGoal *)goal
{
    NSError *error;
    [_managedObjectContext save:&error];
    
    [self dismissViewControllerAnimated:YES completion:nil];    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *navigationController = segue.destinationViewController;
    GoalViewController *controller = (GoalViewController *)navigationController.topViewController;
    controller.delegate = self;
    
    if ([segue.identifier isEqualToString:@"EditGoal"]) {
        controller.goalToEdit = sender;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        RegimenCell *cell = (RegimenCell *)[_tableView cellForRowAtIndexPath:indexPath];
        cell.contentView.backgroundColor = [UIColor colorWithRed: 210.0 / 255 green:210.0 / 255 blue: 210.0 / 255 alpha:1.0];
        cell.label.backgroundColor = [UIColor colorWithRed: 210.0 / 255 green:210.0 / 255 blue: 210.0 / 255 alpha:1.0];
        
        RegimenGoal *goal = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"EditGoal" sender:goal];
    }
}

- (IBAction)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:_tableView];
    NSIndexPath *swipedIndexPath = [_tableView indexPathForRowAtPoint:location];
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:swipedIndexPath];

    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSError *error;
    
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
		[context deleteObject:[self.fetchedResultsController objectAtIndexPath:swipedIndexPath]];
        [context save:&error];
        
        for(UIView *subview in [cell subviews]) {
            if(subview.tag == 1) {
                [subview removeFromSuperview];
            }
        }
        
        [self setNavTitle];
    }
    else {
        if (swipedIndexPath.section == 0) {
            RegimenGoal *goal = [self.fetchedResultsController objectAtIndexPath:swipedIndexPath];
            goal.completed = [NSNumber numberWithBool:YES];
        
            [context save:&error];
            
            for(UIView *subview in [cell subviews]) {
                if(subview.tag == 1) {
                    [subview removeFromSuperview];
                }
            }
            
            [self setNavTitle];
        }
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *dayRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *dayEntity = [NSEntityDescription entityForName:@"RegimenGoal" inManagedObjectContext:_managedObjectContext];
    [dayRequest setEntity:dayEntity];
 
    NSPredicate *dayPredicate = [NSPredicate predicateWithFormat:@"time.duration ==     %@", @"Day"];
    [dayRequest setPredicate:dayPredicate];
 
    NSSortDescriptor *daySort = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:YES];

    NSSortDescriptor *completeSort = [[NSSortDescriptor alloc] initWithKey:@"completed" ascending:YES];
    
    [dayRequest setSortDescriptors:[NSArray arrayWithObjects:completeSort, daySort, nil]];
    
    [dayRequest setFetchBatchSize:20];
 
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:dayRequest
                                        managedObjectContext:_managedObjectContext sectionNameKeyPath:@"completed"
                                                   cacheName:@"Root"];
    
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(RegimenCell *)[_tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
    
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:sectionIndex];
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:set withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:set withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    
    [self.tableView endUpdates];
}


@end
