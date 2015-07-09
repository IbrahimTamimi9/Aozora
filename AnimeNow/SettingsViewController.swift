//
//  SettingsViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/28/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import iRate

class SettingsViewController: UITableViewController {
    
    let FacebookPageDeepLink = "fb://profile/713541968752502";
    let FacebookPageURL = "http://www.facebook.com/AozoraApp";
    let TwitterPageDeepLink = "twitter://user?id=3366576341";
    let TwitterPageURL = "http://www.twitter.com/AozoraApp";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // MARK: - IBActions
    
    @IBAction func dismissPressed(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - TableView functions
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            break // Login / Logout
        case (1,0):
            // Unlock features
            let controller = UIStoryboard(name: "InApp", bundle: nil).instantiateInitialViewController() as! InAppPurchaseViewController
            navigationController?.pushViewController(controller, animated: true)
        case (1,1):
            break // Restore purchases
        case (2,0):
            // Rate app
            iRate.sharedInstance().openRatingsPageInAppStore()
        case (3,0):
            // Open Facebook
            var url: NSURL?
            if let twitterScheme = NSURL(string: "fb://requests") where UIApplication.sharedApplication().canOpenURL(twitterScheme) {
                url = NSURL(string: FacebookPageDeepLink)
            } else {
                url = NSURL(string: FacebookPageURL)
            }
            UIApplication.sharedApplication().openURL(url!)
        case (3,1):
            // Open Twitter
            var url: NSURL?
            if let twitterScheme = NSURL(string: "twitter://") where UIApplication.sharedApplication().canOpenURL(twitterScheme) {
                url = NSURL(string: TwitterPageDeepLink)
            } else {
                url = NSURL(string: TwitterPageURL)
            }
            UIApplication.sharedApplication().openURL(url!)
        default:
            break
        }
        
        
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return nil
        case 1:
            return "Going pro unlocks lots of awesome features and help us keep improving the app"
        case 2:
            return "If you're looking for support drop us a message on Facebook or Twitter"
        case 3:
            return "Created from Anime fans for Anime fans, enjoy!\nAozora 1.0.0"
        default:
            return nil
        }
    }
}