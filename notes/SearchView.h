//
//  SearchView.h
//  notes
//
//  Created by Samez on 16.05.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchField.h"

@protocol SearchViewDelegate;

@interface SearchView : UIView <UITextFieldDelegate>
{
    SearchField *searchField;
    UIButton *searchButton;
    
    CGRect unsearchingButtonRect;
    CGRect oldFrame;
    CGRect narrowFieldFrame;
    
    BOOL searchingNow;
    
    id <SearchViewDelegate> delegate;
}

@property id <SearchViewDelegate> delegate;
@property UITextField *searchField;
@property UIButton *searchButton;
@property BOOL searchingNow;

-(void)buttonClick;
-(void)hideSearchFieldCursor;

@end

@protocol SearchViewDelegate <NSObject>
@optional
-(void)searchView:(SearchView *) sender changeTextTo:(NSString*)text;
-(BOOL)searchViewWillStartSearching:(SearchView *) sender;
-(BOOL)searchViewWillEndSearching:(SearchView *) sender;
-(void)searchViewDidBeginSearching:(SearchView *) sender ;
-(void)searchViewDidEndSearching:(SearchView *) sender ;
@end