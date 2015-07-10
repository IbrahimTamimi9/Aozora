//
//  InAppPurchaseController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/9/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import RMStore

let PurchasedProNotification = "InApps.Purchased.Pro"

let ProInAppPurchase = "com.anytap.Aozora.Pro"
let ProPlusInAppPurchase = "com.anytap.Aozora.ProPlus"

class InAppPurchaseController {
    
    class func purchasedAnyPro() -> Int? {

        return (purchasedPro() != nil || purchasedProPlus() != nil) ? 1 : nil
    }
    
    class func purchasedPro() -> Int? {
        let pro = NSUserDefaults.standardUserDefaults().boolForKey(ProInAppPurchase)
        return pro ? 1 : nil
    }
    
    class func purchasedProPlus() -> Int? {
        let proPlus = NSUserDefaults.standardUserDefaults().boolForKey(ProPlusInAppPurchase)
        return proPlus ? 1 : nil
    }
    
    class func purchaseProductWithID(productID: String) -> BFTask {
        let completionSource = BFTaskCompletionSource()
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        RMStore.defaultStore().addPayment(productID, success: { (transaction: SKPaymentTransaction!) -> Void in
            self.purchaseCompleted([transaction])
            completionSource.setResult([transaction])
        }) { (transaction: SKPaymentTransaction!, error: NSError!) -> Void in
            self.purchaseFailed(nil, error: error)
            completionSource.setError(error)
        }
        
        return completionSource.task
    }
    
    class func restorePurchases() -> BFTask {
        let completionSource = BFTaskCompletionSource()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        RMStore.defaultStore().restoreTransactionsOnSuccess({ (transactions) -> Void in
            let allTransactions = transactions as! [SKPaymentTransaction]
            self.purchaseCompleted(allTransactions)
            completionSource.setResult(allTransactions)
        }, failure: { (error) -> Void in
            self.purchaseFailed(nil, error: error)
            completionSource.setError(error)
        })
        
        return completionSource.task
    }
    
    class func purchaseCompleted(transactions: [SKPaymentTransaction]) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        for transaction in transactions {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: transaction.payment.productIdentifier)
        }
        NSUserDefaults.standardUserDefaults().synchronize()
        
        // Unlock..
        NSNotificationCenter.defaultCenter().postNotificationName(PurchasedProNotification, object: nil)
        
    }
    
    class func purchaseFailed(transaction: SKPaymentTransaction?, error: NSError) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        var alert = UIAlertController(title: "Payment Transaction Failed", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        
        if let window = UIApplication.sharedApplication().delegate?.window {
            window?.rootViewController!.presentViewController(alert, animated: true, completion: nil)
        }

    }
}