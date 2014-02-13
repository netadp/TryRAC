//
//  FRPAppDelegate.h
//  PhotoGallery
//
//  Created by Jie Huo on 13/2/14.
//  Copyright (c) 2014 Jie Huo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PXAPIHelper *apiHelper;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
