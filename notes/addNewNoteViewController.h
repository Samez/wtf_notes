//
//  addNewNoteViewController.h
//  notes
//
//  Created by Samez on 20.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@interface addNewNoteViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, NSFetchedResultsControllerDelegate>
{
    UIImageView *tempImageView;
}

@property BOOL forEditing;
@property BOOL needFooterTitleForPrivateSection;
@property BOOL needFooterTitleForNameSection;

@property (nonatomic, retain) Note *note;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
