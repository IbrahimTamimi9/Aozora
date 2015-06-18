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
  
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 1, 0)];
  self.webView.hidden = YES;  
  self.webView.navigationDelegate = self;
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
  
  self.viewController = aViewController;
  [self.viewController.view addSubview:self.webView];

  self.catchFlag = NO;
  
  return self;
}
- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    
    // if you have set either WKWebView delegate also set these to nil here
    [self.webView setNavigationDelegate:nil];
    [self.webView setUIDelegate:nil];
}
- (void)scrape:(NSString *)url
{
  [self scrape:url handler:self.completetion];
}

- (void)scrape:(NSString *)url handler:(WSRequestHandler)handler
{
    [self.webView stopLoading];
    self.targetUrl = [NSURL URLWithString:url];
    self.completetion = handler;

    NSMutableURLRequest *rq = [NSMutableURLRequest requestWithURL:self.targetUrl];
    [rq setValue:@"api-animetrkr-79CF0C8BFA98843F983F9D1083C54A36" forHTTPHeaderField:@"User-Agent"];
    
    [self.webView loadRequest:rq];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"] && object == self.webView) {
        NSLog(@"%f", self.webView.estimatedProgress);
        // estimatedProgress is a value from 0.0 to 1.0
        // Update your UI here accordingly
        if(self.catchFlag) {
            [self.webView evaluateJavaScript:@"document.body.innerHTML" completionHandler:^(NSString *body, NSError *error) {
                if(!body.length){
                    NSLog(@"No body");
                    return;
                }
                if(!self.catchFlag) {
                    return;
                }
                self.catchFlag = NO;
                NSLog(@"Loaded from progress");
                [self completeForWebView:self.webView];
                [self.webView stopLoading];
            }];
        }
    }
    else {
        // Make sure to call the superclass's implementation in the else block in case it is also implementing KVO
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    self.catchFlag = YES;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
//    [webView evaluateJavaScript:@"document.body.innerHTML" completionHandler:^(NSString *body, NSError *error) {
//        if(!body.length){
//            return;
//        }
//
//        if(!self.catchFlag){
//            return;
//        }
//        
//        //self.catchFlag = NO;
//        
//        [self completeForWebView:self.webView];
//    }];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if ([error code]!=NSURLErrorCancelled) {
        NSLog(@"[ERROR] %@", [error localizedDescription]);
        self.completetion(nil);
    }
}

- (void)completeForWebView:(WKWebView *)webView
{
    [webView evaluateJavaScript:@"document.body.innerHTML" completionHandler:^(NSString *body, NSError *error) {
        NSString* html = [NSString stringWithFormat:@"<html><head></head><body>%@</body></html>", body];
        
        
        NSString *newHTML = [[[html stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"  " withString:@""] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        
        newHTML = [newHTML stringByReplacingOccurrencesOfString:@"> <" withString:@"><"];
        
        TFHpple *hpple = [TFHpple hppleWithHTMLData:[newHTML dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        
        self.completetion(hpple);
    }];
}




@end
