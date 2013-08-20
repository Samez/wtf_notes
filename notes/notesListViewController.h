//
//  notesListViewController.h
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import "noteListCell.h"
#import "CustomAlertView.h"
#import "addNewNoteViewController.h"
#import "SearchView.h"
#import "SearchField.h"

@interface notesListViewController : UITableViewController <NSFetchedResultsControllerDelegate,
                                                            UITextFieldDelegate,
                                                            UIGestureRecognizerDelegate,
                                                            UIAlertViewDelegate,
                                                            SearchViewDelegate>

{
    CustomAlertView *customAlertView; //Для подтверждения удаления
    SearchView *searchView; //Navigation item title
    
    NSIndexPath *iP; //IndexPath тапнутой запароленной ячейки
    NSString *PSWD;
    NSString *myPredicate; //Searching
    NSMutableArray *swipedCells; //Массив с выделенными ячейками
    UIColor *swipeColor;
//    UIView *addFirstNoteView; //Вьюшка со стрелочкой
//    UILabel *addFirstNoteLabel; //Лейбл с надписью возле стрелочки
    
    BOOL unsafeDeletion;
    BOOL canSwipe;
    BOOL canDelete;
    BOOL canTryToEnter;
    BOOL canShowAddFirstNoteView;
    BOOL searchingNow;
    BOOL returnedFromOptions;
}

@property (strong, nonatomic) IBOutlet noteListCell *noteCell;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end

