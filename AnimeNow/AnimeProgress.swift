//
//  AnimeProgress.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/21/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import RealmSwift

class AnimeProgress: Object {
    dynamic var animeID = 0
    dynamic var status = 0
    dynamic var episodes = 0
    dynamic var score = 0
    dynamic var parseID = ""
    
    override static func primaryKey() -> String? {
        return "animeID"
    }
}