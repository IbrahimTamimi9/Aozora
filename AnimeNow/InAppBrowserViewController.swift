//
//  InAppBrowserViewController.swift
//  Seedonk
//
//  Created by Larry Damman on 3/19/15.
//  Copyright (c) 2015 Seedonk. All rights reserved.
//

import WebKit

public class InAppBrowserViewController: UIViewController {

    var initialStatusBarStyle: UIStatusBarStyle!
    var webView: WKWebView!
    
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
        
        webView = WKWebView(frame: view.bounds)
        webView.navigationDelegate = self
        view.addSubview(webView)
        
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

    @IBAction func openInSafari(sender: AnyObject) {
        if let url = initialUrl {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    deinit {
        webView = nil
    }

}


// MARK: <UIWebViewDelegate>

extension InAppBrowserViewController : WKNavigationDelegate {
    public func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
    }
    
}