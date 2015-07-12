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

@property (nonatomic) BOOL catchFlag;
@property (strong, nonatomic) NSURL* targetUrl;

@property (nonatomic) BOOL isMakingPostRequest;
@property (nonatomic) BOOL didMadePostRequest;
@property (strong, nonatomic) NSString *script;

@end

@implementation WSWebScraper

- (UIViewController *)viewController
{
  return _viewController;
}

- (void)setViewController:(UIViewController *)aViewController
{
  _viewController = aViewController;
}

- (id)initWithViewController:(UIViewController *)aViewController {
    
    self = [super init];
    
    if(!self) {
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

- (void)scrape:(NSString *)url handler:(WSRequestHandler)handler
{
    self.isMakingPostRequest = NO;
    [self.webView stopLoading];
    self.targetUrl = [NSURL URLWithString:url];
    self.completion = handler;

    NSMutableURLRequest *rq = [NSMutableURLRequest requestWithURL:self.targetUrl];
    [rq setValue:@"api-animetrkr-79CF0C8BFA98843F983F9D1083C54A36" forHTTPHeaderField:@"User-Agent"];

    [self.webView loadRequest:rq];    
}

// Headers can't be set on WKWebView bug so have to do this: http://stackoverflow.com/questions/26253133/cant-set-headers-on-my-wkwebview-post-request
- (void)prepareForPOSTRequest {
    
    self.isMakingPostRequest = YES;
    self.didMadePostRequest = NO;
    NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:@"POSTRequestJS" ofType:@"html"];
    NSString *html = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:html baseURL:[[NSBundle bundleForClass:self.class] bundleURL]];

}

- (void)makePostRequestWithScript:(NSString *)script handler:(HTTPRequestHandler)handler
{
    NSLog(@"Script: %@",script);
    self.completion2 = handler;
    self.script = script;
    [self prepareForPOSTRequest];
}

- (void)realizePostRequest {
    
    [self.webView evaluateJavaScript:self.script completionHandler:^(id result, NSError *error) {
        if (error) {
            NSLog(@"Error %@",error);
        } else {
            NSLog(@"Result %@",result);
        }
    }];
    
    self.didMadePostRequest = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"] && object == self.webView) {

        // Estimated progress when image urls have been loaded 0.7
        if(self.catchFlag && !self.isMakingPostRequest && self.webView.estimatedProgress > 0.7) {
            [self.webView evaluateJavaScript:@"document.body.innerHTML" completionHandler:^(NSString *body, NSError *error) {
                if(!body.length){
                    NSLog(@"No body");
                    return;
                }
                if(!self.catchFlag) {
                    return;
                }
                self.catchFlag = NO;
                NSLog(@"Loaded from progress %f",self.webView.estimatedProgress);
                
                
                if (self.completion) {
                    
                    NSString* html = [NSString stringWithFormat:@"<html><head></head><body>%@</body></html>", body];
                    
                    NSString *newHTML = [[[html stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"  " withString:@""] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                    
                    newHTML = [newHTML stringByReplacingOccurrencesOfString:@"> <" withString:@"><"];
                    
                    
                    TFHpple *hpple = [TFHpple hppleWithHTMLData:[newHTML dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    self.completion(hpple);
                    
                    [self.webView stopLoading];
                }
                
                
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
    NSLog(@"didCommitNavigation");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"didFinishNavigation");
    
    if (self.isMakingPostRequest) {
        if (!self.didMadePostRequest) {
            [self realizePostRequest];
        } else {
            [self showHTML];
        }
    }
}

- (void)showHTML {
    [self.webView evaluateJavaScript:@"document.body.innerHTML" completionHandler:^(NSString *body, NSError *error) {
        if(!body.length){
            NSLog(@"No body");
            return;
        }
        if(!self.catchFlag) {
            return;
        }
        self.catchFlag = NO;
        NSLog(@"Loaded from progress %f",self.webView.estimatedProgress);
        
        self.completion2(body);
    }];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"didFailNavigation");
    if ([error code]!=NSURLErrorCancelled) {
        NSLog(@"[ERROR] %@", [error localizedDescription]);
        self.completion(nil);
    }
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"didReceiveServerRedirectForProvisionalNavigation");
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"didStartProvisionalNavigation");
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"didFailProvisionalNavigationx ");
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    NSLog(@"didReceiveAuthenticationChallenge");
}

@end
