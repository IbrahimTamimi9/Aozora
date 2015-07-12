//
//  NSUserDefaults+Dates.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/12/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation

extension NSUserDefaults {
    
    public class func shouldPerformAction(actionID: String, expirationDays: Double) -> Bool {
        let lastAction = NSUserDefaults.standardUserDefaults().objectForKey(actionID) as? NSDate ?? NSDate()
        let dayTimeInterval: Double = 24*60*60
        let timeIntervalSinceLastAction = -lastAction.timeIntervalSinceNow
        return timeIntervalSinceLastAction > (expirationDays * dayTimeInterval)
    }
    
    public class func completedAction(actionID: String) {
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: actionID)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}