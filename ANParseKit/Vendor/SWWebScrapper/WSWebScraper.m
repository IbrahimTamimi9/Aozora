//
//  WSWebScraper.m
//  GoogleSearchBridge
//
//  Created by  on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSWebScraper.h"


@interface WSWebScraper(){
  UIViewController* _viewController;
}


@property (weak, nonatomic) UIViewController* viewController;

@property (assign, nonatomic) BOOL catchFlag;
@property (strong, nonatomic) NSURL* targetUrl;
@end

@implementation WSWebScraper

@synthesize completetion = _completetion;

@synthesize webView = _webView;
@synthesize targetUrl = _targetUrl;
@synthesize catchFlag = _catchFlag;

- (UIViewController *)viewController
{
  return _viewController;
}

- (void)setViewController:(UIViewController *)aViewController
{
  _viewController = aViewController;
}

- (id)initWithViewController:(UIViewController *)aViewController
{
  self = [super init];
  if(!self){
    return nil;
  }
  
  self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1, 0)];
  self.webView.hidden = YES;  
  self.webView.delegate = self;
  
  self.viewController = aViewController;
  [self.viewController.view addSubview:self.webView];

  self.catchFlag = NO;
  
  return self;
}

- (void)scrape:(NSString *)url
{
  [self scrape:url mobileVersion:YES handler:self.completetion];
}

- (void)scrape:(NSString *)url mobileVersion:(BOOL)mobileVersion handler:(WSRequestHandler)handler
{
    [self.webView stopLoading];
    self.targetUrl = [NSURL URLWithString:url];
    self.completetion = handler;
    self.catchFlag = YES;
    if (!mobileVersion) {
        NSMutableURLRequest *rq = [NSMutableURLRequest requestWithURL:self.targetUrl];
        [rq setValue:@"api-animetrkr-79CF0C8BFA98843F983F9D1083C54A36" forHTTPHeaderField:@"User-Agent"];
        
        [self.webView loadRequest:rq];
    } else {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.targetUrl]];
    }
    
    
}

# pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{  
  if(![request.URL.scheme isEqualToString:@"http"] && ![request.URL.scheme isEqualToString:@"https"]){
    return NO;
  }
  
  return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString* body = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    if(!body.length){
        return;
    }
    
    if(!self.catchFlag){
        return;
    }
    
    self.catchFlag = NO;
    
    [self performSelector:@selector(completeForWebView:) withObject:webView afterDelay:0.0];
}
- (void)completeForWebView:(UIWebView *)webView
{
    NSString* head = [webView stringByEvaluatingJavaScriptFromString:@"document.head.innerHTML"];
    NSString* body = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];

    NSString* html = [NSString stringWithFormat:@"<html><head>%@</head><body>%@</body></html>", head, body];
    TFHpple *hpple = [TFHpple hppleWithHTMLData:[html dataUsingEncoding:NSUTF8StringEncoding]];
    self.completetion(hpple);
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([error code]!=NSURLErrorCancelled) {
        NSLog(@"[ERROR] %@", [error localizedDescription]);
        self.completetion(nil);
    }
  
}

@end
