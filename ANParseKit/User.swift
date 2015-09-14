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
    @NSManaged public var unlockedContent: [String]
    @NSManaged public var joinDate: NSDate
    @NSManaged public var aozoraUsername: String
    @NSManaged public var myAnimeListUsername: String?
    @NSManaged public var anilistUsername: String
    @NSManaged public var details: UserDetails
    
    public func following() -> PFRelation {
        return self.relationForKey("following")
    }

    public override class func currentUser() -> User? {
        return PFUser.currentUser() as? User
    }
    
    public class func currentUserLoggedIn() -> Bool {
        
        return PFUser.currentUser() != nil && !currentUserIsGuest()
    }
    
    public class func currentUserIsGuest() -> Bool {
        
        return PFAnonymousUtils.isLinkedWithUser(PFUser.currentUser())
    }
    
    public var myAnimeListPassword: String? {
        get {
        return NSUserDefaults.standardUserDefaults().objectForKey("MyAnimeList.Password") as! String?
        }
        set(object) {
            NSUserDefaults.standardUserDefaults().setObject(object, forKey: "MyAnimeList.Password")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    public class func logoutMyAnimeList() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("MyAnimeList.Password")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    public class func syncingWithMyAnimeList() -> Bool {
        return User.currentUser()!.myAnimeListPassword != nil
    }
    
    public func incrementPostCount(byAmount: Int) {
        details.incrementKey("posts", byAmount: byAmount)
        details.saveEventually()
    }
    
}