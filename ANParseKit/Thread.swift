//
//  TimelinePost.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/29/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Parse

public class Thread: PFObject, PFSubclassing {
    override public class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    public class func parseClassName() -> String {
        return "Thread"
    }
    
    @NSManaged public var title: String
    @NSManaged public var episode: Episode?
    @NSManaged public var anime: Anime?
    @NSManaged public var startedBy: PFUser?
    @NSManaged public var replies: Int
    @NSManaged public var tags: [String]
}