//
//  notesListViewController.m
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "notesListViewController.h"
#import "detailViewController.h"
#import "addNewNoteViewController.h"
#import "testAddViewController.h"
#import "res.h"
#import "Note.h"
#import "LocalyticsSession.h"
#import "OptionsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MyButton.h"
#import "SearchField.h"
#import "SearchView.h"

@interface notesListViewController ()

@property UIBarButtonItem* deleteButton;
@property UIBarButtonItem* addButton;
@property UIBarButtonItem* deselectButton;
@property UIBarButtonItem* fillBDButton;
@property UIBarButtonItem* optionsButton;

@end

@implementation notesListViewController

@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize noteCell;
@synthesize addButton;
@synthesize deselectButton;
@synthesize fillBDButton;

#pragma mark - load settings / setup preferense

-(void)loadSettings
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey: @"password"] != nil)
    {
        PSWD = [[NSUserDefaults standardUserDefaults] objectForKey: @"password"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"unsafeDeletion"] != nil)
    {
        unsafeDeletion = [[NSUserDefaults standardUserDefaults] boolForKey:@"unsafeDeletion"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"swipeColor"] != nil)
    {
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"swipeColor"];
        swipeColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    }
}

//Конфигурация всех сраных кнопок
-(void)setupButtons
{
    //Кнопка добавления заметки
    UIImage* image3 = [UIImage imageNamed:@"add.png"];
    CGRect frameimg3 = CGRectMake(0, 0, 34, 29);
    UIButton *someButton3 = [[UIButton alloc] initWithFrame:frameimg3];
    [someButton3 setBackgroundImage:image3 forState:UIControlStateNormal];
    [someButton3 addTarget:self action:@selector(add:)
          forControlEvents:UIControlEventTouchUpInside];
    [someButton3 setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *bufButton3 =[[UIBarButtonItem alloc] initWithCustomView:someButton3];
    self.addButton=bufButton3;
    
    //Кнопка удаления выделенных ячеек
    UIImage* image2 = [UIImage imageNamed:@"trash2.png"];
    CGRect frameimg2 = CGRectMake(0, 0, 34, 29);
    UIButton *someButton2 = [[UIButton alloc] initWithFrame:frameimg2];
    [someButton2 setBackgroundImage:image2 forState:UIControlStateNormal];
    [someButton2 addTarget:self action:@selector(tryToDeleteSelectedCells)
          forControlEvents:UIControlEventTouchUpInside];
    [someButton2 setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *bufButton2 =[[UIBarButtonItem alloc] initWithCustomView:someButton2];
    self.deleteButton=bufButton2;
    
    //Кнопка перехода к контроллеру опций
    UIImage* image = [UIImage imageNamed:@"gear2.png"];
    CGRect frameimg = CGRectMake(0, 0, 36, 24);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image forState:UIControlStateNormal];
    [someButton addTarget:self action:@selector(goToOptions)
         forControlEvents:UIControlEventTouchUpInside];
    [someButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *bufButton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
    self.optionsButton=bufButton;
    
    //Кнопка отмены выделения свайпнутых ячеек
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setFrame:CGRectMake(0, 0, 24, 24)];
    [button1 setBackgroundImage:[UIImage imageNamed:@"X.png"] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(deselectSwipedCells) forControlEvents:UIControlEventTouchUpInside];
    [button1 setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *deselectButton_ = [[UIBarButtonItem alloc] initWithCustomView:button1];
    
    self.deselectButton = deselectButton_;
    
    
    //Кнопка заполнения БД случайными заметками
    self.fillBDButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fillBD)];
    
//    [[self navigationItem] setLeftBarButtonItem:self.fillBDButton];
}

//Установка сраных кнопок
-(void)setButtons
{
    [[self navigationItem] setLeftBarButtonItem:self.optionsButton animated:YES];
    [[self navigationItem] setRightBarButtonItem:self.addButton animated:YES];
}

-(void)removeButtons
{
    [[self navigationItem] setLeftBarButtonItem:nil animated:YES];
    [[self navigationItem] setRightBarButtonItem:nil animated:YES];
}

-(void)setNavigationItemTitleView
{
    [[self navigationItem] setTitleView:searchView];
    
    self.navigationItem.titleView = searchView;
    [searchView setAlpha:0.0];
    [UIView animateWithDuration:0.2 delay:0.1 options: UIViewAnimationCurveEaseOut
                     animations:^{
                         [searchView setAlpha:1.0];
                     }
                     completion:^(BOOL finished){}];
}

//Включение реакции на жесты: свайп влево, свайп вправо
-(void)setupRecognizers
{
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(handleSwipeLeft:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.tableView addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                           action:@selector(handleSwipeRight:)];
    recognizer.delegate = self;
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.tableView addGestureRecognizer:recognizer];
}

#pragma mark - View appear/load

- (void)viewDidLoad
{
    [super viewDidLoad];

    searchingNow = NO;
    
    myPredicate = nil;
    searchView = [[SearchView alloc] initWithFrame:CGRectMake(0, 0, 220, 25)];
    [searchView setDelegate:self];
    
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 55)];
    [footerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"whiteBoard.png"]]];
    self.tableView.tableFooterView = footerView;
    
    /*
    addFirstNoteView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 320, 100, 320, 140)];
    [addFirstNoteView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"arrow.png"]]];
    [addFirstNoteView setAlpha:0.0];
    
    [self.view addSubview:addFirstNoteView];
    
    addFirstNoteLabel = [[UILabel alloc] init];
    [addFirstNoteLabel setText:NSLocalizedString(@"addFirstNoteText", nil)];
    
    [addFirstNoteLabel setTextAlignment:NSTextAlignmentRight];
    [addFirstNoteLabel setBackgroundColor:[UIColor clearColor]];
    
    UIFont *helvFont = [UIFont fontWithName:@"Noteworthy-Light" size:16.0];
    
    [addFirstNoteLabel setFont:helvFont];
    
    CGRect labelRect = CGRectMake(self.view.frame.size.width - 320, 155, 190, 30);
    addFirstNoteLabel.frame = labelRect;
    
    [addFirstNoteLabel setAlpha:0.0];
    
    [self.view addSubview:addFirstNoteLabel];
    */
    [[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlack];
    
    NSError *error = nil;
    
	[[self fetchedResultsController] performFetch:&error];
    
    [self setupButtons];
    [self setButtons];
    [self setupRecognizers];
    
    iP = nil;
    
    canSwipe = YES;
    canDelete = YES;
    
    [self.view addObserver:self forKeyPath:@"frame" options:0 context:nil];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [[self tableView] reloadData];
        
    canShowAddFirstNoteView = YES;
    
    [self loadSettings]; 
    
    canTryToEnter = YES;
    canSwipe = YES;
    canDelete = YES;
    
    if ([[fetchedResultsController fetchedObjects] count] == 0)
        [self.tableView setSeparatorStyle:(UITableViewCellSeparatorStyleNone)];
    else
        [self.tableView setSeparatorStyle:(UITableViewCellSeparatorStyleSingleLine)];
    
    if (!returnedFromOptions)
        [self setButtons];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CGFloat delay = 0.0;
    
    if (returnedFromOptions)
    {
        delay = 0.8;
        returnedFromOptions = NO;
    }
    
    [self performSelector:@selector(setButtons) withObject:nil afterDelay:delay];
//    delay+=0.1;
    [self performSelector:@selector(setNavigationItemTitleView) withObject:nil afterDelay:delay];
    
//    [self performSelector:@selector(setAddFirstNoteView) withObject:nil afterDelay:delay];
    
    [[LocalyticsSession shared] tagScreen:@"Notes list"];
}

#pragma mark - View disappear/unload

-(void)viewWillDisappear:(BOOL)animated
{
    if ([swipedCells count] != 0)
    {
        [self deselectSwipedCells];
        swipedCells = nil;
    }
    
    if (iP != nil)
    {
        [self deselectPrivateRowAtIndexPath:iP];
        iP = nil;
    }
    
    if ([searchView searchingNow])
    {
        [searchView buttonClick];
    }
    
    [self.navigationItem setTitleView:nil];
    [self removeButtons];
}

- (void)viewDidUnload
{
    [self setNoteCell:nil];
//    [self removeAddFirstNoteView];
    [super viewDidUnload];
}

#pragma mark - Buttons selectors

//Удаление нескольких свайпнутых ячеек
-(void)tryToDeleteSelectedCells
{
    BOOL havePrivateNote = NO;
    
    int i = 0;
    
    while ((i < [swipedCells count]) && !havePrivateNote)
    {
        if ([[(Note*)[fetchedResultsController objectAtIndexPath:swipedCells[i]] isPrivate] boolValue])
        {
            havePrivateNote = YES;
            //Вызвать алерт вью если встретилась хоть одна приватная ячейка
            [self showPromptAlert];
            return;
        } else
            i++;
    }
    
    //Удаляем выбранные ячейки если среди них нет приватных
    [self deleteSwipedCells];
}

//Удаление нескольких выбранных ячеек
-(void)deleteSwipedCells
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         for (int i = 0; i < [swipedCells count]; ++i)
                         {
                             [managedObjectContext deleteObject:[fetchedResultsController objectAtIndexPath:swipedCells[i]]];
                             [[LocalyticsSession shared] tagEvent:@"Old note was deleted"];
                         }
                     }
                     completion:^(BOOL finished){
                         
                         NSError *error = nil;
                         [managedObjectContext save:&error];
                         
                     }];
    
    
    swipedCells = nil;
    
    [[self navigationItem] setRightBarButtonItem:self.addButton animated:YES];
    [self.navigationItem setLeftBarButtonItem:self.optionsButton animated:YES];
    //[self.navigationItem setTitleView:searchView];
}

//Переход к контроллеру опций
-(void)goToOptions
{
    returnedFromOptions = YES;
    
    OptionsViewController *OVC = [[OptionsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [OVC setNLC:self];
    
    [UIView transitionFromView:self.view
                        toView:OVC.view
                      duration:1.0
                       options:UIViewAnimationOptionTransitionCurlUp
                    completion:nil];
    
//    [self performSelector:@selector(removeAddFirstNoteView) withObject:nil afterDelay:0.2];
    
    [self removeButtons];
    
    [self.navigationController pushViewController:OVC animated:NO];
}

//Добавление новой заметки
- (void)add:(id)sender
{
    if (iP != nil)
    {
        [self deselectPrivateRowAtIndexPath:iP];
        iP = nil;
    }
    
    testAddViewController *nextC = [[testAddViewController alloc] init];
    
    [nextC setManagedObjectContext:managedObjectContext];
    [nextC setNote:nil];
    [nextC setNLC:self];

    [UIView transitionFromView:self.view
                        toView:nextC.view
                      duration:0.8
                       options:UIViewAnimationOptionTransitionCurlUp
                    completion:nil];
    
    [self removeButtons];
    
    [self.navigationController pushViewController:nextC animated:NO];
}

-(void)deselectSwipedCells
{
    for (int i = 0; i < [swipedCells count]; ++i)
    {
        [self swipeCellAtIndexPath:swipedCells[i] at:-_SHIFT_CELL_LENGTH withTargetColor:[UIColor whiteColor] andWithDuration:0.3];
    }
    
    [[self navigationItem] setRightBarButtonItem:self.addButton animated:YES];
    [self.navigationItem setLeftBarButtonItem:self.optionsButton animated:YES];
    //[self.navigationItem setTitleView:searchView];
    
    swipedCells = nil;
}

#pragma mark - "Add first note" view
/*
-(void)setAddFirstNoteView
{
    if (([[fetchedResultsController fetchedObjects] count] == 0) && (canShowAddFirstNoteView))
    {
        canShowAddFirstNoteView = NO;
        
        CGRect viewRect = CGRectMake(self.view.frame.size.width - 320, 100, 320, 140);
        addFirstNoteView.frame = viewRect;
        viewRect.origin.y = 0;
        
        CGRect labelRect = CGRectMake(self.view.frame.size.width - 320, 155, 190, 30);
        addFirstNoteLabel.frame = labelRect;
        labelRect.origin.y = 55;
        
        [UIView animateWithDuration:0.4
                              delay:0.1
                            options: kCAMediaTimingFunctionEaseIn || UIViewAnimationOptionAutoreverse
                         animations:^{
                             
                             [addFirstNoteView setAlpha:1.0];
                             addFirstNoteView.frame = viewRect;
                             [self.view bringSubviewToFront:addFirstNoteView];
                         }
                         completion:nil];
        
        [UIView animateWithDuration:0.4
                              delay:0.15
                            options: kCAMediaTimingFunctionEaseIn || UIViewAnimationOptionAutoreverse
                         animations:^{
                             
                             addFirstNoteLabel.frame = labelRect;
                             [addFirstNoteLabel setAlpha:1.0];
                             [self.view bringSubviewToFront:addFirstNoteLabel];
                         }
                         completion:^(BOOL finished){
                             canShowAddFirstNoteView = YES;
                         }];
    }
}

-(void)removeAddFirstNoteView
{
    [addFirstNoteView setAlpha:0.0];
    [addFirstNoteLabel setAlpha:0.0];
}
*/
#pragma mark - Searching

//Начало поиска
-(void)searchViewDidBeginSearching:(SearchView *)sender
{
    searchingNow = YES;
    
    //Смена инсетов таблицы, т.к. появляется клавиатура
    CGFloat height = 0.0;
    
    if (self.view.frame.size.height > 350)
        height = 216;
    else
        height = 162;
    
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, height, 0)];
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, height, 0)];
}

//Конец поиска
-(void)searchViewDidEndSearching:(SearchView *)sender
{
    searchingNow = NO;
    //Зануление инсетов, т.к. клавиатура исчезает
    [self.tableView setContentInset:UIEdgeInsetsZero];
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
    
    //Удаление предиката для поиска
    [self refetchWithPredicateString:nil];
}


//Подготовка перед началом поиска, отмена совершенных действий
-(BOOL)searchViewWillStartSearching:(SearchView *)sender
{
    if (iP != nil)
    {
        [self didSelectPrivateNoteAtIndexPath:iP];
    }
    
    if ([swipedCells count] > 0)
        [self deselectSwipedCells];
    
    return YES;
}

//Завершение поиска, отмена совершенных действий
-(BOOL)searchViewWillEndSearching:(SearchView *)sender
{
    if (iP != nil)
    {
        [self didSelectPrivateNoteAtIndexPath:iP];
    }
    
    if ([swipedCells count] > 0)
        [self deselectSwipedCells];

    return YES;
}

-(void)searchView:(SearchView *)sender changeTextTo:(NSString *)text
{
    if (iP!=nil)
    {
        canSwipe = YES;
        [self deselectPrivateRowAtIndexPath:iP];
        [self changeTableViewHeightAt:UIEdgeInsetsZero withDuration:0];
        
        iP = nil;
    }
    
    [self refetchWithPredicateString:text];
}

#pragma mark - Alert view

//Показать алерт вью для подтверждения удаления
-(BOOL)showPromptAlert
{
    customAlertView = [[CustomAlertView alloc]initWithTitle:NSLocalizedString(@"EnterPasswordToDeleteTitle", nil)
                                                                     message:nil
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"CancelButton", nil)
                                                           otherButtonTitles:NSLocalizedString(@"DeleteButton", nil),nil];
    
    UITextField *passwordField = [[UITextField alloc] init];
    
    if (self.view.frame.size.height > 320)
        [passwordField setFrame:CGRectMake(16,60,252,25)];
    else
        [passwordField setFrame:CGRectMake(16,50,252,25)];
    
    passwordField.borderStyle = UITextBorderStyleRoundedRect;
    passwordField.secureTextEntry = YES;
    passwordField.keyboardAppearance = UIKeyboardAppearanceAlert;
    passwordField.returnKeyType = UIReturnKeyDone;
    passwordField.delegate = self;
    [passwordField setTag:1919];
    [passwordField becomeFirstResponder];
    
    [customAlertView addSubview:passwordField];
    [customAlertView setDelegate:self];
	[customAlertView show];
    
    return YES;
}

//Обработка нажатий кнопок алерт вью
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex)
    {
        case 0:
        {
            [self deselectSwipedCells];
            break;
        }
            
        case 1:
        {
            for (UIView* view in alertView.subviews)
            {
                if ([view isKindOfClass:[UITextField class]])
                {
                    UITextField* textField = (UITextField*)view;
                    if ([[textField text] isEqualToString:PSWD])
                    {
                        [self deleteSwipedCells];
                        [(CustomAlertView*)alertView setPasswordIsAccepted:YES];
                    }
                    else
                    {
                        [textField setText:nil];
                        [customAlertView shakeView];
                    }
                }
            }
            break;
        }
            
    }
}

#pragma mark - Gesture recognizers

//Жест свайп влево - для развыбора ячейки
- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    if (indexPath != nil)
        [self deselectSwipedCellAtIndexPath:indexPath];
}

//Жест свайп вправо - для выбора ячейки
- (void)handleSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer
{
    if (canSwipe)
    {
        CGPoint location = [gestureRecognizer locationInView:self.tableView];
        
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
        
        if (indexPath != nil)
        {
            //Если выбранная ячейка первая И включено небезопасное удаление И ячейка не приватная удаляем ее
            if ((unsafeDeletion) && (![[[fetchedResultsController objectAtIndexPath:indexPath] isPrivate] boolValue]) && ([swipedCells count] == 0))
            {
                [self swipeToDeleteCellAtIndexPath:indexPath];
            }
            //Иначе добавляем ее и обновляем кнопки нав.бара
            else
            {
                if (swipedCells == nil)
                    swipedCells = [[NSMutableArray alloc] init];
                
                if ([swipedCells count] == 0)
                {
                    [self.navigationItem setLeftBarButtonItem:self.deselectButton animated:YES];
                    [self.navigationItem setRightBarButtonItem:self.deleteButton animated:YES];
                    //[self.navigationItem setTitleView:nil];
                }
                
                if (![swipedCells containsObject:indexPath])
                {
                    [self selectSwipedCellAtIndexPath:indexPath];
                }
            }
        }
    }
}

//Смещение свайпнутой ячейки
-(void)selectSwipedCellAtIndexPath:(NSIndexPath*)indexPath
{
    [swipedCells addObject:indexPath];
        
    [self swipeCellAtIndexPath:indexPath at:+_SHIFT_CELL_LENGTH withTargetColor:swipeColor andWithDuration:0.3];
}

//Деселект свайпнутой ячейки
-(void)deselectSwipedCellAtIndexPath:(NSIndexPath*)indexPath
{
    if ([swipedCells containsObject:indexPath])
    {
        [swipedCells removeObject:indexPath];
        [self swipeCellAtIndexPath:indexPath at:-_SHIFT_CELL_LENGTH withTargetColor:[UIColor whiteColor] andWithDuration:0.3];
        
        noteListCell *cell = (noteListCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        [[cell timeLabel] setTextColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1]];
        
        if ([swipedCells count] == 0)
        {
            [[self navigationItem] setRightBarButtonItem:self.addButton animated:YES];
            [self.navigationItem setLeftBarButtonItem:self.optionsButton animated:YES];
            //[self.navigationItem setTitleView:searchView];
        }
    }
}

//Анимация свайпа ячейки
-(void)swipeCellAtIndexPath:(NSIndexPath*)indexPath at:(CGFloat)xPixels withTargetColor:(UIColor*)color andWithDuration:(CGFloat)duration
{
    [UIView animateWithDuration:duration
                          delay:0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         [self updateCellAtIndexPath:indexPath at:xPixels withTargetColor:color];
                     }
                     completion:^(BOOL finished){

                     }];
}

//Удаление ячейки используя свайп
-(void)swipeToDeleteCellAtIndexPath:(NSIndexPath*)indexPath
{
    if (canDelete)
    {
        canDelete = NO;
        canSwipe = NO;
        if ([[fetchedResultsController fetchedObjects] count] == 1)
            [self.tableView setSeparatorStyle:(UITableViewCellSeparatorStyleNone)];
        [UIView animateWithDuration:0.4
                              delay:0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             [self updateCellAtIndexPath:indexPath at:320 withTargetColor:swipeColor];
                         }
                         completion:^(BOOL finished){

                             [managedObjectContext deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
                             
                             [[LocalyticsSession shared] tagEvent:@"Old note was deleted"];
                             
                             NSError *error = nil;
                             
                             [managedObjectContext save:&error];
                             
                             canDelete = YES;
                             canSwipe = YES;
                        }];
    }
}

//Исменение параметров ячейки
-(void)updateCellAtIndexPath:(NSIndexPath*)indexPath at:(CGFloat)xPixels withTargetColor:(UIColor*)color
{
    noteListCell *cell = (noteListCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.supportView setBackgroundColor:color];
    
    if ([color isEqual:[UIColor colorWithRed:1 green:0 blue:0 alpha:0.8]])
        [[cell timeLabel] setTextColor:[UIColor whiteColor]];
    else if ([color isEqual:[UIColor whiteColor]])
        [[cell timeLabel] setTextColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1]];
    
    [cell.supportView setFrame:CGRectMake(cell.supportView.frame.origin.x + xPixels, cell.supportView.frame.origin.y, cell.supportView.frame.size.width, cell.supportView.frame.size.height)];
}

#pragma mark - Open note

//Открыть выбранную заметку
- (void)showNoteAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated;
{
    noteListCell* cell = (noteListCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    Note *note = (Note*)[[fetchedResultsController fetchedObjects] objectAtIndex:indexPath.row];
    
    [UIView animateWithDuration:0.1 delay:0 options: UIViewAnimationCurveEaseOut
                     animations:^{
                         [[cell supportView] setBackgroundColor:[UIColor clearColor]];
                         [cell setBackgroundColor:[UIColor sashaGray]];
                         [[cell noteNameLabel] setTextColor:[UIColor whiteColor]];
                         [[cell timeLabel] setTextColor:[UIColor whiteColor]];
                         
                         if ([[note isPrivate] boolValue])
                         {
                             [[cell passwordField] setBackgroundColor:[UIColor whiteColor]];
                         }
                     }
                     completion:^(BOOL finished){
                         
                         testAddViewController *nextC = [[testAddViewController alloc] init];
                         [nextC setNote:note];
                         [nextC setForEditing:YES];
                         [nextC setManagedObjectContext:managedObjectContext];
                         [nextC setNLC:self];
                         
                         [self removeButtons];
                         
                         [UIView transitionFromView:self.view
                                             toView:nextC.view
                                           duration:0.8
                                            options:UIViewAnimationOptionTransitionCurlUp
                                         completion:nil];
                         
                         [self.navigationController pushViewController:nextC animated:NO];
                         
                     }];
}

//Попытка открыть приватную заметку после ввода пароля
-(void)tryEnter
{
    noteListCell *cell = (noteListCell*)[[self tableView] cellForRowAtIndexPath:iP];

    //Если введенный пароль верный - открыть заметку
    if ([[[cell passwordField] text] isEqualToString:PSWD])
    {
        [self changeTableViewHeightAt:UIEdgeInsetsZero withDuration:0.25];
        [self showNoteAtIndexPath:iP animated:YES];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastTime"];
    }
    //Иначе - привлечь внимание к тому что пароль введен неверно
    else
        [cell alertShake];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField tag] == 666)
    {
        [textField resignFirstResponder];
        [self tryEnter];
        return NO;
    }
    
    if ([textField tag] == 1919)
    {
        if ([[textField text] isEqualToString:PSWD])
        {
            [self deleteSwipedCells];
            [customAlertView dismissWithClickedButtonIndex:customAlertView.cancelButtonIndex animated:YES];
        } else
        {
            [textField setText:nil];
            [customAlertView shakeView];
        }
        
    }
    return YES;
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[fetchedResultsController fetchedObjects] count];
}

//Высота ячейки
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([iP isEqual:indexPath])
        return 85;
    else
        return 50;
}

//конфигурация параметров ячейки
-(void)configureCell:(noteListCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    Note *note = (Note*)[fetchedResultsController objectAtIndexPath:indexPath];
    [cell setN:note];
    
    [[cell timeLabel] setTextColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1]];
    
    [[cell passwordField]  setReturnKeyType:UIReturnKeyDone];
    [[cell passwordField] setDelegate:self];
    [[cell passwordField]  setSecureTextEntry:YES];
    
    [[cell noteNameLabel] setTextColor:[UIColor blackColor]];
    [[cell noteNameLabel] setFont:[UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:@"noteNameFont"] size:[[NSUserDefaults standardUserDefaults] floatForKey:@"noteNameFontSize"]]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyCellIdentifier = @"noteListCell";
    
    noteListCell *MYcell = [tableView dequeueReusableCellWithIdentifier:MyCellIdentifier];
    
    if (!MYcell)
    {
        [[NSBundle mainBundle] loadNibNamed:@"noteListCell" owner:self options:nil];
        MYcell = noteCell;
        noteCell = nil;
    }
    
    [[MYcell passwordField] setAlpha:0.0];
    
    [self configureCell:MYcell atIndexPath:indexPath];
    
    MYcell.passwordField.keyboardAppearance = UIKeyboardAppearanceAlert;

    return MYcell;
}

//Обновляем внешний вид ячейки перед отображением
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Если ячейка была свайпнута
    if([swipedCells containsObject:indexPath])
    {
        [((noteListCell*)cell).supportView setBackgroundColor:swipeColor];
        
        [[(noteListCell*)cell noteNameLabel] setTextColor:[UIColor blackColor]];
        
        if ([swipeColor isEqual:[UIColor colorWithRed:1 green:0 blue:0 alpha:0.8]])
            [[(noteListCell*)cell timeLabel] setTextColor:[UIColor whiteColor]];
        
        CGRect t=((noteListCell*)cell).supportView.frame ;
        t.origin.x=_SHIFT_CELL_LENGTH;
        ((noteListCell*)cell).supportView.frame=t;
    } else
        //если ячейка не была свайпнута
    {
        [((noteListCell*)cell).supportView setBackgroundColor:[UIColor whiteColor]];
        CGRect t=((noteListCell*)cell).supportView.frame ;
        t.origin.x=0;
        ((noteListCell*)cell).supportView.frame=t;
    }
}

//Произошел тап на любую ячейку в таблице
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (searchingNow)
        [searchView hideSearchFieldCursor];
    
    //Если есть свайпнутые ячейки, то тапом свайпаем/десвайпаем ячейки
    if ([swipedCells count] != 0)
    {
        if (![swipedCells containsObject:indexPath])
        {
            [self selectSwipedCellAtIndexPath:indexPath];
        } else
        {
            [self deselectSwipedCellAtIndexPath:indexPath];
        }
    }
    else
    {
        Note *note = (Note*)[fetchedResultsController objectAtIndexPath:indexPath];
        
        //Если заметка приватная - замеряем промежуток времени между последним вводом пароля и сейчас, сравниваем его с
        if ([[note isPrivate] boolValue])
        {
            NSDate *lastTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastTime"];
            
            NSDate *newDate = [NSDate dateWithTimeInterval:[[NSUserDefaults standardUserDefaults] integerForKey:@"PasswordRequestInterval"] sinceDate:lastTime];
            
            //Если прошло времени меньше чем в заданном интервале - ставим флаг что мы можем открыть заметку
            if ([newDate compare:[NSDate date]] == NSOrderedDescending)
            {
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastTime"];
                [self showNoteAtIndexPath:indexPath animated:YES];
            } else
                [self didSelectPrivateNoteAtIndexPath:indexPath];
            
        }
        //Иначе - открываем неприватную заметку
        else
        {
            if (iP != nil)
            {
                [self didSelectPrivateNoteAtIndexPath:iP];
            }
            
            [self showNoteAtIndexPath:indexPath animated:YES];
        }
    }
}

//Изменение инсетов таблицы (т.к. появляется клавиатура) и перемотка на тапнутую ячейку, если она приватная
-(void)changeTableViewHeightAt:(UIEdgeInsets)edgeInsets withDuration:(CGFloat)duration
{
    if (canTryToEnter)
    {
        canTryToEnter = NO;
        [UIView animateWithDuration:duration delay:0 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             [self.tableView setContentInset:edgeInsets];
                             [self.tableView setScrollIndicatorInsets:edgeInsets];
                         }
                         completion:^(BOOL finished){
                             int maxIndex = 0;
                             CGFloat height = self.view.frame.size.height;
                             
                             if (height > 500)
                             {
                                 maxIndex = 5;
                             } else
                                 if (height <= 320)
                                 {
                                     maxIndex = 2;
                                 } else
                                     maxIndex = 4;
                             
                             int index = [[self.tableView visibleCells] indexOfObject:[self.tableView cellForRowAtIndexPath:iP]];
                             if (index == 0)
                                 [self.tableView scrollToRowAtIndexPath:iP atScrollPosition:UITableViewScrollPositionTop animated:YES];
                             else if (index >= maxIndex)
                                 [self.tableView scrollToRowAtIndexPath:iP atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                             
                             canTryToEnter = YES;
                         }];
    }
}

//Произошел тап на приватную ячейку
-(void)didSelectPrivateNoteAtIndexPath:(NSIndexPath*)indexPath
{
    noteListCell* cell=(noteListCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if (canTryToEnter)
    {
        //Если до этого не была тапнута другая приватная ячейка
        if (iP == nil)
        {
            CGRect passFieldFrame=[cell.passwordField frame];
            passFieldFrame.origin.y=57-35;
            cell.passwordField.frame=passFieldFrame;
            cell.passwordField.autoresizingMask&=(63-UIViewAutoresizingFlexibleBottomMargin);
            cell.passwordField.autoresizingMask|=UIViewAutoresizingFlexibleTopMargin;
            
            canSwipe = NO;
            iP = indexPath;
            
            [[(noteListCell*)[[self tableView] cellForRowAtIndexPath:iP] passwordField] setTag:666];
            
            [(noteListCell*)[[self tableView] cellForRowAtIndexPath:iP] showPasswordField];
            
            CGFloat height = 0.0;
            
            if (self.view.frame.size.height > 400)
                height = 216;
            else
                height = 162;
            
            [self changeTableViewHeightAt:UIEdgeInsetsMake(0, 0, height, 0) withDuration:0.25];
        }
        else
        {
            //Если тапнули по другой приватной ячейке
            if (![iP isEqual:indexPath])
            {
                noteListCell* oldCell=(noteListCell*)[self.tableView cellForRowAtIndexPath:iP];
                
                if (iP.row>indexPath.row)
                {
                    CGRect passFieldFrame=[cell.passwordField frame];
                    passFieldFrame.origin.y=57;
                    cell.passwordField.frame=passFieldFrame;
                    cell.passwordField.autoresizingMask&=(63-UIViewAutoresizingFlexibleTopMargin);
                    cell.passwordField.autoresizingMask|=UIViewAutoresizingFlexibleBottomMargin;
                    
                    oldCell.passwordField.autoresizingMask&=(63-UIViewAutoresizingFlexibleBottomMargin);
                    oldCell.passwordField.autoresizingMask|=UIViewAutoresizingFlexibleTopMargin;
                }else
                {
                    CGRect passFieldFrame=[cell.passwordField frame];
                    passFieldFrame.origin.y=57-35;
                    cell.passwordField.frame=passFieldFrame;
                    cell.passwordField.autoresizingMask&=(63-UIViewAutoresizingFlexibleBottomMargin);
                    cell.passwordField.autoresizingMask|=UIViewAutoresizingFlexibleTopMargin;
                    
                    oldCell.passwordField.autoresizingMask&=(63-UIViewAutoresizingFlexibleTopMargin);
                    oldCell.passwordField.autoresizingMask|=UIViewAutoresizingFlexibleBottomMargin;
                }
                
                canSwipe = NO;
                [self deselectPrivateRowAtIndexPath:iP];
                
                iP = indexPath;
                
                [[(noteListCell*)[[self tableView] cellForRowAtIndexPath:iP] passwordField] setTag:666];
                
                [(noteListCell*)[[self tableView] cellForRowAtIndexPath:iP] showPasswordField];
                
                CGFloat height = 0.0;
                
                if (self.view.frame.size.height > 400)
                    height = 216;
                else
                    height = 162;
                
                [self changeTableViewHeightAt:UIEdgeInsetsMake(0, 0, height, 0) withDuration:0.25];
                
            }
            //Если тапнули по той же самой приватной ячейке
            else
            {
                CGRect passFieldFrame=[cell.passwordField frame];
                
                cell.passwordField.frame=passFieldFrame;
                cell.passwordField.autoresizingMask&=(63-UIViewAutoresizingFlexibleBottomMargin);
                cell.passwordField.autoresizingMask|=UIViewAutoresizingFlexibleTopMargin;
                
                canSwipe = YES;
                [self deselectPrivateRowAtIndexPath:iP];
                
                [self changeTableViewHeightAt:UIEdgeInsetsZero withDuration:0.25];
                
                CGFloat height = 0.0;
                
                if (self.view.frame.size.height > 400)
                    height = 216;
                else
                    height = 162;
                
                [cell hidePasswordField];
                [self changeTableViewHeightAt:UIEdgeInsetsMake(0, 0, height, 0) withDuration:0.25];
                
                iP = nil;
            }
        }
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    } else
    {
        return;
    }
}

-(void)deselectPrivateRowAtIndexPath:(NSIndexPath*)indexPath
{
    noteListCell *cell = (noteListCell*)[[self tableView] cellForRowAtIndexPath:indexPath];
    
    [[cell passwordField] resignFirstResponder];
    [[cell passwordField] setTag:nil];
}

#pragma mark - Fetched result controller

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[[self tableView] endUpdates];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	[[self tableView] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationRight];
			break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
	UITableView *tableView = self.tableView;
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView setSeparatorStyle:(UITableViewCellSeparatorStyleSingleLine)];
            if ([[fetchedResultsController fetchedObjects] count] == 1)
            {
//                [self performSelector:@selector(removeAddFirstNoteView) withObject:nil afterDelay:0.2];
            }
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
            if ([[fetchedResultsController fetchedObjects] count] == 0)
            {
                [self.tableView setSeparatorStyle:(UITableViewCellSeparatorStyleNone)];
                
                if ([myPredicate length] == 0)
                {
//                    [self setAddFirstNoteView];
                }
            }
			break;
			
		case NSFetchedResultsChangeUpdate:
        {
            if ([[fetchedResultsController fetchedObjects] count] > 0)
            {
                [self configureCell:(noteListCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];

//                [self performSelector:@selector(removeAddFirstNoteView) withObject:nil afterDelay:0.2];
            }
			break;
        }
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
	}
}

- (NSFetchedResultsController *)fetchedResultsController
{
    // Set up the fetched results controller if needed.
    if (fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        if(myPredicate.length != 0)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", myPredicate];
            [fetchRequest setPredicate:predicate];
        }
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
    }
	
	return fetchedResultsController;
}

-(void)refetchWithPredicateString:(NSString*)predicate
{
    fetchedResultsController.delegate = nil;
    fetchedResultsController = nil;
    
    myPredicate = predicate;
    
    NSError *error;
    [[self fetchedResultsController] performFetch:&error];
    
    if ([[fetchedResultsController fetchedObjects] count] == 0)
        [self.tableView setSeparatorStyle:(UITableViewCellSeparatorStyleNone)];
    else
        [self.tableView setSeparatorStyle:(UITableViewCellSeparatorStyleSingleLine)];
    
    [self.tableView reloadData];
}

#pragma mark - Other

//Наблюдение за сменой ориентации
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

    for (UIView* view in customAlertView.subviews)
    {
        if ([view isKindOfClass:[UITextField class]])
        {
            UITextField* textField = (UITextField*)view;

            if (self.view.frame.size.height > 320)
                [textField setFrame:CGRectMake(16,60,252,25)];
            else
                [textField setFrame:CGRectMake(16,50,252,25)];
        }
    }

    [customAlertView setNeedsDisplay];
    /*
    CGRect rect = addFirstNoteView.frame;
    
    rect.origin.x = self.view.frame.size.width - 320;
    addFirstNoteView.frame = rect;
    
    rect = addFirstNoteLabel.frame;
    
    rect.origin.x = self.view.frame.size.width - 320;
    addFirstNoteLabel.frame = rect;
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - debug/test

//Заполнение БД случайными заметками
-(void)fillBD
{
    int notesCount = 15;
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    int len = 14;
    
    for (int i = 0; i<notesCount; ++i)
    {
        NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
        
        for (int i=0; i<len; i++) {
            [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
        }
        
        Note *note = (Note*)[NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:[self managedObjectContext]];
        
        NSString *noteText = @"1.	Получить матрицы парных сравнений критериев и матрицы парных сравнений альтернатив в рамках каждого критерия от всех экспертов. Если имеется n критериев на заданном уровне иерархии, то создается матрица А размерности  , именуемую матрицей парных сравнений, которая отражает суждение лица, принимающего решение, относительно важности разных критериев. Парное сравнение выполняется таким образом, что критерий в строке i (i=1, 2, …, n) оценивается относительно каждого из критериев, представленных n столбцами. Обозначим через aij элемент матрицы А, находящийся на пересечении i –строки и j – столбц";
        
        [note setDate:[NSDate date]];
        [note setIsPrivate:[NSNumber numberWithUnsignedInt:arc4random()%2]];
        
        if ([note isPrivate])
        {
            [note setText:noteText];
            [note setName:randomString];
        }
        else
            [note setName:noteText];
    }
    
    NSError *error = nil;
    [managedObjectContext save:&error];
}

@end