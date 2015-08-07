//
//  String+Validations.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 8/7/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import ANParseKit

extension String {
    func validEmail(viewController: UIViewController) -> Bool {
        let email = self.stringByReplacingOccurrencesOfString(" ", withString: "")
        let emailRegex = "[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?"
        let regularExpression = NSRegularExpression(pattern: emailRegex, options: NSRegularExpressionOptions.CaseInsensitive, error: nil)
        let matches = regularExpression?.numberOfMatchesInString(self, options: nil, range: NSMakeRange(0, count(self)))
        
        let validEmail = (matches == 1)
        if !validEmail {
            viewController.presentBasicAlertWithTitle("Invalid email")
        }
        return validEmail
    }
    
    func validPassword(viewController: UIViewController) -> Bool {
        
        let validPassword = count(self) >= 6
        if !validPassword {
            viewController.presentBasicAlertWithTitle("Invalid password", message: "Length should be at least 6 characters")
        }
        return validPassword
    }
    
    func validUsername(viewController: UIViewController) -> Bool {
        
        switch self {
        case let _ where count(self) < 3:
            viewController.presentBasicAlertWithTitle("Invalid username", message: "Make it 3 characters or longer")
            return false
        case let _ where self.rangeOfString(" ") != nil:
            viewController.presentBasicAlertWithTitle("Invalid username", message: "It can't have spaces")
            return false
        default:
            return true
        }
    }
    
    func usernameIsUnique() -> BFTask {
        let query = User.query()!
        query.limit = 1
        query.whereKey("aozoraUsername", equalTo: self)
        return query.findObjectsInBackground()
    }
}