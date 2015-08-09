//
//  UserProfileViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/22/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANCommonKit
import TTTAttributedLabel
import XCDYouTubeKit
import Parse

public class ProfileViewController: ThreadViewController {
    
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userBanner: UIImageView!
    @IBOutlet weak var animeListButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var aboutLabel: UILabel!
    
    @IBOutlet weak var proBadge: UILabel!
    @IBOutlet weak var tagBadge: UILabel!
    @IBOutlet weak var proBottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var settingsTrailingSpaceConstraint: NSLayoutConstraint!
    
    var user = User.currentUser()!
    
    public func initWithUser(user: User) {
        self.user = user
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        updateViewWithUser(user)
        updateThread()
        fetchUserDetails()
    }
    
    override func updateThread() {
        super.updateThread()
        fetchUserFeed()
    }
    
    func updateViewWithUser(user: User) {
        usernameLabel.text = user.username
        title = user.aozoraUsername
        if let avatarFile = user.avatarThumb {
            userAvatar.setImageWithPFFile(avatarFile)
        }
        
        if let bannerFile = user.banner {
            userBanner.setImageWithPFFile(bannerFile)
        }
        followingButton.setTitle("\(user.followingCount) FOLLOWING", forState: .Normal)
        followersButton.setTitle("\(user.followersCount) FOLLOWERS", forState: .Normal)
        
        if user == User.currentUser() {
            followButton.hidden = true
            animeListButton.hidden = true
            settingsTrailingSpaceConstraint.constant = 8
            navigationItem.leftBarButtonItem = nil
        } else {
            followButton.hidden = false
            animeListButton.hidden = false
            navigationItem.rightBarButtonItems = nil
            settingsTrailingSpaceConstraint.constant = 88
        }
        
        if user.badges.count > 0 {
            tagBadge.text = user.badges.first
        } else {
            tagBadge.hidden = true
            proBottomLayoutConstraint.constant = 4
        }
        
        if let _ = InAppController.purchasedProPlus() {
            proBadge.text = "PRO+"
        } else if let _ = InAppController.purchasedPro() {
            proBadge.text = "PRO"
        } else {
            proBadge.hidden = true
        }
    }
    
    // MARK: - Fetching
    
    func fetchUserFeed() {
        let query = TimelinePost.query()!
        query.skip = 0
        query.whereKey("userTimeline", equalTo: user)
        query.whereKey("replyLevel", equalTo: 0)
        query.orderByDescending("createdAt")
        query.includeKey("episode")
        query.includeKey("postedBy")
        query.includeKey("userTimeline")
        query.includeKey("replies")
        fetchController.configureWith(self, query: query, tableView: tableView)
    }
    
    func fetchUserDetails() {
        
        let query = User.query()!
        query.whereKey("objectId", equalTo: user.objectId!)
        query.includeKey("details")
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if let user = result?.last as? User {
                self.updateViewWithUser(user)
                self.aboutLabel.text = user.details.about
            }
        }
    }
    
    
    // MARK: - IBAction
    
    @IBAction func showLibrary(sender: AnyObject) {
        
    }
    
    @IBAction func followOrUnfollow(sender: AnyObject) {
        
    }
    
    public override func replyToThreadPressed(sender: AnyObject) {
        super.replyToThreadPressed(sender)
        
        let comment = ANParseKit.commentViewController()
        comment.initWithTimelinePost(self)
        presentViewController(comment, animated: true, completion: nil)
    }
    
    @IBAction func showFollowingUsers(sender: AnyObject) {
        let userListController = UIStoryboard(name: "Profile", bundle: ANParseKit.bundle()).instantiateViewControllerWithIdentifier("UserList") as! UserListViewController
        let query = user.following().query()!
        userListController.initWithQuery(query, title: "Following")
        navigationController?.pushViewController(userListController, animated: true)
    }
    
    @IBAction func showFollowers(sender: AnyObject) {
        let userListController = UIStoryboard(name: "Profile", bundle: ANParseKit.bundle()).instantiateViewControllerWithIdentifier("UserList") as! UserListViewController
        let query = User.query()!
        query.whereKey("following", equalTo: user)
        userListController.initWithQuery(query, title: "Followers")
        navigationController?.pushViewController(userListController, animated: true)
    }
    
    @IBAction func showSettings(sender: AnyObject) {
        
        var alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction!) -> Void in
            let settings = UIStoryboard(name: "Settings", bundle: ANParseKit.bundle()).instantiateInitialViewController() as! UINavigationController
            self.presentViewController(settings, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Edit Profile", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction!) -> Void in
            let editProfileController =  UIStoryboard(name: "Profile", bundle: ANParseKit.bundle()).instantiateViewControllerWithIdentifier("EditProfile") as! EditProfileViewController
            editProfileController.delegate = self
            self.presentViewController(editProfileController, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

extension ProfileViewController: EditProfileViewControllerProtocol {
    
    func editProfileViewControllerDidEditedUser() {
        fetchUserDetails()
    }
}