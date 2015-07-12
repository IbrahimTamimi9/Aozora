//
//  PFQuery+LocalDatastore.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/12/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import ANCommonKit
import Parse
import Bolts

extension PFQuery {
    public func findCachedOrNetwork(pinName: String, expirationDays: Int = 1) -> BFTask {
        
        let expired = NSUserDefaults.shouldPerformAction(pinName, expirationDays: Double(expirationDays))
        
        var fetchResult: [AnyObject] = []
        let nonLocalQuery = self.copy() as! PFQuery
        return self.fromPinWithName(pinName).findObjectsInBackground().continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
            if task.result.count == 0 || expired {
                // Not cached, fetch from network
                println("Objects from network..")
                return nonLocalQuery.findObjectsInBackground()
            } else {
                println("Objects from localdatastore..")
                fetchResult += task.result as! [AnyObject]
                return nil
            }
            
            }.continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
                
                if let result = task.result as? [AnyObject] where result.count != 0 {
                    
                    NSUserDefaults.completedAction(pinName)
                    PFObject.unpinAllObjectsInBackgroundWithName(pinName).continueWithBlock({ (task: BFTask!) -> AnyObject! in
                        PFObject.pinAllInBackground(result, withName: pinName)
                    })
                    fetchResult += result
                }
                
                return BFTask(result: fetchResult)
        }
    }
}