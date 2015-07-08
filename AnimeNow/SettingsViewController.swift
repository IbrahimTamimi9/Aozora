//
//  SettingsViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/28/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
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
            break
        case (1,0):
            let controller = UIStoryboard(name: "InApp", bundle: nil).instantiateInitialViewController() as! InAppPurchaseViewController
            navigationController?.pushViewController(controller, animated: true)
        case (2,0):
            break
        case (3,0):
            break
        case (3,1):
            break
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