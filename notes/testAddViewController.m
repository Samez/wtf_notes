//
//  testAddViewController.m
//  notes
//
//  Created by Samez on 02.04.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "testAddViewController.h"
#import "res.h"
#import "LocalyticsSession.h"
#import <QuartzCore/QuartzCore.h>
#import "MyButton.h"

@interface testAddViewController ()

@property UIView* trashButton;
@property UIBarButtonItem* cancelButton;
@property UIBarButtonItem* saveButton;

@end

@implementation testAddViewController
@synthesize forEditing;
@synthesize myTextView;
@synthesize myNameField;
@synthesize managedObjectContext;
@synthesize note;
@synthesize timeText;
@synthesize lockButton;

@synthesize trashButton;
@synthesize cancelButton;
@synthesize saveButton;
@synthesize backView;
@synthesize NLC;

#pragma mark - Load settings/setup preference

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        nameSymbolCount = 0;
        isPrivate = NO;
        alertIsVisible = NO;
        alerting = NO;
        hidining = NO;
        keyboardIsActive = NO;
    }
    return self;
}

-(void)setupFields
{
    [self updateMyTextViewWithDuration:0.0];
    [self updateBackViewWithDuration:0.0];
    [self updateTimeTextWithDuration:0.0];
    
    [myTextView setBackgroundColor:[UIColor whiteColor]];
    [myTextView setDelegate:self];
    [myTextView.layer setCornerRadius:5];
    [myTextView.layer setMasksToBounds:YES];
    [myTextView setNeedsDisplay];
    
    [myNameField setDelegate:self];
    
    [backView setBackgroundColor:[UIColor whiteColor]];
    [backView.layer setCornerRadius:5];
    [backView.layer setMasksToBounds:YES];
    
    if (!forEditing)
    {
        [timeText setHidden:YES];
    } else
    {
        NSDateFormatter * date_format = [[NSDateFormatter alloc] init];
        [date_format setDateFormat: @"HH:mm MMMM d, YYYY"];
        NSString *identifier = [[NSLocale currentLocale] localeIdentifier];
        [date_format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:identifier]];
        NSString * timeString = [date_format stringFromDate: [note date]];
        
        [timeText setText:timeString];
        [timeText setHidden:NO];
        
        if (isPrivate)
        {
            [myNameField setText:[note name]];
            [myTextView setText:[note text]];
        } else
        {
            [myTextView setText:[note name]];
        }
        
    }
    
    [[self view] addSubview:backView];
    [[self view] addSubview:myTextView];
    [[self view] addSubview:timeText];
    [[self view] addSubview:myNameField];
}

-(void)setupButtons
{
    UIView *trashButtonContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 34, 29)];
    trashButtonContainer.backgroundColor = [UIColor clearColor];
    UIButton *button0 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button0 setFrame:CGRectMake(0, 0, 34, 29)];
    [button0 setBackgroundImage:[UIImage imageNamed:@"trash2.png"] forState:UIControlStateNormal];
    [button0 addTarget:self action:@selector(clickTrashButton:) forControlEvents:UIControlEventTouchUpInside];
    [button0 setShowsTouchWhenHighlighted:YES];
    [trashButtonContainer addSubview:button0];
    
    self.trashButton = trashButtonContainer;
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setFrame:CGRectMake(0, 0, 24, 24)];
    [button1 setBackgroundImage:[UIImage imageNamed:@"X.png"] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [button1 setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *cancelButton_ = [[UIBarButtonItem alloc] initWithCustomView:button1];
    
    self.cancelButton = cancelButton_;
    
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setFrame:CGRectMake(0, 0, 24, 24)];
    [button2 setBackgroundImage:[UIImage imageNamed:@"checkmark.png"] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [button2 setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *saveButton_ = [[UIBarButtonItem alloc] initWithCustomView:button2];
    
    self.saveButton = saveButton_;
    
    UIImage *firstImage;
    UIImage *secondImage;
    
    if (isPrivate)
    {
        firstImage  = [UIImage imageNamed:@"locked.png"];
        secondImage = [UIImage imageNamed:@"unlocked.png"];
    } else
    {
        firstImage  = [UIImage imageNamed:@"unlocked.png"];
        secondImage = [UIImage imageNamed:@"locked.png"];
    }
    
    UIView *container = [UIButton flipButtonWithFirstImage:firstImage
                                               secondImage:secondImage
                                           firstTransition:UIViewAnimationTransitionFlipFromRight
                                          secondTransition:UIViewAnimationTransitionFlipFromRight
                                            animationCurve:UIViewAnimationCurveEaseInOut
                                                  duration:0.3
                                                    target:self
                                                  selector:@selector(clickLockButton:)];
    
    [lockButton addSubview:container];
    
    [[self view] addSubview:lockButton];
}

-(void)setButtons
{
    [self.navigationItem setLeftBarButtonItem:cancelButton animated:YES];
    [self.navigationItem setRightBarButtonItem:saveButton animated:YES];
}

-(void)removeButtons
{
    [[self navigationItem] setLeftBarButtonItem:nil animated:YES];
    [[self navigationItem] setRightBarButtonItem:nil animated:YES];
}

#pragma mark - View appear/load

-(void)viewWillAppear:(BOOL)animated
{
    [self updateMyTextViewWithDuration:0.0];
    [self updateBackViewWithDuration:0.0];
    [self updateTimeTextWithDuration:0.0];
    
    [myTextView setFont:[UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:@"noteTextFont"] size:[[NSUserDefaults standardUserDefaults] integerForKey:@"noteTextFontSize"]]];
    
    [myNameField setFont:[UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:@"noteNameFont"] size:[[NSUserDefaults standardUserDefaults] integerForKey:@"noteNameFontSize"]]];
}

-(void)viewDidAppear:(BOOL)animated
{    
    [[LocalyticsSession shared] tagScreen:@"New note / edit note"];
    [self setButtons];
    
    if (forEditing)
    {
        self.navigationItem.titleView = trashButton;
        [trashButton setAlpha:0.0];
        [UIView animateWithDuration:0.2 delay:0.1 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             [trashButton setAlpha:1.0];
                         }
                         completion:^(BOOL finished){}];
    }
//    if (!forEditing)
//        [[self navigationItem] setTitle:NSLocalizedString(@"NewNote", nil)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setAutoresizesSubviews:YES];
    self.navigationItem.hidesBackButton = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [[self view] addGestureRecognizer:tap];
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"woodenBackground.png"]]];
    
    if (note != nil)
    {
        forEditing = YES;
        isPrivate = [[note isPrivate] boolValue];
        
        CGRect rect = myNameField.frame;
        
        if (isPrivate)
            rect.origin.y = 20;
        else
            rect.origin.y = -35;
        
        myNameField.frame = rect;
    }
    else
    {
        note = (Note*)[NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:[self managedObjectContext]];
        
//        [[self navigationItem] setTitle:NSLocalizedString(@"NewNote", nil)];
    }
    
    [[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlack];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self setupFields];
    [self setupButtons];

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    if (!forEditing)
        [self.myTextView becomeFirstResponder];
}

- (void) orientationChanged:(NSNotification *)note
{
    [self updateMyTextViewWithDuration:0.3];
    [self updateBackViewWithDuration:0.3];
    [self updateTimeTextWithDuration:0.3];
}

#pragma mark - Update views

-(void)updateMyTextViewWithDuration:(CGFloat)duration
{
    CGRect rect = myTextView.frame;
    
    rect.size.width = self.view.frame.size.width - 22;
    rect.size.height = [self getValideTextFieldHeight];
    
    [self setNewFrame:rect toView:myTextView withDuration:duration];
}

-(void)updateTimeTextWithDuration:(CGFloat)duration
{
    CGRect newRect = timeText.frame;
    
    newRect.origin.x = myTextView.frame.origin.x + myTextView.frame.size.width - timeText.frame.size.width;
    newRect.origin.y = myTextView.frame.origin.y + myTextView.frame.size.height+5;

    [self setNewFrame:newRect toView:timeText withDuration:duration];
}

-(void)updateBackViewWithDuration:(CGFloat)duration
{
    CGRect newRect = backView.frame;
    
    newRect.size.width = self.view.frame.size.width - 22;
    newRect.size.height = myTextView.frame.size.height + 44 + 5;
    
    [self setNewFrame:newRect toView:backView withDuration:duration];
}

-(CGFloat)getValideTextFieldHeight
{
    CGFloat height = myTextView.contentSize.height;

    if ((self.view.frame.size.height <= 320) || ((keyboardIsActive) &&(self.view.frame.size.height != 416)))
    {
        height = 190;
    } else
        if (self.view.frame.size.height == 416)
        {
            height = self.view.frame.size.height - 55 - 25;
        } else
        {
            CGFloat maxHeight = self.view.frame.size.height - 55 - 25;
            
            if (height > maxHeight)
                height = maxHeight;
            else
                if (height < 190)
                    height = 190;
        }

    return height;
}

#pragma mark - Keyboard

-(void) keyboardWillShow:(NSNotification*) notification
{
    keyboardIsActive = YES;
    
    
    if (self.view.frame.size.height == 416)
    {
        [self.myTextView setContentInset:UIEdgeInsetsMake(0, 0, 216, 0)];
    } else
        if (self.view.frame.size.height <= 320)
            [self.myTextView setContentInset:UIEdgeInsetsMake(0, 0, 140, 0)];
        else
        {
            CGRect rect = myTextView.frame;
            
            rect.size.height = 190;
            [self setNewFrame:rect toView:myTextView withDuration:0.25];
            
            rect = backView.frame;
            rect.size.height = myTextView.frame.origin.y + myTextView.frame.size.height - backView.frame.origin.y + 5;
            [self setNewFrame:rect toView:backView withDuration:0.25];
            [self updateTimeTextWithDuration:0.25];
        }
}

-(void) keyboardWillHide:(NSNotification*) notification
{
    keyboardIsActive = NO;
    
    [self.myTextView setContentInset:UIEdgeInsetsMake(0, 0, myTextView.contentSize.height, 0)];
    
    if ((self.view.frame.size.height <= 320) || (self.view.frame.size.height == 416))
    {
        [self.myTextView setContentInset:UIEdgeInsetsZero];
    } else
    {
        [self updateMyTextViewWithDuration:0.25];
        [self updateBackViewWithDuration:0.25];
        [self.myTextView setContentInset:UIEdgeInsetsZero];
        [self updateTimeTextWithDuration:0.25];
    }
}

-(void)dismissKeyboard
{
    [myTextView resignFirstResponder];
    [myNameField resignFirstResponder];
}

#pragma mark - Text field delegate

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [myTextView becomeFirstResponder];
    return NO;
}

#pragma mark - Buttons selectors

-(void)goToNotesList
{
    [UIView transitionFromView:self.view
                        toView:NLC.view
                      duration:0.8
                       options:UIViewAnimationOptionTransitionCurlDown
                    completion:nil];
    
    [self.navigationController popToViewController:NLC animated:NO];
}

-(void)clickLockButton:(id)sender
{
    isPrivate = !isPrivate;
    
    CGRect rect = myNameField.frame;
    
    if (isPrivate)
    {
        rect.origin.y = 20.0;
    } else
    {
        [myNameField resignFirstResponder];
        rect.origin.y = -35.0;
    }
    
    [UIView animateWithDuration:0.3 delay:0 options:nil
                     animations:^{
                         myNameField.frame = rect;
                     } completion:^(BOOL finished) {
                     }];
}

- (void)clickTrashButton:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"CancelButton", nil)
                                  destructiveButtonTitle:NSLocalizedString(@"DeleteButton", nil)
                                  otherButtonTitles:nil,nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex)
    {
        case 0:
        {
            [managedObjectContext deleteObject:note];
            
            NSError *error = nil;
            
            [[self managedObjectContext] save:&error];
            
            [[LocalyticsSession shared] tagEvent:@"Old note was deleted"];
            
            [self removeButtons];
            [self goToNotesList];
            
//            [[self navigationController] popToRootViewControllerAnimated:YES];
            break;
        }
        case 1:
        {
            break;
        }
    }
}

- (void)cancel
{
    if (!forEditing)
    {
        [[self managedObjectContext] deleteObject:note];
    
        [[LocalyticsSession shared] tagEvent:@"Creating a new note has been canceled"];
    }
    
    [self removeButtons];
    [self goToNotesList];
}

-(void)save
{
    if (isPrivate)
    {
        if (([[myNameField text] length] == 0) || ([[myTextView text] length] == 0))
        {
            if ([[myNameField text] length] == 0)
                [self shakeView:myNameField];
            if ([[myTextView text] length] == 0)
                [self shakeView:myTextView];
            return;
        } else
        {
            [note setText:[myTextView text]];
            [note setName:[myNameField text]];
        }
    } else
    {
        if ([[myTextView text] length] == 0)
        {
            [self shakeView:myTextView];
            return;
        } else
        {
            [note setText:nil];
            [note setName:[myTextView text]];
        }
    }
    
    [note setIsPrivate:[NSNumber numberWithBool:isPrivate]];
    
    if(!forEditing || [[NSUserDefaults standardUserDefaults] boolForKey:@"needUpdateTime"])
        [note setDate:[NSDate date]];
    
    if (forEditing)
        [[LocalyticsSession shared] tagEvent:@"Old note was updated"];
    
    NSError *error = nil;
    
    [[self managedObjectContext] save:&error];
    
    [[LocalyticsSession shared] tagEvent:@"New note was added"];
    
    [self removeButtons];
    [self goToNotesList];
}

#pragma mark - Other

-(void)shakeView:(UIView*)viewToShake
{
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
    [shake setDuration:0.1];
    [shake setRepeatCount:2];
    [shake setAutoreverses:YES];
    [shake setFromValue:[NSValue valueWithCGPoint:
                         CGPointMake(viewToShake.center.x,viewToShake.center.y + 5)]];
    [shake setToValue:[NSValue valueWithCGPoint:
                       CGPointMake(viewToShake.center.x, viewToShake.center.y - 5 )]];
    [viewToShake.layer addAnimation:shake forKey:@"position"];
     
}

-(void)setNewFrame:(CGRect)newFrame toView:(UIView*)aView withDuration:(CGFloat)duration
{
    [myTextView setScrollEnabled:NO];
    [UIView animateWithDuration:duration
                          delay:0 options:nil
                     animations:^{
                         aView.frame = newFrame;
                     } completion:^(BOOL finished) {
                             [myTextView setScrollEnabled:YES];
                     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [myTextView setNeedsDisplay];
}

- (void)viewDidUnload
{
    [self setMyNameField:nil];
    [self setTimeText:nil];
    [self setLockButton:nil];
    [self setBackView:nil];
    [super viewDidUnload];
}

@end