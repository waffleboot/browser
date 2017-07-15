
#import "ViewModel.h"
#import "BrowserModel.h"

@interface ViewModel ()
@property (nonatomic, weak) id<ViewModelDelegate> delegate;
@property (nonatomic) NSUndoManager *undoManager;
@end

@interface NSURL (CanonicalURL)
@property (nonatomic, readonly) NSURL *canonicalURL;
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
    [self openPageWithURL:[NSURL URLWithString:address]];
}

- (void)openPageWithURL:(NSURL *)url {
    NSString *latestAddress = [[NSUserDefaults standardUserDefaults] objectForKey:@"latestAddress"];
    NSURL *latestURL = [NSURL URLWithString:latestAddress];
    if (![latestURL.canonicalURL isEqualTo:url.canonicalURL]) {
        [self.undoManager removeAllActions];
    }
    [[NSUserDefaults standardUserDefaults] setObject:url.absoluteString forKey:@"latestAddress"];
    NSString *html = [[BrowserModel sharedModel] getHtmlByURL:url.canonicalURL];
    if (html) {
        [self.delegate openPageWithHTML:html baseURL:url];
    } else {
        [self.delegate openPageWithURL:url];
    }
}

- (void)undoToHtml:(NSString *)html withAddress:(NSString *)address {
    [self savePageHTML:html withAddress:address];
    [self openPageWithAddress:address];
}

- (void)savePageHTML:(NSString *)html withAddress:(NSString *)address {
    NSURL *url = [NSURL URLWithString:address];
    NSString *oldHtml = [[BrowserModel sharedModel] getHtmlByURL:url.canonicalURL];
    if (oldHtml) {
        ViewModel *vm = [self.undoManager prepareWithInvocationTarget:self];
        [vm undoToHtml:oldHtml withAddress:address];
    }
    [[BrowserModel sharedModel] saveHTML:html forURL:url.canonicalURL];
}

- (void)openLatest {
    NSString *latestAddress = [[NSUserDefaults standardUserDefaults] objectForKey:@"latestAddress"];
    NSURL *latestURL = [NSURL URLWithString:latestAddress];
    if (latestURL) {
        [self openPageWithURL:latestURL];
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

@implementation NSURL (CanonicalNSURL)
- (NSURL *)canonicalURL {
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = self.scheme;
    components.host = self.host;
    components.port = self.port;
    components.path = self.path;
    return components.URL;
}
@end
