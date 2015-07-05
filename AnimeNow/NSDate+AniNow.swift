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
    
    public func daysAgo() -> Int {
        return Int(-timeIntervalSinceDate(NSDate()) / (60*60*24))
    }
    
}
