//
//  ViewController.m
//  browser
//
//  Created by Андрей on 14.07.17.
//  Copyright © 2017 yangand. All rights reserved.
//

#import "ViewController.h"
@import WebKit;

@interface ViewController () <NSTextFieldDelegate,WKNavigationDelegate,WKUIDelegate>
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
    self.webView.navigationDelegate = self;
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

//- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
//    decisionHandler(WKNavigationActionPolicyAllow);
//}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"%@", error);
}

@end
