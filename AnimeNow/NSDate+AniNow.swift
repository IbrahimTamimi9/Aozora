//
//  NSDate+AniNow.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/11/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit

extension NSDate {

    public func mediumDate() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle

        return dateFormatter.stringFromDate(self)
    }
    
    public func daysAgo() -> Int {
        return Int(-timeIntervalSinceDate(NSDate()) / (60*60*24))
    }
    
}
