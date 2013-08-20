//
//  returnPasswordViewController.h
//  notes
//
//  Created by Oleg Sobolev on 27.06.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface returnPasswordViewController : UIViewController <UIAlertViewDelegate>
{
    NSTimer *timer;
}

@property (weak, nonatomic) IBOutlet UITextView *myTextView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

- (IBAction)tapOnStartButton:(id)sender;

@end
