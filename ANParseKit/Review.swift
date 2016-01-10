//
//  Review.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 1/9/16.
//  Copyright © 2016 AnyTap. All rights reserved.
//

import Foundation
import Parse

public class Review: PFObject, PFSubclassing, Postable {
    
    override public class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    public class func parseClassName() -> String {
        return "Review"
    }
    
    @NSManaged public var anime: Anime
    @NSManaged public var summary: String
    @NSManaged public var upvotes: Int
    @NSManaged public var downvotes: Int
    
    // Pointing
    @NSManaged public var overallScore: Int
    @NSManaged public var storyScore: Int
    @NSManaged public var animationScore: Int
    @NSManaged public var soundScore: Int
    @NSManaged public var charactersScore: Int
    @NSManaged public var enjoymentScore: Int

    public var imagesDataInternal: [ImageData]?
    public var linkDataInternal: LinkData?
}

