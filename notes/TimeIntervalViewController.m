//
//  TimeIntervalViewController.m
//  notes
//
//  Created by Samez on 28.04.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "TimeIntervalViewController.h"
#import "LocalyticsSession.h"

@interface TimeIntervalViewController ()

@end

@implementation TimeIntervalViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        intervalValueArray = [[NSMutableArray alloc] initWithObjects:@0,@(60*60*24*7),@60,@(60*5),@(60*10),@(60*30), nil];
        intervalNameArray = [[NSMutableArray alloc] initWithObjects:@"RIEveryTime",@"RTForOneSession",@"RI1min",@"RI5min",@"RI10min",@"RI30min", nil];

        dotImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dot@2x.png"]];
        
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [[LocalyticsSession shared] tagScreen:@"Time interval"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[self tableView] setBackgroundColor:[UIColor clearColor]];
    
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

-(NSInteger)intervalIndex
{
    NSInteger index = 0;
    
    index = [intervalValueArray indexOfObject:[NSNumber numberWithInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"PasswordRequestInterval"]]];
    
    return index;
}

-(void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    [[cell textLabel] setText:NSLocalizedString(intervalNameArray[indexPath.row], nil)];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (indexPath.row == [self intervalIndex])
    {
        [cell setAccessoryView:dotImage];
        [[cell textLabel] setTextColor:selectedColor];
    } else
    {
        [[cell textLabel] setTextColor:unselectedColor];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedItemColor"];
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    selectedColor = color;
    
    colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"unselectedItemColor"];
    color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    unselectedColor = color;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [UIView transitionWithView:self.tableView
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowAnimatedContent
                    animations:^{
                        UITableViewCell *cell = nil;
                        
                        for (int i = 0; i < 6; ++i)
                        {
                            cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                            if (i != indexPath.row)
                            {
                                [cell setAccessoryView:nil];
                                [[cell textLabel] setTextColor:unselectedColor];
                            } else
                            {
                                [cell setAccessoryView:dotImage];
                                [[cell textLabel] setTextColor:selectedColor];
                            }
                        }

                    }
                    completion:nil];
    
    NSInteger interval = 0;
    
    interval = [intervalValueArray[indexPath.row] integerValue];
    
    [[NSUserDefaults standardUserDefaults] setInteger:interval forKey:@"PasswordRequestInterval"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSince1970:1] forKey:@"lastTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
