//
//  SearchField.m
//  notes
//
//  Created by Samez on 18.05.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "SearchField.h"

@implementation SearchField

@synthesize curColor;
@synthesize cursor_;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup:self.frame];
    }
    return self;
}

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup:frame];
    }
    return self;
}

- (void) setCursorColor:(UIColor *)cursorColor
{
    cursor_.backgroundColor = cursorColor;
}

- (UIColor *) cursorColor
{
    return cursor_.backgroundColor;
}

- (void)setup:(CGRect)frame
{
    cursor_ = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 2.0f, frame.size.height)];
    [self addSubview:cursor_];
    [cursor_ setBackgroundColor:[UIColor colorWithRed:81.0f/255.0f green:106.0f/255.0f blue:237.0f/255.0f alpha:1.0f]];
    cursor_.hidden = NO;
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
}

-(BOOL)becomeFirstResponder
{
    cursor_.alpha = 1.0f;
    
    [UIView animateWithDuration:0.5f
                          delay:0.6f
                        options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionCurveEaseInOut)
                     animations:^{
                         cursor_.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){}];
    
    return [super becomeFirstResponder];
}

-(BOOL)resignFirstResponder
{
    cursor_.alpha = 0.0f;
    
    return [super resignFirstResponder];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    cursor_.hidden = YES;
    [self bringSubviewToFront:cursor_];
    return [super textRectForBounds:bounds];
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{    
    UITextRange *range = [self selectedTextRange];

    cursor_.hidden = !range.empty;
    
    CGRect rect = [self caretRectForPosition:range.start];
    rect.origin.x = ([self caretRectForPosition:range.start]).origin.x;
    rect.size.width = 3.0f;
    cursor_.frame = rect;
    
    return [super editingRectForBounds:bounds];
}

- (CGRect)caretRectForPosition:(UITextPosition *)position
{
    CGRect rect = [super caretRectForPosition:position];
    rect.size.width = 0.0f;
    return rect;
}

@end
