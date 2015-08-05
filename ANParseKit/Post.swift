//
//  TimelinePost.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/29/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Parse

public class Post: PFObject, PFSubclassing {
    override public class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    public class func parseClassName() -> String {
        return "Post"
    }
    
    @NSManaged public var content: String
    @NSManaged public var replyLevel: Int
    @NSManaged public var postedBy: User?
    @NSManaged public var thread: Thread
    @NSManaged public var hasSpoilers: Bool
    @NSManaged public var images: [String]?
    @NSManaged public var youtubeID: String?
    @NSManaged public var replies: [Post]
}