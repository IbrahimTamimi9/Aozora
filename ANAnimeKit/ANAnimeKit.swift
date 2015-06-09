//
//  ANAnimeKit.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/9/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

public class ANAnimeKit {
    
    public class func bundle() -> NSBundle {
        return NSBundle(forClass: self)
    }
    
    public class func defaultStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Anime", bundle: bundle())
    }
    
    public class func rootTabBarController() -> UITabBarController {
        let tabBarController = defaultStoryboard().instantiateInitialViewController() as! UITabBarController
        return tabBarController
    }
}