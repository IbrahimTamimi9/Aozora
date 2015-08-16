//
//  WorkflowController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/29/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import ANParseKit
import ANCommonKit

class WorkflowController {
    
    class func presentRootTabBar(#animated: Bool) {
        
        let seasons = UIStoryboard(name: "Season", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let library = UIStoryboard(name: "Library", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let forum = UIStoryboard(name: "Forum", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let (profile, _) = ANParseKit.profileViewController()
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
    
    class func presentOnboardingController(asRoot: Bool) {
            
        let onboarding = UIStoryboard(name: "Onboarding", bundle: nil).instantiateInitialViewController() as! OnboardingViewController
        
        if asRoot {
            onboarding.isInWindowRoot = true
            applicationWindow().rootViewController = onboarding
            applicationWindow().makeKeyAndVisible()
        } else {
            applicationWindow().rootViewController?.presentViewController(onboarding, animated: true, completion: nil)
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
    
    class func applicationWindow() -> UIWindow {
        return UIApplication.sharedApplication().delegate!.window!!
    }
    
    class func logoutUser() -> BFTask {
        // Remove cookies
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in storage.cookies as! [NSHTTPCookie] {
            storage.deleteCookie(cookie)
        }
        
        // Removed saved data
        let query = Anime.query()!
        query.fromLocalDatastore()
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            PFObject.unpinAllInBackground(result)
        }
        
        let query2 = Episode.query()!
        query2.fromLocalDatastore()
        query2.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            PFObject.unpinAllInBackground(result)
        }
        
        // Remove defaults
        NSUserDefaults.standardUserDefaults().removeObjectForKey(LibrarySyncController.LastSyncDateDefaultsKey)

        // Logout MAL
        User.removeCredentials()
        
        if let user = PFUser.currentUser() {
            PFFacebookUtils.unlinkUserInBackground(user, block: { (succeeded, error) -> Void in
                if succeeded {
                    println("The user is no longer associated with their Facebook account.")
                } else {
                    println("Failed unlinking from Facebook!")
                }
            })
        }
        
        // Logout user
        return PFUser.logOutInBackground()

    }
}