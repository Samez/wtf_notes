//
//  FontTableViewController.m
//  notes
//
//  Created by Samez on 24.05.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "FontTableViewController.h"
#import "FontPickingViewController.h"

@implementation FontTableViewController

@synthesize fontSizeCell;
@synthesize fontCell;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        fontsArray = [[NSMutableArray alloc] initWithObjects:@"HelveticaNeue",@"Thonburi",@"Verdana",@"GillSans", nil];
        dotImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dot@2x.png"]];
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedString(@"FontLabel", nil)];
    
    [[[self navigationController]navigationBar] setBarStyle:UIBarStyleBlack];
    
    UIImageView *backgroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"woodenBackground.png"]];
    
    [[self tableView] setBackgroundView:backgroundImageView];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedItemColor"];
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    selectedColor = color;
    
    colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"unselectedItemColor"];
    color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    unselectedColor = color;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = 0;
    
    switch(section)
    {
        case 0:
            rows = 1;
            break;
            
        case 1:
            rows = [fontsArray count];
            break;
    }
    
    return rows;
}

-(void)configureFontSizeCell:(FontSizeCell*)cell withidentificator:(NSString*)_identificator
{
    [cell setupWithIdentificator:_identificator];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
}

-(void)configureCell:(UITableViewCell*)cell AtIndexPath:(NSIndexPath*)indexPath
{
    [[cell textLabel] setText:fontsArray[indexPath.row]];
    [[cell textLabel] setFont:[UIFont fontWithName:fontsArray[indexPath.row] size:17]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if ([[[cell textLabel] text] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"noteNameFont"]])
    {
        [cell setAccessoryView:dotImage];
        [[cell textLabel] setTextColor:selectedColor];
    } else
        [[cell textLabel] setTextColor:unselectedColor];
     
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    static NSString *MyFontSizeCellIdentifier = @"FontSizeCell";
    FontSizeCell * fontC = [tableView dequeueReusableCellWithIdentifier:MyFontSizeCellIdentifier];
    
    if (!fontC)
    {
        [[NSBundle mainBundle] loadNibNamed:@"FontSizeCell" owner:self options:nil];
        fontC = fontSizeCell;
        fontSizeCell = nil;
    }
    
    UITableViewCell *cellToReturn = nil;
    
    switch(indexPath.section)
    {
        case 0:
        {
            [self configureFontSizeCell:fontC withidentificator:@"noteTextFontSize"];
            cellToReturn = fontC;
            break;
        }
        case 1:
        {
            [self configureCell:cell AtIndexPath:indexPath];
            cellToReturn = cell;
            break;
        }
    }

    return cellToReturn;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        [UIView transitionWithView:self.tableView
                          duration:0.4
                           options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowAnimatedContent
                        animations:^{
                            for (int i = 0; i < [fontsArray count]; ++i)
                            {
                                UITableViewCell* cell = nil;
                                cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
                                
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
                        completion:^(BOOL finished) {
                            [[NSUserDefaults standardUserDefaults] setObject:fontsArray[indexPath.row] forKey:@"noteNameFont"];
                            [[NSUserDefaults standardUserDefaults] setObject:fontsArray[indexPath.row] forKey:@"noteTextFont"];
                        }];
    }
    
}

- (void)viewDidUnload
{
    [self setFontSizeCell:nil];
    [self setFontCell:nil];
    [self setFontCell:nil];
    [super viewDidUnload];
}
@end
