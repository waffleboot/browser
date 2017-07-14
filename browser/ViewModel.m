
#import "ViewModel.h"
#import "AppDelegate.h"
#import "HTML+CoreDataProperties.h"

@interface ViewModel ()
@property (nonatomic, weak) id<ViewModelDelegate> delegate;
@end

@implementation ViewModel

- (instancetype)initWithDelegate:(id<ViewModelDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
    }
    return self;
}

- (void)open:(NSString *)address {
    NSError *error;
    AppDelegate *appDelegate = (AppDelegate *) [[NSApplication sharedApplication] delegate];
    NSManagedObjectContext *ctx = appDelegate.viewContext;
    NSFetchRequest *fetchRequest = [HTML fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"address == %@", address];
    NSArray<HTML *> *array = [ctx executeFetchRequest:fetchRequest error:&error];
    if (array && array.count) {
        HTML *obj = array.firstObject;
        [self.delegate openHTML:obj.html withAddress:address];
    } else {
        [self.delegate open:address];
    }
}

- (void)save:(NSString *)html withAddress:(NSString *)address {
    NSError *error;
    AppDelegate *appDelegate = (AppDelegate *) [[NSApplication sharedApplication] delegate];
    NSManagedObjectContext *ctx = appDelegate.viewContext;
    NSFetchRequest *fetchRequest = [HTML fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"address == %@", address];
    NSArray<HTML *> *array = [ctx executeFetchRequest:fetchRequest error:&error];
    if (array && array.count) {
        HTML *obj = array.firstObject;
        obj.html  = html;
    } else {
        HTML *obj = [[HTML alloc] initWithContext:ctx];
        obj.html = html;
        obj.address = address;
        [ctx insertObject:obj];
    }
    if (![ctx save:&error]) {
        NSLog(@"%@", error);
    }
}

@end
