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

class UserFriendsViewController: UserBaseViewController {
    
    var dataSource: [ProfileViewController.Profile] = [] {
        didSet {
            tableView.reloadData()
            tableView.animateFadeIn()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        fetchUserFriends()
    }
    
    override func refreshPulled() {
        super.refreshPulled()
        fetchUserFriends()
    }
    
    func fetchUserFriends() {
        loadingView.startAnimating()
        userFriends().continueWithBlock
            { (task: BFTask!) -> AnyObject! in
                
                self.loadingView.stopAnimating()
                self.refreshControl.endRefreshing()
                
                if let result = task.result as? [[String: AnyObject]] {
                    
                    var profiles: [ProfileViewController.Profile] = []
                    for profileItem in result {
                        
                        var profile = ProfileViewController.Profile()
                        let profileInfo = profileItem["profile"] as! [String: AnyObject]
                        profile.username = profileItem["name"] as! String
                        profile.avatarURL = profileInfo["avatar_url"] as! String
                        
                        let lastOnlineString = (profileInfo["details"] as! [String:AnyObject])["last_online"] as! String
                        if let lastOnline = lastOnlineString.dateWithISO8601NoMinutes() ?? lastOnlineString.dateWithISO8601() {
                            profile.lastOnline = lastOnline.timeAgo()
                        }
                        profiles.append(profile)
                    }
                    
                    self.dataSource = profiles
                }
                
                return nil
        }
    }
    
    func userFriends() -> BFTask! {
        let completionSource = BFTaskCompletionSource()
        Alamofire.request(Atarashii.Router.friends(username: username)).validate().responseJSON { (req, res, JSON, error) -> Void in
            if error == nil {
                completionSource.setResult(JSON)
            } else {
                completionSource.setError(error)
            }
        }
        return completionSource.task
    }
    
    
}



extension UserFriendsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as! UserCell
        
        let profile = dataSource[indexPath.row]
        
        cell.avatar.setImageFrom(urlString: profile.avatarURL)
        cell.username.text = profile.username
        cell.lastOnline.text = profile.lastOnline
        
        cell.layoutIfNeeded()
        
        return cell
        
    }
    
}

extension UserFriendsViewController: UITableViewDelegate {
    
}
