//
//  PFUser+CurrentUser.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/30/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Parse

extension PFUser {

    class public var malUsername: String? {
        get {
            if let currentUser = PFUser.currentUser() {
                return currentUser["myAnimeListUsername"] as! String?
            } else {
                return nil
            }
        }
        set(object) {
            if let currentUser = PFUser.currentUser() {
                currentUser["myAnimeListUsername"] = object
                currentUser.saveEventually()
            }
        }
    }
    
    class public var malPassword: String? {
        get {
        return NSUserDefaults.standardUserDefaults().objectForKey("User.Password") as! String?
        }
        set(object) {
            NSUserDefaults.standardUserDefaults().setObject(object, forKey: "User.Password")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    class public func currentUserLoggedIn() -> Bool {
        
        return PFUser.currentUser() != nil && !currentUserIsGuest() && loggedInWithMyAnimeList()
    }
    
    class public func currentUserIsGuest() -> Bool {
        
        return PFAnonymousUtils.isLinkedWithUser(PFUser.currentUser())
    }
    
    class public func removeCredentials() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("User.Password")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func loggedInWithMyAnimeList() -> Bool {
        return malPassword != nil
    }
    
}