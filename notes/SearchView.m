//
//  SearchView.m
//  notes
//
//  Created by Samez on 16.05.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "SearchView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SearchView

@synthesize searchField,searchButton;
@synthesize searchingNow;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        oldFrame = frame;
        [self setUpWithFrame:frame];
        searchingNow = NO;
    }
    return self;
}

-(void)hideSearchFieldCursor
{
    searchField.curColor = [UIColor clearColor];
    searchField.cursor_.hidden = YES;
}

-(void)showSearchFieldCursor
{
    searchField.curColor = [UIColor colorWithRed:81.0f/255.0f green:106.0f/255.0f blue:237.0f/255.0f alpha:1.0f];
    searchField.cursor_.hidden = NO;
    [searchField becomeFirstResponder];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self performSelector:@selector(getText) withObject:nil afterDelay:0.05];
    return YES;
}

-(void)getText
{
    [self.delegate searchView:self changeTextTo:[searchField text]];
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self.delegate searchView:self changeTextTo:@""];
    return YES;
}

-(void)startSearching
{
    [searchField setCurColor:[UIColor clearColor]];
    [searchField becomeFirstResponder];
    [self.delegate searchViewWillStartSearching:self];
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         
                         [searchField setAlpha:1.0];
                         
                         CGRect rect = oldFrame;
                         rect.size.width -= 34;
                         searchField.frame = rect;
                         
                     }
                     completion:^(BOOL finished){
                         searchingNow = YES;
                         [delegate searchViewDidBeginSearching:self];
                         [searchField setCurColor:[UIColor colorWithRed:81.0f/255.0f green:106.0f/255.0f blue:237.0f/255.0f alpha:1.0f]];
                     }];
}

-(void)endSearching
{
    [self.delegate searchViewWillEndSearching:self];
    [UIView animateWithDuration:0.3
                          delay:0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         
                         [searchField setAlpha:0.0];
                         [searchField resignFirstResponder];
                         searchField.frame = narrowFieldFrame;
                     }
                     completion:^(BOOL finished){
                         searchingNow = NO;
                         [searchField setText:nil];
                         [delegate searchViewDidEndSearching:self];
                     }];
}

-(void)buttonClick
{
    if (!searchingNow)
        [self startSearching];
    else
        [self endSearching];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

-(void)setUpWithFrame:(CGRect)frame
{
    UIButton *button0 = [UIButton buttonWithType:UIButtonTypeCustom];

    unsearchingButtonRect = CGRectMake(frame.origin.x + frame.size.width/2 -15, frame.origin.y + frame.size.height/2 - 15, 34, 29);
    
    [button0 setFrame: unsearchingButtonRect];
    [button0 setBackgroundImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
    [button0 addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [button0 setShowsTouchWhenHighlighted:YES];
    
    searchButton = button0;
    
    narrowFieldFrame = CGRectMake(frame.origin.x + frame.size.width/2 -15 , frame.origin.y , 1, frame.size.height);
    searchField = [[SearchField alloc] initWithFrame: narrowFieldFrame];
    [searchField setBackgroundColor:[UIColor whiteColor]];

    [searchField setBorderStyle:UITextBorderStyleRoundedRect];
    [searchField setAlpha:0.0];
    searchField.keyboardAppearance = UIKeyboardAppearanceAlert;
    searchField.returnKeyType = UIReturnKeyDone;
    [searchField setSpellCheckingType:UITextSpellCheckingTypeNo];
    [self addSubview:searchField];
    [self addSubview:searchButton];
    [searchField setDelegate:self];
    
    [searchField addObserver:self forKeyPath:@"frame" options:0 context:nil];
    [self observeValueForKeyPath:@"frame" ofObject:searchField change:nil context:nil];
    
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object==searchField)
    {
        CGRect rect = [[object valueForKeyPath:@"frame"] CGRectValue];
        CGRect rect2 = searchButton.frame;

        rect2.origin.x = rect.origin.x + rect.size.width;
        
        searchButton.frame = rect2;
    }
}

@end
