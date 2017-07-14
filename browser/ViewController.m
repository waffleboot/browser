
#import "ViewController.h"
#import "ViewModel.h"
@import WebKit;

@interface ViewController () <NSTextFieldDelegate,WKUIDelegate,WKScriptMessageHandler,ViewModelDelegate>
@property (nonatomic) WKWebView *webView;
@property (nonatomic) IBOutlet NSTextField *addressTextField;
@property (nonatomic) ViewModel *viewModel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect frame = CGRectMake(0, 0, 480, 233);
    self.webView = [[WKWebView alloc] initWithFrame:frame configuration:[self webConfiguration]];
    self.webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.webView.UIDelegate = self;
    [self.view addSubview:self.webView];
    self.addressTextField.delegate = self;
    self.viewModel = [[ViewModel alloc] initWithDelegate:self];
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
        [self.viewModel open:textView.string];
        return true;
    }
    return false;
}

- (void)open:(NSString *)address {
    self.addressTextField.stringValue = address;
    NSURL *url = [NSURL URLWithString:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)openHTML:(NSString *)html withAddress:(NSString *)address {
    self.addressTextField.stringValue = address;
    [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:address]];
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    NSURLRequest *request = navigationAction.request;
    self.addressTextField.stringValue = request.URL.absoluteString;
    [self.webView loadRequest:request];
    return nil;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.viewModel save:message.body withAddress:self.webView.URL.absoluteString];
}

@end
