//
//  TimelinePost.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/29/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Parse

public class User: PFUser, PFSubclassing {
    
    override public class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    @NSManaged public var avatarThumb: PFFile?
    @NSManaged public var banner: PFFile?
    @NSManaged public var badges: [String]
    @NSManaged public var joinDate: NSDate
    @NSManaged public var aozoraUsername: String
    @NSManaged public var myAnimeListUsername: String
    @NSManaged public var anilistUsername: String
    @NSManaged public var syncingWithMyAnimeList: Bool
    @NSManaged public var syncingWithAnilist: Bool
    @NSManaged public var details: UserDetails
    @NSManaged public var followingCount: Int
    @NSManaged public var followersCount: Int
    
    public func following() -> PFRelation {
        return self["following"] as! PFRelation
    }

    public override class func currentUser() -> User? {
        return PFUser.currentUser() as? User
    }
    
}