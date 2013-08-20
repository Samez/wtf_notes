//
//  res.h
//  notes
//
//  Created by Samez on 10.04.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#ifndef notes_res_h
#define notes_res_h

//Note list
#define  _SHIFT_CELL_LENGTH 32
//End

//Options controller
#define _VISUAL_SECTION 0
#define _FONT 0

#define _SORT_SECTION 1
#define _UNSAFE_DELETION 0

#define _SECURITY_SECTION 2
#define _PSWD_REQUEST_INTERVAL 0
#define _PSWD 1
#define _PSWD_RETURN 2
//End

//Change password controller
#define _OLD 100
#define _NEW1 101
#define _NEW2 102
#define _PASSWORD_MIN_LENGTH 4
//End

@interface UIColor (Extensions)

+(UIColor *) sashaGray;

@end

@implementation UIColor (Extensions)

+ (UIColor *)sashaGray
{
    return [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.3];
}

@end

#endif
