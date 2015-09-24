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
    @NSManaged public var startedBy: User?
    @NSManaged public var lastPostedBy: User?
    @NSManaged public var subscribers: [User]
    @NSManaged public var replies: Int
    @NSManaged public var tags: [PFObject]
    
    @NSManaged public var content: String?
    @NSManaged public var hasSpoilers: Bool
    @NSManaged public var locked: Bool
    @NSManaged public var edited: Bool
    @NSManaged public var pinType: String?
    @NSManaged public var youtubeID: String?
    
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
}