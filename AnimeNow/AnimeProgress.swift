//
//  AnimeProgress.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/21/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import RealmSwift

public enum SyncState: Int {
    case InSync = 0
    case Created
    case Updated
    case Deleted
}

public class AnimeProgress: Object {
    dynamic public var myAnimeListID = 0
    dynamic public var status = ""
    dynamic public var episodes = 0
    dynamic public var score = 0
    dynamic public var parseID = ""
    dynamic public var syncState = 0
    
    override public static func primaryKey() -> String? {
        return "myAnimeListID"
    }
    
    public func updatedEpisodes(animeEpisodes: Int) {
        if let list = MALList(rawValue: status) where list == .Planning {
            status = MALList.Watching.rawValue
        }
        
        if let list = MALList(rawValue: status) where list != .Completed && (animeEpisodes == episodes && animeEpisodes != 0) {
            status = MALList.Completed.rawValue
        }
        
        if let list = MALList(rawValue: status) where list == .Completed && (animeEpisodes != episodes && animeEpisodes != 0) {
            status = MALList.Watching.rawValue
        }
    }

}