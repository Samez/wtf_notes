//
//  AppDelegate.m
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "AppDelegate.h"
#import "res.h"
#import "LocalyticsSession.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize notesListController;
@synthesize window;
@synthesize notesNavController;

-(void) applicationDidFinishLaunching:(UIApplication *)application
{
    [self LoadSettings];

    [notesListController setManagedObjectContext:[self managedObjectContext]];
    
    [window setRootViewController:notesNavController];
    
    [application setApplicationSupportsShakeToEdit:YES];
    
    //для сбора статистики
    [[LocalyticsSession shared] startSession:@"76ff7f96b13702a3e4d0fe0-ebd89cd8-b0f7-11e2-882a-005cf8cbabd8"];
    [[LocalyticsSession shared] setLoggingEnabled:NO];
    
    //если производилась активация сброса пароля
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"callResetPasswordTime"] != nil)
    {
        NSTimeInterval diff = [[[NSUserDefaults standardUserDefaults] objectForKey:@"callResetPasswordTime"] timeIntervalSinceNow];
        
        //если время истекло, то сбрасываем пароль
        if (abs(diff) >= (12*60*60))
        {        
            [[NSUserDefaults standardUserDefaults] setObject:@"pass" forKey:@"password"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"callResetPasswordTime"];

        }
    }
    
    [[self window] makeKeyAndVisible];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[LocalyticsSession shared] close];
    [[LocalyticsSession shared] upload];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"applicationReturnedFromBackground"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[LocalyticsSession shared] resume];
    [[LocalyticsSession shared] upload];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSince1970:1] forKey:@"lastTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) LoadSettings
{
    //пароль
    if ([[NSUserDefaults standardUserDefaults] objectForKey: @"password"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"pass" forKey:@"password"];
    }
    
    //удаление незапароленной записи жестом без подтверждения
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"unsafeDeletion"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"unsafeDeletion"];
    }
    
    //цвет выделенной ячейки
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"swipeColor"] == nil)
    {
        //NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:1 green:0 blue:0 alpha:0.8]];
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor sashaGray]];
        [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"swipeColor"];
    }
    
    //интервал, в течении которого пароль не запрашивается повторно, после первого ввода
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"PasswordRequestInterval"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"PasswordRequestInterval"];
    }
    
    //
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"lastTime"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSince1970:0]forKey:@"lastTime"];
    }

    //Размер шрифта для названия заметки
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"noteNameFontSize"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setFloat:18.0 forKey:@"noteNameFontSize"];
    }
    
    //Размер шрифта для текста заметки
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"noteTextFontSize"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setFloat:14.0 forKey:@"noteTextFontSize"];
    }
    
    //Шрифт для названия заметки
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"noteNameFont"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"HelveticaNeue" forKey:@"noteNameFont"];
    }
    
    //Шрифт для текста заметки
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"noteTextFont"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"HelveticaNeue" forKey:@"noteTextFont"];
    }
    
    //Цвет текста для ячейки отмеченной чекбоксом
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"selectedItemColor"] == nil)
    {
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor blackColor]];
        [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"selectedItemColor"];
    }

    //Цвет текста для ячейки не отмеченной чекбоксом
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"unselectedItemColor"] == nil)
    {
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"unselectedItemColor"];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveContext];
    [[LocalyticsSession shared] close];
    [[LocalyticsSession shared] upload];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSince1970:1] forKey:@"lastTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    
    if (managedObjectContext != nil)
    {
        [managedObjectContext save:&error];
    }
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Model10.2" ofType:@"momd"];
    NSURL *momURL = [NSURL fileURLWithPath:path];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model10.2.sqlite"];
    
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
