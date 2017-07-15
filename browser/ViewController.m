
#import "ViewController.h"
#import "ViewModel.h"
@import WebKit;

@interface ViewController () <NSTextFieldDelegate,WKUIDelegate,WKScriptMessageHandler,ViewModelDelegate>
@property (nonatomic) WKWebView *webView;
@property (nonatomic) IBOutlet NSView *mainView;
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
    self.viewModel = [[ViewModel alloc] initWithDelegate:self];
    [self.viewModel openLatest];
    self.undoManager.levelsOfUndo = 10;
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
        [controller addScriptMessageHandler:self name:@"app"];
        [controller addUserScript:script];
        webConfiguration.userContentController = controller;
    }
    return webConfiguration;
}

- (BOOL)control:(NSControl *)control
       textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertNewline:)) {
        [self.viewModel openPageWithAddress:textView.string];
        return true;
    }
    return false;
}

- (void)openPageWithURL:(NSURL *)url {
    self.addressTextField.stringValue = url.absoluteString;
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)openPageWithHTML:(NSString *)html baseURL:(NSURL *)baseUrl {
    self.addressTextField.stringValue = baseUrl.absoluteString;
    [self.webView loadHTMLString:html baseURL:baseUrl];
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    NSURLRequest *request = navigationAction.request;
    self.addressTextField.stringValue = request.URL.absoluteString;
    [self.webView loadRequest:request];
    return nil;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.viewModel savePageHTML:message.body withAddress:self.webView.URL.absoluteString];
}

- (IBAction)undo:(id)sender {
    [self.viewModel undo];
}

- (IBAction)reload:(id)sender {
    [self.viewModel reload:self.webView.URL.absoluteString];
}

- (IBAction)back:(id)sender {
    WKBackForwardListItem *back = self.webView.backForwardList.backItem;
    if (back) {
        [self.viewModel openPageWithAddress:back.URL.absoluteString];
    }
}

- (IBAction)source:(id)sender {
    BOOL webViewHidden = self.webView.hidden;
    self.webView.hidden = !webViewHidden;
    self.sourceView.hidden = webViewHidden;
    self.sourceTextView.string = [self.viewModel html:self.addressTextField.stringValue];
}

@end
