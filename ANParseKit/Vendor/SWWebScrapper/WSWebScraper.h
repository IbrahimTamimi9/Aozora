//
//  WSWebScraper.h
//  GoogleSearchBridge
//
//  Created by  on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TFHpple.h"
#import <NJKWebViewProgress/NJKWebViewProgress.h>

@interface WSWebScraper : NSObject <UIWebViewDelegate, NJKWebViewProgressDelegate>

typedef void(^WSRequestHandler)(TFHpple *hpple);
typedef void(^HTTPRequestHandler)(NSString *body);

@property (nonatomic, copy) WSRequestHandler completion;
@property (nonatomic, copy) HTTPRequestHandler completionPOST;
@property (strong, nonatomic) UIWebView* webView;
@property (strong, nonatomic) NJKWebViewProgress* progressProxy;

- (id)initWithViewController:(UIViewController *)aViewController;

- (void)scrape:(NSString *)url handler:(WSRequestHandler)handler;
- (void)makePostRequestWithScript:(NSString *)script handler:(HTTPRequestHandler)handler;
@end
