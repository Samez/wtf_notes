//
//  OptionsViewController.m
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "OptionsViewController.h"
#import "passwordViewController.h"
#import "TimeIntervalViewController.h"
#import "res.h"
#import "TwoCaseCell.h"
#import "Switchy.h"
#import "LocalyticsSession.h"
#import "notesListViewController.h"
#import "FontTableViewController.h"
#import "returnPasswordViewController.h"

@interface OptionsViewController ()

@property UIBarButtonItem* goToNotesListButton;

@end

@implementation OptionsViewController

@synthesize mySwitchCell;
@synthesize NLC;
@synthesize goToNotesListButton;
@synthesize returnPasswordCell;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        intervalValueArray = [[NSMutableArray alloc] initWithObjects:@0,@(60*60*24*7),@60,@(60*5),@(60*10),@(60*30), nil];
        intervalNameArray = [[NSMutableArray alloc] initWithObjects:@"RIEveryTime",@"RTForOneSession",@"RI1min",@"RI5min",@"RI10min",@"RI30min", nil];
    }
    return self;
}

-(void)setButton
{
    [[self navigationItem] setLeftBarButtonItem:goToNotesListButton animated:YES];
}

-(void)setTitle
{
    [self setTitle:NSLocalizedString(@"OptionsTitle", nil)];
}

-(void)setupButtons
{
    UIImage* image = [UIImage imageNamed:@"list2.png"];
    CGRect frameimg = CGRectMake(12, 0, 23, 23);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image forState:UIControlStateNormal];
    [someButton addTarget:self action:@selector(toNotes)
         forControlEvents:UIControlEventTouchUpInside];
    [someButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *bufButton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
    self.goToNotesListButton=bufButton;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performSelector:@selector(setButton) withObject:nil afterDelay:0.8];
    [self performSelector:@selector(setTitle) withObject:nil afterDelay:0.95];
    
    [[LocalyticsSession shared] tagScreen:@"Options"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self LoadSettings];
    [self.tableView reloadData];
}

- (void) LoadSettings
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"unsafeDeletion"] != nil)
    {
        unsafeDeletion = [[NSUserDefaults standardUserDefaults] boolForKey:@"unsafeDeletion"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"swipeColor"] != nil)
    {
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"swipeColor"];
        UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
        
        if ([color isEqual:[UIColor sashaGray]])
            swipeColorIsRed = NO;
        else
            swipeColorIsRed = YES;
    }
}

-(void)unsafeDeletionWasChanged
{
    CellWithSwitcher *cell = (CellWithSwitcher*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_UNSAFE_DELETION inSection:_SORT_SECTION]];
    
    unsafeDeletion = [[cell stateSwitcher] isOn];
    
    [[NSUserDefaults standardUserDefaults] setBool: unsafeDeletion forKey: @"unsafeDeletion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)toNotes
{
    [UIView transitionFromView:self.view
                        toView:NLC.view
                      duration:1.0
                       options:UIViewAnimationOptionTransitionCurlDown
                    completion:nil];
    
    [[self navigationItem] setLeftBarButtonItem:nil animated:YES];
    
    [self.navigationController popToViewController:NLC animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupButtons];
    
    self.navigationItem.hidesBackButton = YES;
    
    
    
    [[[self navigationController]navigationBar] setBarStyle:UIBarStyleBlack];
    
    UIImageView *backgroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"woodenBackground.png"]];
    
    [[self tableView] setBackgroundView:backgroundImageView];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    switch (section)
    {
        case _VISUAL_SECTION:
            count = 1;
            break;
        case _SECURITY_SECTION:
            count = 3;
            break;
        case _SORT_SECTION:
            count = 1;
            break;
    }
    
    return count;
}

-(UITableViewCell*)configureFontCell
{
    static NSString *fontCellIdentifier = @"fontCell";
    
    UITableViewCell *fontCell = [self.tableView dequeueReusableCellWithIdentifier:fontCellIdentifier];
    
    if (!fontCell)
    {
        fontCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:fontCellIdentifier];
    }
    
    [fontCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [fontCell setSelectionStyle:UITableViewCellSelectionStyleGray];
    [[fontCell textLabel] setText:NSLocalizedString(@"FontLabel", nil)];
    
    return fontCell;
}

-(UITableViewCell*)configurePasswordRequestIntervalCell
{
    UITableViewCell *intervalCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    [[intervalCell textLabel] setText:NSLocalizedString(@"PasswordRequestIntervalCell", nil)];
    
    [[intervalCell detailTextLabel] setText:NSLocalizedString(@"PasswordRequestInterval", nil)];
    
    [intervalCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    int index = [intervalValueArray indexOfObject:[NSNumber numberWithInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"PasswordRequestInterval"]]];
    
    [[intervalCell detailTextLabel] setText:NSLocalizedString(intervalNameArray[index], nil)];
    
    [[intervalCell detailTextLabel] setTextColor:[UIColor blackColor]];
    
    return intervalCell;
}

-(UITableViewCell*)configureChangePasswordCell
{
    static NSString *passwordCellIdentifier = @"passwordCell";
    
    UITableViewCell *passwordCell = [self.tableView dequeueReusableCellWithIdentifier:passwordCellIdentifier];
    
    if (!passwordCell)
    {
        passwordCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:passwordCellIdentifier];
    }
    
    [[passwordCell textLabel] setText:NSLocalizedString(@"ChangePasswordCell", nil)];
    
    [passwordCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [passwordCell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    return passwordCell;
}

-(ReturnPasswordCell*)configureReturnPasswordCell
{
    static NSString *MyCellIdentifier = @"ReturnPasswordCell";
    
    
    ReturnPasswordCell *returnPswdCell = [self.tableView dequeueReusableCellWithIdentifier:MyCellIdentifier];
    
    if (!returnPswdCell)
    {
        [[NSBundle mainBundle] loadNibNamed:@"ReturnPasswordCell" owner:self options:nil];
        
        returnPswdCell = returnPasswordCell;
        
        returnPasswordCell = nil;
    }
    
    [[returnPswdCell textLabel] setText:NSLocalizedString(@"returnPasswordCell", nil)];
    [returnPswdCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [returnPswdCell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    return returnPswdCell;
}

-(CellWithSwitcher*)configureUnsafeDeletionCell
{
    static NSString *MyCellIdentifier = @"CellWithSwitcher";
    
    CellWithSwitcher *MYcell = [self.tableView dequeueReusableCellWithIdentifier:MyCellIdentifier];
    
    if (!MYcell)
    {
        [[NSBundle mainBundle] loadNibNamed:@"CellWithSwitcher" owner:self options:nil];
        
        MYcell = mySwitchCell;
        
        mySwitchCell = nil;
    }
    
    [[MYcell myTextLabel] setText:NSLocalizedString(@"unsafeDetetionCell", nil)];
    
    [MYcell.stateSwitcher addTarget:self action:@selector(unsafeDeletionWasChanged) forControlEvents:UIControlEventValueChanged];
    
    [[MYcell stateSwitcher] setOn:unsafeDeletion];
    
    [MYcell setSelectionStyle:UITableViewCellSelectionStyleNone];
    UIFont *myFont = [ UIFont fontWithName: @"Helvetica-Bold" size: 17.0];
    [[MYcell myTextLabel] setFont:myFont];
    
    return MYcell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    switch (indexPath.section)
    {
        case _VISUAL_SECTION:
        {
            cell = [self configureFontCell];
            break;
        }
        case _SECURITY_SECTION:
        {
            switch(indexPath.row)
            {
                case _PSWD_REQUEST_INTERVAL:
                {
                    cell = [self configurePasswordRequestIntervalCell];
                    break;
                }
                case _PSWD:
                {   
                    cell = [self configureChangePasswordCell];
                    break;
                }
                case _PSWD_RETURN:
                {
                    cell = [self configureReturnPasswordCell];
                    break;
                }
            }
            break;
        }
        case _SORT_SECTION:
        {
            cell = [self configureUnsafeDeletionCell];
            break;
        }
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *nextViewController = nil;

    switch ([indexPath section])
    {
        case _VISUAL_SECTION:
        {
            nextViewController = [[FontTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            break;
        }
        case _SECURITY_SECTION:
        {
            switch (indexPath.row)
            {
                case _PSWD:
                {
                    nextViewController = [[passwordViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    break;
                }
                case _PSWD_REQUEST_INTERVAL:
                {
                    nextViewController = [[TimeIntervalViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    break;
                }
                case _PSWD_RETURN:
                {
                    nextViewController = [[returnPasswordViewController alloc] init];
                    break;
                }
            }
        break;
        }
    }
    
    if (nextViewController)
    {
        [[self navigationController] pushViewController:nextViewController animated:YES];
    }
}

- (void)viewDidUnload
{
    [self setReturnPasswordCell:nil];
    [super viewDidUnload];
}

@end
