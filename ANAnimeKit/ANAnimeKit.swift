//
//  ANAnimeKit.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/9/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//
import ANParseKit

public class ANAnimeKit {
    
    public class func defaultStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Anime", bundle: nil)
    }
    
    public class func threadStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Thread", bundle: nil)
    }
    
    public class func rootTabBarController() -> CustomTabBarController {
        let tabBarController = defaultStoryboard().instantiateInitialViewController() as! CustomTabBarController
        return tabBarController
    }
    
    public class func profileViewController() -> (UINavigationController, ProfileViewController) {
        let navController = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let controller = navController.viewControllers.last as! ProfileViewController
        return (navController, controller)
    }
    
    public class func animeForumViewController() -> (UINavigationController,ForumViewController) {
        let controller = UIStoryboard(name: "Forum", bundle: nil).instantiateInitialViewController() as! UINavigationController
        return (controller,controller.viewControllers.last! as! ForumViewController)
    }
    
    public class func customThreadViewController() -> CustomThreadViewController {
        let controller = ANAnimeKit.threadStoryboard().instantiateViewControllerWithIdentifier("CustomThread") as! CustomThreadViewController
        return controller
    }
    
    public class func notificationThreadViewController() -> NotificationThreadViewController {
        let controller = ANAnimeKit.threadStoryboard().instantiateViewControllerWithIdentifier("NotificationThread") as! NotificationThreadViewController
        return controller
    }
}