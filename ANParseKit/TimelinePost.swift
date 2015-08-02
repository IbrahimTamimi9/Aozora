//
//  TimelinePost.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/29/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Parse

public class TimelinePost: PFObject, PFSubclassing {
    override public class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    public class func parseClassName() -> String {
        return "TimelinePost"
    }
    
    @NSManaged public var content: String
    @NSManaged public var replyLevel: Int
    @NSManaged public var episode: Episode?
    @NSManaged public var repostedBy: [PFUser]
    @NSManaged public var postedBy: PFUser?
    @NSManaged public var userTimeline: PFUser
    @NSManaged public var hasSpoilers: Bool
    @NSManaged public var images: [String]?
    @NSManaged public var youtubeID: String?
    
    public var replies: [PFObject] {
        get {
           return (self["replies"] ?? [] ) as! [PFObject]
        }
        set (value) {
            self["replies"] = value
        }
    }
}