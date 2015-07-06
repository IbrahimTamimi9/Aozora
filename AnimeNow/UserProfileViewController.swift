//
//  UserProfileViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/22/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANCommonKit

class UserProfileViewController: UserBaseViewController {
    
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lastOnlineLabel: UILabel!
    
    let HeaderCellHeight: CGFloat = 39
    
    var profile: ProfileViewController.Profile? {
        didSet {
            usernameLabel.text = profile?.username
            if let date = profile?.lastOnline.dateWithISO8601() {
                self.lastOnlineLabel.text = date.timeAgo()
            }
            self.userAvatar.setImageFrom(urlString: profile?.avatarURL)
            
            tableView.reloadData()
        }
    }
    
    func setUserProfile(profile: ProfileViewController.Profile) {
        self.profile = profile
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
}


extension UserProfileViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return profile != nil ? 3 : 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows = 0
        switch section {
        case 0: numberOfRows = 5
        case 1: numberOfRows = 7
        case 2: numberOfRows = 7
        default: break
        }
        
        return profile != nil ? numberOfRows : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("InformationCell") as! BasicTableCell
        
        var title: String?
        var subtitle: String?
        switch (indexPath.section,indexPath.row) {
            case (0,0):
                title = "Gender"
                subtitle = profile?.gender
            case (0,1):
                title = "Join Date"
                subtitle = profile?.joinDate
            case (0,2):
                title = "Anime list views"
                subtitle = profile?.animeListViews.description
            case (0,3):
                title = "Manga list views"
                subtitle = profile?.mangaListViews.description
            case (0,4):
                title = "Forum posts"
                subtitle = profile?.forumPosts.description
            case (1,0):
                title = "Time Days"
                subtitle = profile?.animeStats.timeDays.description
            case (1,1):
                title = "Watching"
                subtitle = profile?.animeStats.watching.description
            case (1,2):
                title = "Completed"
                subtitle = profile?.animeStats.completed.description
            case (1,3):
                title = "On Hold"
                subtitle = profile?.animeStats.onHold.description
            case (1,4):
                title = "Droped"
                subtitle = profile?.animeStats.dropped.description
            case (1,5):
                title = "Plan to watch"
                subtitle = profile?.animeStats.planToWatch.description
            case (1,6):
                title = "Total entries"
                subtitle = profile?.animeStats.totalEntries.description
            case (2,0):
                title = "Time Days"
                subtitle = profile?.mangaStats.timeDays.description
            case (2,1):
                title = "Reading"
                subtitle = profile?.mangaStats.reading.description
            case (2,2):
                title = "Completed"
                subtitle = profile?.mangaStats.completed.description
            case (2,3):
                title = "On Hold"
                subtitle = profile?.mangaStats.onHold.description
            case (2,4):
                title = "Dropped"
                subtitle = profile?.mangaStats.dropped.description
            case (2,5):
                title = "Plan to read"
                subtitle = profile?.mangaStats.planToRead.description
            case (2,6):
                title = "Total entries"
                subtitle = profile?.mangaStats.totalEntries.description
        default: break
        }
        
        cell.titleLabel.text = title
        cell.subtitleLabel.text = subtitle
        
        cell.layoutIfNeeded()
        return cell

    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! BasicTableCell
        var title = ""
        
        switch section {
        case 0:
            title = "Details"
        case 1:
            title = "Anime Stats"
        case 2:
            title = "Manga Stats"
        default: break
        }
        
        cell.titleLabel.text = title
        return cell.contentView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HeaderCellHeight
    }
    
}

extension UserProfileViewController: UITableViewDelegate {
    
}