//
//  NSDate+AniNow.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/11/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit

extension NSDate {

    var mediumFormatter: NSDateFormatter {
        struct Static {
            static let instance : NSDateFormatter = {
                let formatter = NSDateFormatter()
                formatter.dateStyle = NSDateFormatterStyle.MediumStyle
                return formatter
                }()
        }
        return Static.instance
    }
    
    public func mediumDate() -> String {
        return mediumFormatter.stringFromDate(self)
    }
    
    public func timeAgo() -> String {
        
        var timeInterval = Int(-timeIntervalSinceDate(NSDate()))
        
        if let daysAgo = timeInterval / (60*60*24) as Int? where daysAgo > 0 {
            return "\(daysAgo) " + (daysAgo == 1 ? "day" : "days")
        } else if let hoursAgo = timeInterval / (60*60) as Int? where hoursAgo > 0 {
            return "\(hoursAgo) " + (hoursAgo == 1 ? "hr" : "hrs")
        } else if let minutesAgo = timeInterval / 60 as Int? where minutesAgo > 0 {
            return "\(minutesAgo) " + (minutesAgo == 1 ? "min" : "mins")
        } else {
            return "Just now"
        }
    }
    
}
