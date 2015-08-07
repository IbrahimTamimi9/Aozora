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
    @NSManaged public var edited: Bool
    @NSManaged public var episode: Episode?
    @NSManaged public var repostedBy: [User]
    @NSManaged public var postedBy: User?
    @NSManaged public var userTimeline: User
    @NSManaged public var images: [String]?
    @NSManaged public var youtubeID: String?
    @NSManaged public var replies: [TimelinePost]
    
}