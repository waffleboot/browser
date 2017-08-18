
#import "BrowserModel.h"
#import "HTML+CoreDataProperties.h"
#import "NSURL+Browser.h"
@import CoreData;

@interface BrowserModel ()
@property (nonatomic) NSPersistentContainer *persistentContainer;
@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@end

@implementation BrowserModel

+ (instancetype)sharedModel {
    static dispatch_once_t onceToken;
    static BrowserModel *instance;
    dispatch_once(&onceToken, ^{
        instance = [[BrowserModel alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (HTML *)getHtmlObjByURL:(NSURL *)url {
    NSError *error;
    NSFetchRequest *fetchRequest = [HTML fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"address == %@", url.canonicalURL.relativeString];
    NSArray<HTML *> *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return array.firstObject;
}

- (NSString *)getHtmlByURL:(NSURL *)url {
    return [self getHtmlObjByURL:url].html;
}

- (void)saveHTML:(NSString *)html forURL:(NSURL *)url {
    HTML *obj = [self getHtmlObjByURL:url];
    if (obj) {
        obj.html = html;
    } else {
        HTML *obj = [[HTML alloc] initWithContext:self.managedObjectContext];
        obj.html = html;
        obj.address = url.canonicalURL.relativeString;
    }
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"%@", error);
    }
}

- (void)deleteHTML:(NSURL *)url {
    HTML *obj = [self getHtmlObjByURL:url];
    if (obj) {
        NSError *error;
        [self.managedObjectContext deleteObject:obj];
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"%@", error);
        }
    }
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

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    _managedObjectContext = self.persistentContainer.viewContext;
    return _managedObjectContext;
}

@end
