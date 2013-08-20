//
//  OptionsViewController.h
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellWithSwitcher.h"
#import "notesListViewController.h"
#import "ReturnPasswordCell.h"

@interface OptionsViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
    NSMutableArray *intervalValueArray;
    NSMutableArray *intervalNameArray;
    
    BOOL unsafeDeletion;
    BOOL swipeColorIsRed;
}

@property (strong, nonatomic) IBOutlet ReturnPasswordCell *returnPasswordCell;
@property (strong, nonatomic) IBOutlet CellWithSwitcher *mySwitchCell;

@property notesListViewController *NLC;

@end
