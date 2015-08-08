//
//  TimelinePost.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/29/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Parse

public class Post: PFObject, PFSubclassing, ThreadPostable {
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
    
    
    public var createdDate: NSDate? {
        get {
            return createdAt
        }
    }
    
    public var episode: Episode? {
        get {
            return self["episode"] as? Episode
        }
    }
    
    public var youtubeID: String? {
        get {
            return self["youtubeID"] as? String
        }
        set(value) {
            self["youtubeID"] = value
        }
    }
    
    public var postedBy: User? {
        get {
            return self["postedBy"] as? User
        }
        set(value) {
            self["postedBy"] = value
        }
    }
    
    public var edited: Bool {
        get {
            return self["edited"] as? Bool ?? false
        }
        set(value) {
            self["edited"] = value
        }
    }
    
    public var content: String {
        get {
            return self["content"] as? String ?? ""
        }
        set(value) {
            self["content"] = value
        }
    }
    
    public var replyLevel: Int {
        get {
            return self["replyLevel"] as? Int ?? 0
        }
        set(value) {
            self["replyLevel"] = value
        }
    }
    
    public var replies: [PFObject]? {
        get {
            return self["replies"] as? [PFObject]
        }
        set(value) {
            self["replies"] = value
        }
    }
    
    public var images: [String]? {
        get {
            return self["images"] as? [String]
        }
        set(value) {
            self["images"] = value
        }
    }
    
    public var thread: Thread {
        get {
            return self["thread"] as! Thread
        }
        set(value) {
            self["thread"] = value
        }
    }
    
    public var hasSpoilers: Bool {
        get {
            return self["hasSpoilers"] as? Bool ?? false
        }
        set(value) {
            self["hasSpoilers"] = value
        }
    }
}