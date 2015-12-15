//
//  String+Utils.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 12/14/15.
//  Copyright © 2015 AnyTap. All rights reserved.
//

import Foundation

extension String {
    func endsWith(str: String) -> Bool {
        if let range = self.rangeOfString(str, options:NSStringCompareOptions.BackwardsSearch) {
            return range.endIndex == self.endIndex
        }
        return false
    }
}