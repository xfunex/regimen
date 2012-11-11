//
//  RegimenSecondViewController.m
//  Regimen
//
//  Created by Sayem Islam on 10/3/12.
//  Copyright (c) 2012 HatTrick Labs, LLC. All rights reserved.
//

#import "RegimenWeekController.h"
#import "RegimenGoal.h"

@interface RegimenWeekController ()

@end

@implementation RegimenWeekController {
    NSMutableArray *items;
}
@synthesize tableView = _tableView;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    items = [[NSMutableArray alloc] initWithCapacity:20];
    
    RegimenGoal *item;
    
    item = [[RegimenGoal alloc] init];
    item.text = @"Walk the dog";
    [items addObject:item];
    
    item = [[RegimenGoal alloc] init];
    item.text = @"Brush my teeth";
    [items addObject:item];
    
    item = [[RegimenGoal alloc] init];
    item.text = @"Learn iOS development";
    [items addObject:item];
    
    item = [[RegimenGoal alloc] init];
    item.text = @"Soccer practice";
    [items addObject:item];
    
    item = [[RegimenGoal alloc] init];
    item.text = @"Eat ice cream";
    [items addObject:item];
    
    
    
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSWeekdayCalendarUnit fromDate:today];
    
    NSTimeInterval minusDays = ([components weekday]-1) * 24 * 60 * 60;
    NSTimeInterval plusDays = (7-[components weekday]) * 24 * 60 * 60;
    
    NSDate *startWeek = [[NSDate alloc] initWithTimeIntervalSinceNow:-minusDays];
    NSDate *endWeek = [[NSDate alloc] initWithTimeIntervalSinceNow:plusDays];
    
    NSDateComponents *sunday = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit) fromDate:startWeek];
    NSDateComponents *saturday = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit) fromDate:endWeek];
    
    NSString *week = [NSString stringWithFormat:@"%d/%d - %d/%d", [sunday month], [sunday day],[saturday month], [saturday day]];
    
    UINavigationItem *nav = [self navigationItem];
    [nav setTitle:week];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [items count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RegimenGoal"];
    
    UILabel *label = (UILabel *)[cell viewWithTag:1000];
    return cell;
}


- (IBAction)addItem {

    int newRowIndex = [items count];
    RegimenGoal *item = [[RegimenGoal alloc] init];
    item.text = @"I am a new row";
    [items addObject:item];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:newRowIndex inSection:0];
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)addGoalViewControllerDidCancel:(AddGoalViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addGoalViewController:(AddGoalViewController *)controller didFinishAddingItem:(RegimenGoal *)item
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
