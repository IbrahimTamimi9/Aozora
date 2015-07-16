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
@property (nonatomic) float estimatedProgress;

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
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1, 0)];
    self.webView.hidden = YES;
    
    self.viewController = aViewController;
    [self.viewController.view addSubview:self.webView];
    
    self.progressProxy = [[NJKWebViewProgress alloc] init];
    self.webView.delegate = self.progressProxy;
    self.progressProxy.webViewProxyDelegate = self;
    self.progressProxy.progressDelegate = self;
    
    self.catchFlag = NO;

    return self;
}

- (void)scrape:(NSString *)url handler:(WSRequestHandler)handler
{
    self.catchFlag = YES;
    self.isMakingPostRequest = NO;
    [self.webView stopLoading];
    self.targetUrl = [NSURL URLWithString:url];
    self.completion = handler;

    NSMutableURLRequest *rq = [NSMutableURLRequest requestWithURL:self.targetUrl];
    //[rq setValue:@"api-animetrkr-79CF0C8BFA98843F983F9D1083C54A36" forHTTPHeaderField:@"User-Agent"];

    [self.webView loadRequest:rq];    
}

- (void)makePostRequestWithScript:(NSString *)script handler:(HTTPRequestHandler)handler
{

    NSLog(@"Script: %@",script);
    self.completionPOST = handler;
    self.script = script;
    
    // TODO: Make a post request with a NSMutableURLRequest... if using UIWebView
    // Prepare for POST request
    self.isMakingPostRequest = YES;
    self.didMadePostRequest = NO;
    NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:@"POSTRequestJS" ofType:@"html"];
    NSString *html = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:html baseURL:[[NSBundle bundleForClass:self.class] bundleURL]];

}


-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    self.estimatedProgress = progress;
    // Estimated progress when image urls have been loaded 0.5
    //NSLog(@"Progress %f",self.estimatedProgress);
    if (!self.catchFlag || self.estimatedProgress < NJKInteractiveProgressValue) {
        return;
    }
    
    NSString *html = [self webHTML];
    if(!html.length){
        NSLog(@"No html");
        return;
    }
    
    self.catchFlag = NO;
    NSLog(@"Loaded from progress %f",self.estimatedProgress);
    
    if(!self.isMakingPostRequest) {
        if (self.completion) {
            
            NSString *newHTML = [[[html stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"  " withString:@""] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            newHTML = [newHTML stringByReplacingOccurrencesOfString:@"> <" withString:@"><"];
            
            TFHpple *hpple = [TFHpple hppleWithHTMLData:[newHTML dataUsingEncoding:NSUTF8StringEncoding]];
            self.completion(hpple);
            [self.webView stopLoading];
        }

    } else {
        if (self.completionPOST) {
            self.completionPOST(html);
        }
    }
}


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //NSLog(@"Should startLoadWithRequest: %@", webView.request.URL);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    //NSLog(@"didStartLoad %@",webView.request.URL);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    // This is called multiple times, stupid webview..
    if (self.isMakingPostRequest && !self.didMadePostRequest) {
        self.didMadePostRequest = YES;
        self.catchFlag = YES;
        [self.webView stringByEvaluatingJavaScriptFromString:self.script];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoad");
    
    if ([error code] != NSURLErrorCancelled) {
        NSLog(@"[ERROR] %@", [error localizedDescription]);
        self.completion(nil);
    }
}

- (NSString *)webHTML {
    NSString* head = [self.webView stringByEvaluatingJavaScriptFromString:@"document.head.innerHTML"];
    NSString* body = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    
    NSString* html = [NSString stringWithFormat:@"<html><head>%@</head><body>%@</body></html>", head, body];
    return html;
}



@end
