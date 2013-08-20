//
//  passwordViewController.m
//  notes
//
//  Created by Samez on 26.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "passwordViewController.h"
#import "LocalyticsSession.h"
#import "strenghtPasswordChecker.h"
#import "res.h"

@interface passwordViewController ()

@end

@implementation passwordViewController

@synthesize pass;
@synthesize pswdCell;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        rowsCount =  0;
        bottomTitle = nil;
        forOldPassword = nil;
        showingNow = NO;
        detectorView = [[DetectorView alloc] initWithFrame:CGRectMake(0, 0, 100, 10)];
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    forOldPassword = nil;
    bottomTitle = nil;
    [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:0 ] withRowAnimation:UITableViewRowAnimationNone];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self.navigationItem leftBarButtonItem] setAction:@selector(cancel)];
    
    [[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlack];
    
    pass = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];


    [[self tableView] setAllowsSelection:NO];
    
    [[self tableView] setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *backgroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"woodenBackground.png"]];
    
    [[self tableView] setBackgroundView:backgroundImageView];
    
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([pass isEqualToString:@"Password"])
    {
        forOldPassword = pass;
        
        [self showBottomTitle:NSLocalizedString(@"StandartPasswordWarning", nil)];
    }
    
    [[LocalyticsSession shared] tagScreen:@"Password"];
}

-(void)dismissKeyboard
{
    for (int i = 0; i < 3; ++i)
    {
        [[(passwordCell*)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] passwordField] resignFirstResponder];
    }
}

-(void)showBottomTitle:(NSString*)title
{
    if (!showingNow)
    {
        showingNow = YES;
        bottomTitle = nil;
        
        if ([title isEqualToString:NSLocalizedString(@"PasswordWasChangeNotification", nil)])
            forOldPassword = nil;
        
        [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:0 ] withRowAnimation:UITableViewRowAnimationNone];
        [UIView animateWithDuration:0.5
                              delay:0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             bottomTitle = title;
                             
                             [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:0 ] withRowAnimation:UITableViewRowAnimationNone];
                             
                             if ([title isEqualToString:NSLocalizedString(@"PasswordWasChangeNotification", nil)])
                             {
                                 [[[[self tableView] footerViewForSection:0] textLabel] setTextColor:[UIColor greenColor]];
                             }
                             else
                                 [[[[self tableView] footerViewForSection:0] textLabel] setTextColor:[UIColor redColor]];
                             
                             [[[[self tableView] footerViewForSection:0] textLabel] setShadowColor:[UIColor clearColor]];
                         }
                         completion:^(BOOL finished){
                             showingNow = NO;
                         }];
    }
}

-(void)cancel
{
    [[self navigationController] popViewControllerAnimated:YES];
}

-(BOOL)compareNewPasswordOne:(NSString*)passwordOne andNewPasswordTwo:(NSString*)passwordTwo
{
    BOOL flag = NO;
    
    if ([passwordOne isEqualToString:passwordTwo])
    {
        if ([passwordOne length]>=_PASSWORD_MIN_LENGTH)
        {
            [self showBottomTitle:NSLocalizedString(@"PasswordWasChangeNotification", nil)];
            flag = YES;
        } else
        {
            [self showBottomTitle:NSLocalizedString(@"TooShortPasswordWarning", nil)];
            flag = NO;
        }
    } else
    {
        [self showBottomTitle:NSLocalizedString(@"PasswordsAreNotEqualWarning", nil)];
        flag = NO;
    }
    
    return flag;
}

-(BOOL)compareOldPassword:(NSString*)oldPassword andNewPassword:(NSString*)newPassword
{
    BOOL flag = NO;
    
    if ([oldPassword isEqualToString:newPassword])
    {
        forOldPassword = oldPassword;
        flag = YES;
    }
    else
    {
        forOldPassword = nil;
        [self showBottomTitle:NSLocalizedString(@"IncorrectOldPasswordWarning", nil)];
        flag = NO;
    }
    return flag;
}

-(void)save
{
    NSString *oldPass = nil;
    NSString *newPassOne = nil;
    NSString *newPassTwo = nil;
    
    if (pass != nil)
    {
        oldPass = [[((passwordCell*)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]) passwordField] text];
        newPassOne = [[((passwordCell*)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]) passwordField] text];
        newPassTwo = [[((passwordCell*)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]]) passwordField] text];
        
        if ([self compareOldPassword:pass andNewPassword:oldPass])
        {
            if ([self compareNewPasswordOne:newPassOne andNewPasswordTwo:newPassTwo])
            {
                pass = newPassOne;
                [self savePass];
            }
        }
    } else
    {
        newPassOne = [[((passwordCell*)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]) passwordField] text];
        newPassTwo = [[((passwordCell*)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]) passwordField] text];
        
        if ([self compareNewPasswordOne:newPassOne andNewPasswordTwo:newPassTwo])
        {
            pass = newPassOne;
            [self savePass];
        }
    }
    
    [detectorView setCountOfSectors:0];
    [detectorView setNeedsDisplay];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *title = nil;

    switch (section)
    {
        case 0:
            title = bottomTitle;
            break;
    }
    
    return title;
}

-(void)savePass
{
    [[NSUserDefaults standardUserDefaults] setObject:pass forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"callResetPasswordTime"];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField tag] == _NEW1)
    {
        [self performSelector:@selector(check) withObject:nil afterDelay:0.05];
    }
    return YES;
}

-(void)check
{
    NSString *checkString = [[(passwordCell*)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] passwordField] text];
    
    if([checkString length] == 0)
        [detectorView setCountOfSectors:0];
    else
        [detectorView setCountOfSectors:[RegExUtils checkPasswordStrength:checkString]+1];
    
    [detectorView setNeedsDisplay];
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    if ([textField tag] == _NEW1)
    {
        [detectorView setCountOfSectors:0];
        [detectorView setNeedsDisplay];
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    switch ([textField tag])
    {
        case _OLD:
        {
            [textField resignFirstResponder];
            [[(passwordCell*)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] passwordField] becomeFirstResponder];
            break;
        }
        case _NEW1:
        {
            [textField resignFirstResponder];
            [[(passwordCell*)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] passwordField] becomeFirstResponder];
            break;
        }
        case _NEW2:
        {
            [textField resignFirstResponder];
            [self save];
            break;
        }
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (pass)
        return 3;
    else
        return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *passCellIdentifier = @"pswdCell";
    
    passwordCell *passCell = [tableView dequeueReusableCellWithIdentifier:passCellIdentifier];
    
    if (passCell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"passwordCell" owner:self options:nil];
        passCell = [topLevelObjects objectAtIndex:0];
    }
    
    switch ([indexPath section])
    {
        case 0:
        {
            switch ([indexPath row])
            {
                case 0:
                {
                    if (pass)
                    {
                        [[passCell passwordField] setPlaceholder:NSLocalizedString(@"EnterOldPasswordLabel", nil)];
                    } else
                    {
                        [[passCell passwordField] setPlaceholder:NSLocalizedString(@"EnterNewPasswordLabel", nil)];
                    }
                    
                    if (forOldPassword)
                        [[passCell passwordField] setText:forOldPassword];
                    
                    [[passCell passwordField] setTag:_OLD];
                    [[passCell passwordField] setReturnKeyType:UIReturnKeyNext];
                    
                    break;
                }
                    
                case 1:
                {
                    [[passCell passwordField] setPlaceholder:NSLocalizedString(@"EnterNewPasswordLabel", nil)];
                    [[passCell passwordField] setTag:_NEW1];
                    [[passCell passwordField] setReturnKeyType:UIReturnKeyNext];
                    
                    CGRect frameForDetectorView = passCell.frame;
                    
                    frameForDetectorView.size.height = 5;
                    frameForDetectorView.size.width-=20;
                    frameForDetectorView.origin.x+=10;
                    
                    [detectorView setFrame:frameForDetectorView];
                    [detectorView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
                    
                    [passCell addSubview:detectorView];
                    
                    break;
                }
                case 2:
                {
                    [[passCell passwordField] setPlaceholder:NSLocalizedString(@"RepeatNewPasswordLabel", nil)];
                    [[passCell passwordField] setTag:_NEW2];
                    [[passCell passwordField] setReturnKeyType:UIReturnKeyDone];

                    break;
                }
            }
        }
    }
    
    [[passCell passwordField] setDelegate:self];
    [[passCell passwordField] setSecureTextEntry:YES];
    
    passCell.passwordField.keyboardAppearance = UIKeyboardAppearanceAlert;
    
    return passCell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)viewDidUnload
{
    [self setPswdCell:nil];
    [super viewDidUnload];
}
@end
