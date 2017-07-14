
#import "ViewModel.h"

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
    BOOL isDirectory;
    NSString *path = @"/Users/yangand/Downloads/browser.html";
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    if (fileExists && !isDirectory) {
        NSError *error;
        NSString *text = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        if (text) {
            [self.delegate openHTML:text withAddress:address];
            return;
        }
    }
    [self.delegate open:address];
}

- (void)save:(NSString *)html withAddress:(NSString *)address {
    NSError *error;
    NSString *path = @"/Users/yangand/Downloads/browser.html";
    if (![html writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:&error]) {
        NSLog(@"%@", error);
    }
}

@end
