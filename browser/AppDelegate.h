//
//  AppDelegate.h
//  browser
//
//  Created by Андрей on 14.07.17.
//  Copyright © 2017 yangand. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (nonatomic, readonly) NSManagedObjectContext *viewContext;
@end

