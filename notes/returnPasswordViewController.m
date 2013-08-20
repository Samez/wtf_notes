//
//  returnPasswordViewController.m
//  notes
//
//  Created by Oleg Sobolev on 27.06.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "returnPasswordViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "res.h"

@interface returnPasswordViewController ()

@end

@implementation returnPasswordViewController

@synthesize startButton, myTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

-(void) updateCountdown
{
    NSTimeInterval diff = [[[NSUserDefaults standardUserDefaults] objectForKey:@"callResetPasswordTime"] timeIntervalSinceNow];
    
    if (abs(diff) >= (12*60*60))
    {
        [timer invalidate];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"pass" forKey:@"password"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"callResetPasswordTime"];
        
        [myTextView setText:NSLocalizedString(@"passwordWasReseted", nil)];
        [startButton setEnabled:NO];
        [startButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [startButton setTitle:NSLocalizedString(@"ResetButton", nil) forState:UIControlStateDisabled];

        CGRect rect = myTextView.frame;
        
        rect.size.height = [myTextView contentSize].height + 15;
        
        [UIView animateWithDuration:0.3 delay:0 options:nil
                         animations:^{
                             myTextView.frame = rect;
                         } completion:^(BOOL finished) {
                             
                         }];
    } else
    {        
        NSTimeInterval diff = [[[NSUserDefaults standardUserDefaults] objectForKey:@"callResetPasswordTime"] timeIntervalSinceNow];
        int ihours = abs(diff)/(60*60);
        int iminutes = (abs(diff) - ihours*60*60) / 60;
        int iseconds = abs(diff) - iminutes*60 - ihours*60*60;

        NSString *hours =[NSString stringWithFormat:@"%02d",(11-ihours)];
        NSString *minuts =[NSString stringWithFormat:@"%02d",(59-iminutes)];
        NSString *seconds =[NSString stringWithFormat:@"%02d",(59-iseconds)];
        NSString *countdonwTimerTimeLeftLabel = NSLocalizedString(@"countdonwTimerTimeLeftLabel", nil);

        NSString *countdown = [NSString stringWithFormat:@"%@%@ : %@ : %@",countdonwTimerTimeLeftLabel,hours,minuts,seconds];
        [startButton setTitle:countdown forState:UIControlStateNormal];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:NSLocalizedString(@"resetPasswordControllerTitle", nil)];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"woodenBackground.png"]]];
    
    [startButton setTitle:NSLocalizedString(@"ResetButton", nil) forState:UIControlStateNormal];
    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"password"] isEqualToString:@"pass1"])
    {
        [myTextView setText:NSLocalizedString(@"passwordIsAllreadyDefault", nil)];
        [startButton setEnabled:NO];
        [startButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    } else
    {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"callResetPasswordTime"] == nil)
        {
            [myTextView setText:NSLocalizedString(@"ReturnPasswordTextWarning", nil)];
            [startButton setTintColor:[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.6]];
            [startButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        } else
        {
            NSTimeInterval diff = [[[NSUserDefaults standardUserDefaults] objectForKey:@"callResetPasswordTime"] timeIntervalSinceNow];
            
            if (ABS(diff) < (12*60*60-1))
            {
                [myTextView setText:NSLocalizedString(@"ResetPasswordActive", nil)];
                [startButton setEnabled:NO];
                [startButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
                
                timer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target:self selector:@selector(updateCountdown) userInfo:nil repeats: YES];
            } else
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"pass" forKey:@"password"];
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"callResetPasswordTime"];
                
                [myTextView setText:NSLocalizedString(@"passwordIsAllreadyDefault", nil)];
                [startButton setEnabled:NO];
                [startButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];   
            }
        }
    }
    
    CGRect rect = myTextView.frame;

    rect.size.height = [myTextView contentSize].height;
    rect.origin.y = 15;
    
    myTextView.frame = rect;
    myTextView.layer.cornerRadius = 5;
    myTextView.clipsToBounds = YES;
    
    rect = startButton.frame;
    rect.origin.y = myTextView.frame.origin.y + myTextView.frame.size.height + 15;
    
    startButton.frame = rect;
    
    [self.view addObserver:self forKeyPath:@"frame" options:0 context:nil];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    CGRect myRect = myTextView.frame;
    
    myRect.size.height = [myTextView contentSize].height;
    
    myTextView.frame = myRect;
    
    CGRect newRect = startButton.frame;
    
    newRect.origin.y = myTextView.frame.origin.y + myTextView.frame.size.height + 15;
    startButton.frame = newRect;
}

- (IBAction)tapOnStartButton:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"callResetPasswordTime"];
    
    timer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target:self selector:@selector(updateCountdown) userInfo:nil repeats: YES];
    
    [startButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    
    [myTextView setText:NSLocalizedString(@"ResetPasswordActive", nil)];
    
    CGRect rect = myTextView.frame;
    
    rect.size.height = [myTextView contentSize].height;
    
    
    CGRect newRect = startButton.frame;
    
    newRect.origin.y = rect.origin.y + rect.size.height + 15;
    
    [UIView animateWithDuration:0.3 delay:0 options:nil
                     animations:^{
                         myTextView.frame = rect;
                         startButton.frame = newRect;
                     } completion:^(BOOL finished) {
                         
                     }];
    
    [startButton setEnabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.view removeObserver:self forKeyPath:@"frame"];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [self setMyTextView:nil];
    [self setStartButton:nil];
    [super viewDidUnload];
}

@end
