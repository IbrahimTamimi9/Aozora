//
//  ANParseKit.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 5/23/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation

public struct ParseKit {
    public static let Anime = "Anime"
    public static let AnimeDetail = "AnimeDetail"
    public static let AnimeCast = "AnimeCast"
    public static let AnimeCharacters = "AnimeCharacters"
    public static let AnimeForum = "AnimeForum"
    public static let AnimeRelations = "AnimeRelations"
    public static let AnimeReview = "AnimeReview"
    public static let SeasonalChart = "SeasonalChart"
}

public class ANParseKit {
    
    public class func bundle() -> NSBundle {
        return NSBundle(forClass: self)
    }
    
    public class func threadStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Thread", bundle: bundle())
    }
    
    public class func commentStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Comment", bundle: bundle())
    }
    
    public class func profileStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Profile", bundle: bundle())
    }
    
    public class func profileViewController() -> (UINavigationController, ProfileViewController) {
        let navController = ANParseKit.profileStoryboard().instantiateInitialViewController() as! UINavigationController
        let controller = navController.viewControllers.last as! ProfileViewController
        return (navController, controller)
    }
    
    public class func commentViewController() -> CommentViewController {
        let controller = ANParseKit.commentStoryboard().instantiateInitialViewController() as! CommentViewController
        return controller
    }
    
    public class func episodeThreadViewController() -> EpisodeThreadViewController {
        let controller = ANParseKit.threadStoryboard().instantiateViewControllerWithIdentifier("EpisodeThread") as! EpisodeThreadViewController
        return controller
        
    }
    
    public class func loginViewController() -> LoginViewController {
        let storyboard = UIStoryboard(name: "Login", bundle: ANParseKit.bundle())
        let loginController = storyboard.instantiateInitialViewController() as! LoginViewController
        return loginController
    }
}