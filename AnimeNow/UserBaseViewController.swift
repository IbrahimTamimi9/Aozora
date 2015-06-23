//
//  UserBaseViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/22/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class UserBaseViewController: UIViewController {
    var profileSection: ProfileSection!
    var username: String!
    
    @IBOutlet weak var tableView: UITableView!
    
    func initWithProfileSection(profileSection: ProfileSection, username: String) {
        self.profileSection = profileSection
        self.username = username
    }
        
}

extension UserBaseViewController: XLPagerTabStripChildItem {
    func titleForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> String! {
        return profileSection.rawValue
    }
    
    func colorForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> UIColor! {
        return UIColor.whiteColor()
    }
}
