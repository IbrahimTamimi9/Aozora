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

@interface WSWebScraper : NSObject <UIWebViewDelegate>

typedef void(^WSRequestHandler)(TFHpple *hpple);

@property (nonatomic, copy) WSRequestHandler completetion;
@property (strong, nonatomic) UIWebView* webView;
- (id)initWithViewController:(UIViewController *)aViewController;

- (void)scrape:(NSString *)url;
- (void)scrape:(NSString *)url mobileVersion:(BOOL)mobileVersion handler:(WSRequestHandler)handler;


@end
