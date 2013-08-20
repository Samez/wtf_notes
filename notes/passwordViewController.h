//
//  passwordViewController.h
//  notes
//
//  Created by Samez on 26.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "passwordCell.h"
#import "DetectorView.h"

@interface passwordViewController : UITableViewController <UITextFieldDelegate>
{
    DetectorView *detectorView;
    
    NSString *bottomTitle;
    NSString *forOldPassword;
    
    BOOL showingNow;
    int rowsCount;
}

@property (strong, nonatomic) IBOutlet passwordCell *pswdCell;

@property (nonatomic,retain) NSString *pass;

@end
