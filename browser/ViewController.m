
#import "ViewController.h"
#import "ViewModel.h"
#import "NSURL+Browser.h"
@import WebKit;

@interface ViewController () <NSTextFieldDelegate,WKUIDelegate,WKScriptMessageHandler,ViewModelDelegate>
@property (nonatomic) WKWebView *webView;
@property (nonatomic) IBOutlet NSView *mainView;
@property (nonatomic) IBOutlet NSButton *linksCheckBox;
@property (nonatomic) IBOutlet NSTextField *addressTextField;
@property (nonatomic) IBOutlet NSTextView *sourceTextView;
@property (nonatomic) IBOutlet NSView *sourceView;
@property (nonatomic) ViewModel *viewModel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.addressTextField.delegate = self;
    self.webView = [[WKWebView alloc] initWithFrame:self.mainView.bounds configuration:[self webConfiguration]];
    self.webView.UIDelegate = self;
    self.webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.webView.translatesAutoresizingMaskIntoConstraints = YES;
    [self.mainView addSubview:self.webView];
    self.sourceView.hidden = YES;
    self.undoManager.levelsOfUndo = 10;
    self.viewModel = [[ViewModel alloc] initWithDelegate:self];
    [self.viewModel openRecentAddress];
}

- (WKWebViewConfiguration *)webConfiguration {
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"script" ofType:@"js"];
    NSString *text = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    WKWebViewConfiguration *webConfiguration = [[WKWebViewConfiguration alloc] init];
    if (text) {
        WKUserScript *script = [[WKUserScript alloc] initWithSource:text
                                                      injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                   forMainFrameOnly:YES];
        WKUserContentController *controller = [[WKUserContentController alloc] init];
        [controller addScriptMessageHandler:self name:@"host"];
        [controller addUserScript:script];
        webConfiguration.userContentController = controller;
    }
    webConfiguration.preferences = [[WKPreferences alloc] init];
//    webConfiguration.preferences.javaScriptEnabled = NO;
    return webConfiguration;
}

- (BOOL)control:(NSControl *)control
       textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertNewline:)) {
        NSURL *url = [NSURL URLWithBrowserString:textView.string];
        [self.viewModel openPageWithURL:url];
        return true;
    }
    return false;
}

- (void)openPageWithURL:(NSURL *)url {
    self.addressTextField.stringValue = url.browserString;
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url
//                                                  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
//                                              timeoutInterval:10];
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)openPageWithHTML:(NSString *)html baseURL:(NSURL *)baseUrl {
    self.addressTextField.stringValue = baseUrl.browserString;
    [self.webView loadHTMLString:html baseURL:baseUrl];
}

- (WKWebView *)webView:(WKWebView *)webView
createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
   forNavigationAction:(WKNavigationAction *)navigationAction
        windowFeatures:(WKWindowFeatures *)windowFeatures {
    // а вот здесь нужно проверять, есть ли
    NSURLRequest *request = navigationAction.request;
    self.addressTextField.stringValue = request.URL.browserString;
    [self.webView loadRequest:request];
    return nil;
}

- (void)sendRemoveLinksState {
    NSString *value  = self.linksCheckBox.state == NSOnState ? @"true" : @"false";
    NSString *script = [NSString stringWithFormat:@"window.removeLinks = %@", value];
    [self.webView evaluateJavaScript:script completionHandler:^(id result, NSError* error) {
        // nothing to do
    }];
}

static const unsigned logSize = 1023;

- (void)logLongText:(NSString *)text {
    NSInteger parts = text.length / logSize;
    for (int i = 0; i < parts; ++i) {
        NSRange range = NSMakeRange(i * logSize, logSize);
        NSString *part = [text substringWithRange:[text rangeOfComposedCharacterSequencesForRange:range]];
        NSLog(@"\n%@\n", part);
    }
    NSInteger remain = text.length - parts * logSize;
    if (remain) {
        NSRange range = NSMakeRange(parts * logSize, remain);
        NSString *part = [text substringWithRange:[text rangeOfComposedCharacterSequencesForRange:range]];
        NSLog(@"\n%@\n", part);
    }
}

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary *dict = (NSDictionary *) message.body;
    if ([dict valueForKey:@"log"]) {
        NSString *loggedText = [dict valueForKey:@"log"];
        if (loggedText.length > logSize) {
            [self logLongText:loggedText];
        } else {
            NSLog(@"%@", loggedText);
        }
    } else if ([dict valueForKey:@"html"]) {
        [self.viewModel savePageHTML:[dict valueForKey:@"html"] withURL:self.webView.URL];
        self.addressTextField.stringValue = self.webView.URL.browserString;
    } else if ([dict valueForKey:@"removeLinks"]) {
        [self sendRemoveLinksState];
    }
}

- (IBAction)undo:(id)sender {
    [self.viewModel undo];
}

- (IBAction)reload:(id)sender {
    [self.viewModel reload:self.webView.URL];
}

- (IBAction)back:(id)sender {
    WKBackForwardListItem *back = self.webView.backForwardList.backItem;
    if (back) {
        [self.viewModel openPageWithURL:back.URL];
    }
}

- (IBAction)source:(id)sender {
//    [self.webView evaluateJavaScript:@"document.documentElement.innerHTML = 'test'" completionHandler:^(id x, NSError *error) {
//        if (error) NSLog(@"%@", error);
//    }];
    BOOL webViewHidden = self.webView.hidden;
    self.webView.hidden = !webViewHidden;
    self.sourceView.hidden = webViewHidden;
    NSString *html = [self.viewModel html:self.webView.URL];
    self.sourceTextView.string = html ? html : @"";
}

- (IBAction)links:(id)sender {
    [self sendRemoveLinksState];
}

@end
