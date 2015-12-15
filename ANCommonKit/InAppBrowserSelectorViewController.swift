//
//  InAppBrowserSelectorViewController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 8/6/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import WebKit

public protocol InAppBrowserSelectorViewControllerDelegate: class {
    func inAppBrowserSelectorViewControllerSelectedSite(siteURL: String)
}

public class InAppBrowserSelectorViewController: UIViewController {
    
    var initialStatusBarStyle: UIStatusBarStyle!
    var webView: WKWebView!
    public weak var delegate: InAppBrowserSelectorViewControllerDelegate?
    
    var initialUrl: NSURL? {
        didSet {
            if let initialUrl = initialUrl {
                lastRequest = NSURLRequest(URL: initialUrl)
            }
        }
    }
    
    var lastRequest : NSURLRequest?
    
    public func initWithTitle(title: String, initialUrl: NSURL?) {
        self.initialUrl = initialUrl
        self.title = title
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        var frame = view.bounds
        frame.origin.y = 0
        frame.size.height = frame.size.height
        webView = WKWebView(frame: frame)
        webView.navigationDelegate = self
        view.insertSubview(webView, atIndex: 0)
        
        navigationController?.navigationBar.barTintColor = UIColor.darkBlue()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        if let request = lastRequest {
            webView.loadRequest(request)
        }
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        initialStatusBarStyle = UIApplication.sharedApplication().statusBarStyle
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().setStatusBarStyle(initialStatusBarStyle, animated: true)
    }
    
    @IBAction func dismissModal() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func selectWebSite(sender: AnyObject) {
        if let urlString = webView.URL?.absoluteString {
            delegate?.inAppBrowserSelectorViewControllerSelectedSite(urlString)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func navigateBack(sender: AnyObject) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @IBAction func navigateForward(sender: AnyObject) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
   
    deinit {
        webView = nil
    }
}


// MARK: <UIWebViewDelegate>

extension InAppBrowserSelectorViewController : WKNavigationDelegate {
    public func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
    }
    
}