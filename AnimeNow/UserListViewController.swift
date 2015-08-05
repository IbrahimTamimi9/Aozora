//
//  UserFriendsViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/22/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import Alamofire
import Bolts
import ANCommonKit
import ANParseKit

class UserListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var user: User = User.currentUser()!
    var loadingView: LoaderView!
    
    var dataSource: [User] = []
    var titleToSet = ""
    func initWithList(userList: [User], title: String) {
        dataSource = userList
        titleToSet = title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = titleToSet
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        loadingView = LoaderView(parentView: view)
        
        fetchUserFriends()
    }
    
    func fetchUserFriends() {
        
        loadingView.startAnimating()
        
        PFObject.fetchAllIfNeededInBackground(dataSource, block: { (result, error) -> Void in
            
            if let result = result as? [User] {
                self.dataSource = result
            }
            
            self.loadingView.stopAnimating()
            self.tableView.reloadData()
            self.tableView.animateFadeIn()
        })
    }
}

extension UserListViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as! UserCell
        
        let profile = dataSource[indexPath.row]
        let avatarFile = profile.avatarThumb
        cell.avatar.setImageWithPFFile(avatarFile)
        cell.username.text = profile.username
        cell.layoutIfNeeded()
        
        return cell
        
    }

}

extension UserListViewController: UITableViewDelegate {
    
}
