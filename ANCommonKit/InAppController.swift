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
        #if DEBUG
            return 1
        #else
            return (purchasedPro() != nil || purchasedProPlus() != nil) ? 1 : nil
        #endif
    }
    
    public class func purchasedPro() -> Int? {
        let pro = NSUserDefaults.standardUserDefaults().boolForKey(ProInAppPurchase)
        return pro ? 1 : nil
    }
    
    public class func purchasedProPlus() -> Int? {
        let proPlus = NSUserDefaults.standardUserDefaults().boolForKey(ProPlusInAppPurchase)
        return proPlus ? 1 : nil
    }
}
