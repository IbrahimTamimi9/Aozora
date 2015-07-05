//
//  AnimeProgress.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/21/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import RealmSwift

public class AnimeProgress: Object {
    dynamic public var animeID = 0
    dynamic public var status = ""
    dynamic public var episodes = 0
    dynamic public var score = 0
    dynamic public var parseID = ""
    
    override public static func primaryKey() -> String? {
        return "animeID"
    }

}