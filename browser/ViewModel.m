
#import "ViewModel.h"
#import "BrowserModel.h"
#import "NSURL+Browser.h"

@interface ViewModel ()
@property (nonatomic, weak) id<ViewModelDelegate> delegate;
@property (nonatomic) NSUndoManager *undoManager;
@end

@implementation ViewModel

- (instancetype)initWithDelegate:(id<ViewModelDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        _undoManager = [[NSUndoManager alloc] init];
        _undoManager.levelsOfUndo = 10;
    }
    return self;
}

- (void)openPageWithAddress:(NSString *)address {
    [self openPageWithURL:[NSURL URLWithBrowserString:address]];
}

- (void)openPageWithURL:(NSURL *)url {
    NSString *recentAddress = [[NSUserDefaults standardUserDefaults] objectForKey:@"recentAddress"];
    NSURL *recentURL = [NSURL URLWithBrowserString:recentAddress];
    if (![recentURL.canonicalURL isEqualTo:url.canonicalURL]) {
        [[NSUserDefaults standardUserDefaults] setObject:url.browserString forKey:@"recentAddress"];
        [self.undoManager removeAllActions];
    }
    NSString *html = [[BrowserModel sharedModel] getHtmlByURL:url.canonicalURL];
    if (html) {
        [self.delegate openPageWithHTML:html baseURL:url];
    } else {
        [self.delegate openPageWithURL:url];
    }
}

- (void)undoToHtml:(NSString *)html withURL:(NSURL *)url {
    [[BrowserModel sharedModel] saveHTML:html forURL:url.canonicalURL];
    [self openPageWithURL:url];
}

- (void)savePageHTML:(NSString *)html withURL:(NSURL *)url {
    NSString *oldHtml = [[BrowserModel sharedModel] getHtmlByURL:url.canonicalURL];
    if (oldHtml) {
        ViewModel *vm = [self.undoManager prepareWithInvocationTarget:self];
        [vm undoToHtml:oldHtml withURL:url.canonicalURL];
    }
    [[NSUserDefaults standardUserDefaults] setObject:url.browserString forKey:@"recentAddress"];
    [[BrowserModel sharedModel] saveHTML:html forURL:url.canonicalURL];
}

- (void)openRecentAddress {
    NSString *recentAddress = [[NSUserDefaults standardUserDefaults] objectForKey:@"recentAddress"];
    NSURL *recentURL = [NSURL URLWithBrowserString:recentAddress];
    if (recentURL) {
        [self openPageWithURL:recentURL];
    }
}

- (void)undo {
    [self.undoManager undo];
}

- (void)reload:(NSString *)address {
    [self.delegate openPageWithURL:[NSURL URLWithString:address]];
}

- (NSString *)html:(NSString *)address {
    NSURL *url = [NSURL URLWithString:address];
    return [[BrowserModel sharedModel] getHtmlByURL:url.canonicalURL];
}

@end

