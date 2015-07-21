//
//  UserBaseViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/22/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import ANCommonKit

class UserBaseViewController: UIViewController {
    var profileSection: ProfileSection!
    var username: String!
    
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl = UIRefreshControl()
    var loadingView: LoaderView!
    
    func initWithProfileSection(profileSection: ProfileSection, username: String) {
        self.profileSection = profileSection
        self.username = username
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView = LoaderView(parentView: view)
        
        addRefreshControl()
    }
    
    func addRefreshControl() {
        refreshControl.tintColor = UIColor.lightGrayColor()
        refreshControl.addTarget(self, action: "refreshPulled", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: tableView.subviews.count - 1)
        tableView.alwaysBounceVertical = true
    }
    
    func refreshPulled() {
        
        // Add in subclasses
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
