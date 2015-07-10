//
//  WorkflowController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/29/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation

class WorkflowController {
    
    class func presentRootTabBar(#animated: Bool) {
        
        let seasons = UIStoryboard(name: "Season", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let library = UIStoryboard(name: "Library", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let forum = UIStoryboard(name: "Forum", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let profile = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let browse = UIStoryboard(name: "Browse", bundle: nil).instantiateInitialViewController() as! UINavigationController
        
        let tabBarController = RootTabBar()
        tabBarController.viewControllers = [seasons, library, profile, forum, browse]
        
        if animated {
            changeRootViewController(tabBarController, animationDuration: 0.5)
        } else {
            if let window = UIApplication.sharedApplication().delegate!.window {
                window?.rootViewController = tabBarController
                window?.makeKeyAndVisible()
            }
        }
        
    }
    
    class func changeRootViewController(vc: UIViewController, animationDuration: NSTimeInterval = 0.5) {
        
        var window: UIWindow?
        
        let appDelegate = UIApplication.sharedApplication().delegate!
        
        if appDelegate.respondsToSelector(Selector("window")) {
            window = appDelegate.window!
        }
        
        if let window = window {
            if window.rootViewController == nil {
                window.rootViewController = vc
                return
            }
            
            let snapshot = window.snapshotViewAfterScreenUpdates(true)
            vc.view.addSubview(snapshot)
            window.rootViewController = vc
            window.makeKeyAndVisible()
            
            UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                snapshot.alpha = 0.0
                }, completion: {(finished) in
                    snapshot.removeFromSuperview()
            })
        }
    }
}