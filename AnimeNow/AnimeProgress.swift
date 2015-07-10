//
//  AnimeProgress.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/21/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import RealmSwift

public class AnimeProgress: Object {
    dynamic public var myAnimeListID = 0
    dynamic public var status = ""
    dynamic public var episodes = 0
    dynamic public var score = 0
    dynamic public var parseID = ""
    
    override public static func primaryKey() -> String? {
        return "myAnimeListID"
    }
    
    public func updatedEpisodes(animeEpisodes: Int) {
        if let list = MALList(rawValue: status) where list == .Planning {
            status = MALList.Watching.rawValue
        } else if let list = MALList(rawValue: status) where list == .Watching && (animeEpisodes == episodes && animeEpisodes != 0) {
            status = MALList.Completed.rawValue
        } else if let list = MALList(rawValue: status) where list == .Completed && (animeEpisodes != episodes && animeEpisodes != 0) {
            status = MALList.Watching.rawValue
        }
    }

}