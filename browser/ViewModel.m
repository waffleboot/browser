
#import "ViewModel.h"
#import "AppDelegate.h"
#import "HTML+CoreDataProperties.h"

@interface ViewModel ()
@property (nonatomic, weak) id<ViewModelDelegate> delegate;
@property (nonatomic) NSUndoManager *undoManager;
@end

@implementation ViewModel

- (instancetype)initWithDelegate:(id<ViewModelDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        _undoManager = [[NSUndoManager alloc] init];
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
    [[NSUserDefaults standardUserDefaults] setObject:address forKey:@"latest"];
}

- (void)save:(NSString *)html withAddress:(NSString *)address {
    [self save:html withAddress:address undo:NO];
}

- (void)save:(NSString *)html withAddress:(NSString *)address undo:(BOOL)undo {
    NSError *error;
    AppDelegate *appDelegate = (AppDelegate *) [[NSApplication sharedApplication] delegate];
    NSManagedObjectContext *ctx = appDelegate.viewContext;
    NSFetchRequest *fetchRequest = [HTML fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"address == %@", address];
    NSArray<HTML *> *array = [ctx executeFetchRequest:fetchRequest error:&error];
    if (array && array.count) {
        HTML *obj = array.firstObject;
        if (!undo) {
            ViewModel *vm = (ViewModel *) [self.undoManager prepareWithInvocationTarget:self];
            [vm save:obj.html withAddress:address undo:YES];
        }
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
    if (undo) {
        [self open:address];
    }
}

- (void)openLatest {
    NSString *latest = [[NSUserDefaults standardUserDefaults] stringForKey:@"latest"];
    if (latest) {
        [self open:latest];
    }
}

- (void)undo {
    [self.undoManager undo];
}

- (void)reload:(NSString *)address {
    [self.delegate open:address];
}

@end
