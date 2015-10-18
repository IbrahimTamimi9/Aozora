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
            self["youtubeID"] = value ?? NSNull()
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
    
    public var subscribers: [User] {
        get {
            return self["subscribers"] as! [User]
        }
        set(value) {
            self["subscribers"] = value
        }
    }
    
    public var likedBy: [User]? {
        get {
            return self["likedBy"] as? [User]
        }
        set(value) {
            self["likedBy"] = value
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
    
    public var nonSpoilerContent: String? {
        get {
            return self["nonSpoilerContent"] as? String
        }
        set(value) {
            self["nonSpoilerContent"] = value ?? NSNull()
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
    
    public var parentPost: PFObject? {
        get {
            return self["parentPost"] as? PFObject
        }
        set(value) {
            self["parentPost"] = value
        }
    }
    
    var imagesInternal: [ImageData]!
    public var images: [ImageData] {
        get {
            if imagesInternal == nil {
                imagesInternal = []
                if let images = self["images"] as? [[String: AnyObject]] {
                    for image in images {
                        imagesInternal.append(ImageData.imageDataWithDictionary(image))
                    }
                }
            }
            return imagesInternal
        }
        set(value) {
            imagesInternal = value
            var imagesRaw: [[String: AnyObject]] = []
            for image in value {
                imagesRaw.append(image.toDictionary())
            }
            self["images"] = imagesRaw
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
    
    lazy var repliesInternal: [PFObject] = []
    public var replies: [PFObject] {
        get {
            return repliesInternal
        }
        set(value) {
            repliesInternal = value
        }
    }
    
    var isSpoilerHiddenInternal = true
    public var isSpoilerHidden: Bool {
        get {
            return isSpoilerHiddenInternal
        }
        set(value) {
            isSpoilerHiddenInternal = value
        }
    }
    
    var showAllRepliesInternal = false
    public var showAllReplies: Bool {
        get {
            return showAllRepliesInternal
        }
        set(value) {
            showAllRepliesInternal = value
        }
    }
    
}