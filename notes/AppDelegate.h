//
//  AppDelegate.h
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "notesListViewController.h"
#import "OptionsViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,
                                      NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (weak, nonatomic) IBOutlet UINavigationController *notesNavController;
@property (weak, nonatomic) IBOutlet notesListViewController *notesListController;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
