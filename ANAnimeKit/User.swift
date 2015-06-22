//
//  User.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/20/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation

public class User {
    
    static let UsernameDefaultKey = "User.Username"
    static let PasswordDefaultKey = "User.Password"
    
    public class var username: String? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey(UsernameDefaultKey) as! String?
        }
        set(username) {
            NSUserDefaults.standardUserDefaults().setObject(username, forKey: UsernameDefaultKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    public class var password: String? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey(PasswordDefaultKey) as! String?
        }
        set(object) {
            NSUserDefaults.standardUserDefaults().setObject(object, forKey: PasswordDefaultKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    public class var loggedIn: Bool {
        get {
            return username != nil && password != nil
        }
    }
    
    public class func removeCredentials() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UsernameDefaultKey)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(PasswordDefaultKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}
