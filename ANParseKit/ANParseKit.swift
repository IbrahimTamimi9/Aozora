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
    
    public class func commentViewController() -> CommentViewController {
        let controller = ANParseKit.threadStoryboard().instantiateInitialViewController() as! CommentViewController
        return controller
    }
}