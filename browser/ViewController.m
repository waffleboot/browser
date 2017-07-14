
#import "ViewController.h"
@import WebKit;

@interface ViewController () <NSTextFieldDelegate,WKUIDelegate>
@property (nonatomic) WKWebView *webView;
@property (nonatomic) IBOutlet NSTextField *addressTextField;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect frame = CGRectMake(0, 0, 480, 233);
    WKWebViewConfiguration *webConfiguration = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:frame configuration:webConfiguration];
    self.webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.webView.UIDelegate = self;
    [self.view addSubview:self.webView];
    self.addressTextField.delegate = self;
}

- (BOOL)control:(NSControl *)control
       textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertNewline:)) {
        [self openAddress:textView.string];
        return true;
    }
    return false;
}

- (void)openAddress:(NSString *)address {
    self.addressTextField.stringValue = address;
    NSURL *url = [NSURL URLWithString:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    NSURLRequest *request = navigationAction.request;
    self.addressTextField.stringValue = request.URL.absoluteString;
    [self.webView loadRequest:request];
    return nil;
}

@end
