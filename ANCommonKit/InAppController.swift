//
//  InAppController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/10/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation

public let ProInAppPurchase = "com.anytap.Aozora.Pro"
public let ProPlusInAppPurchase = "com.anytap.Aozora.ProPlus"

public class InAppController {
    
    public class func purchasedAnyPro() -> Int? {
        return (purchasedPro() != nil ||
                purchasedProPlus() != nil) ? 1 : nil
    }
    
    public class func purchasedPro() -> Int? {
        let user = User.currentUser()
        let identifier = ProInAppPurchase
        let pro = NSUserDefaults.standardUserDefaults().boolForKey(identifier) ||
            (user != nil ? contains(user!.unlockedContent, identifier) : false)
        return pro ? 1 : nil
    }
    
    public class func purchasedProPlus() -> Int? {
        let user = User.currentUser()
        let identifier = ProPlusInAppPurchase
        let proPlus = NSUserDefaults.standardUserDefaults().boolForKey(identifier) ||
        (user != nil ? contains(user!.unlockedContent, identifier) : false)
        return proPlus ? 1 : nil
    }
}
