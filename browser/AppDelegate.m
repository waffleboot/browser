//
//  AppDelegate.m
//  browser
//
//  Created by Андрей on 14.07.17.
//  Copyright © 2017 yangand. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (nonatomic) NSPersistentContainer *persistentContainer;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (NSPersistentContainer *)persistentContainer {
    if (_persistentContainer != nil) {
        return _persistentContainer;
    }
    _persistentContainer = [NSPersistentContainer persistentContainerWithName:@"Browser"];
    [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *persistentStoreDescription, NSError *error) {
        if (error != nil) {
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        }
    }];
    return _persistentContainer;
}

- (NSManagedObjectContext *)viewContext {
    return self.persistentContainer.viewContext;
}

@end
