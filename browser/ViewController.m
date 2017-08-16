
#import "ViewController.h"
#import "ViewModel.h"
#import "NSURL+Browser.h"
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
        [self.viewModel openPageWithAddress:textView.string];
        return true;
    }
    return false;
}

- (void)openPageWithURL:(NSURL *)url {
    self.addressTextField.stringValue = url.browserString;
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
    self.addressTextField.stringValue = request.URL.absoluteString;
    [self.webView loadRequest:request];
    return nil;
}

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary *dict = (NSDictionary *) message.body;
    if ([dict valueForKey:@"log"]) {
        NSLog(@"%@", [dict valueForKey:@"log"]);
    } else if ([dict valueForKey:@"html"]) {
        [self.viewModel savePageHTML:[dict valueForKey:@"html"] withURL:self.webView.URL];
    }
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
//    [self.webView evaluateJavaScript:@"document.documentElement.innerHTML = 'test'" completionHandler:^(id x, NSError *error) {
//        if (error) NSLog(@"%@", error);
//    }];
    BOOL webViewHidden = self.webView.hidden;
    self.webView.hidden = !webViewHidden;
    self.sourceView.hidden = webViewHidden;
    NSString *html = [self.viewModel html:self.addressTextField.stringValue];
    self.sourceTextView.string = html ? html : @"";
}

- (IBAction)links:(NSButton *)linksCheckBox {
    NSString *value  = linksCheckBox.state == NSOnState ? @"true" : @"false";
    NSString *script = [NSString stringWithFormat:@"window.removeLinks = %@", value];
    [self.webView evaluateJavaScript:script completionHandler:^(id result, NSError* error) {
        // nothing to do
    }];
}

@end
