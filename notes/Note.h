//
//  Note.h
//  notes
//
//  Created by Samez on 03.03.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Note : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * isPrivate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * text;

@end
