//
//  RegimenDayController.h
//  Regimen
//
//  Created by Sayem Islam on 10/3/12.
//  Copyright (c) 2012 HatTrick Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoalViewController.h"
#import "RegimenTable.h"
#import "RegimenCell.h"

@interface RegimenDayController : UIViewController <UITableViewDelegate, UITableViewDataSource, GoalViewControllerDelegate>

@property (strong, nonatomic) IBOutlet RegimenTable *tableView;
@property (nonatomic, retain) IBOutlet RegimenCell *regimenCell;

- (IBAction)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer;

@end
