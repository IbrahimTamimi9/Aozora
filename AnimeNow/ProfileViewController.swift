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
    
    var userProfile: User!
    var followingUser: Bool?
    
    public func initWithUser(user: User) {
        self.userProfile = user
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        userProfile = User.currentUser()!
        updateViewWithUser(userProfile)
        fetchPosts()
        fetchUserDetails()
    }
    
    override func fetchPosts() {
        super.fetchPosts()
        fetchController.configureWith(self, queryDelegate: self, tableView: tableView, limit: FetchLimit, datasourceUsesSections: true)
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
            settingsTrailingSpaceConstraint.constant = 8
            navigationItem.leftBarButtonItem = nil
        } else {
            followButton.hidden = false
            settingsButton.hidden = true
            //settingsTrailingSpaceConstraint.constant = 88
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
    
    func fetchUserDetails() {
        
        let query = User.query()!
        query.whereKey("objectId", equalTo: userProfile.objectId!)
        query.includeKey("details")
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if let user = result?.last as? User {
                self.userProfile = user
                self.updateViewWithUser(user)
                self.aboutLabel.text = user.details.about
            }
        }
        
        if User.currentUser() != userProfile {
            
            let relationQuery = User.currentUser()!.following().query()!
            relationQuery.whereKey("objectId", equalTo: userProfile.objectId!)
            relationQuery.findObjectsInBackgroundWithBlock { (result, error) -> Void in
                if let user = result?.last as? User {
                    // Following this user
                    self.followButton.setTitle("  Following", forState: .Normal)
                    self.followButton.layoutIfNeeded()
                    self.followingUser = true
                } else if let error = error {
                    // TODO: Show error
                    
                } else {
                    // NOT following this user
                    self.followButton.setTitle("  Follow", forState: .Normal)
                    self.followButton.layoutIfNeeded()
                    self.followingUser = false
                }
            }
        }
        
    }
    
    
    // MARK: - IBAction
    
    @IBAction func showLibrary(sender: AnyObject) {
        
    }
    
    @IBAction func followOrUnfollow(sender: AnyObject) {
        
        let thisProfileUser = self.userProfile
        if let followingUser = followingUser, let currentUser = User.currentUser() where thisProfileUser != currentUser {

            if !followingUser {
                // Follow
                self.followButton.setTitle("  Following", forState: .Normal)
                let followingRelation = currentUser.following()
                followingRelation.addObject(thisProfileUser)
                thisProfileUser.incrementKey("followersCount", byAmount: 1)
                currentUser.incrementKey("followingCount", byAmount: 1)
                thisProfileUser.saveEventually()
                currentUser.saveEventually()
                PFCloud.callFunctionInBackground("sendFollowingPushNotification", withParameters: ["toUser":thisProfileUser.objectId!])
                
            } else {
                // Unfollow
                self.followButton.setTitle("  Follow", forState: .Normal)
                let followingRelation = currentUser.following()
                followingRelation.removeObject(thisProfileUser)
                thisProfileUser.incrementKey("followersCount", byAmount: -1)
                currentUser.incrementKey("followingCount", byAmount: -1)
                thisProfileUser.saveEventually()
                currentUser.saveEventually()
            }
            
            self.followingUser = !followingUser
        }
    }
    
    public override func replyToThreadPressed(sender: AnyObject) {
        super.replyToThreadPressed(sender)
        
        let comment = ANParseKit.commentViewController()
        comment.initWithTimelinePost(self, postedIn: userProfile)
        presentViewController(comment, animated: true, completion: nil)
    }
    
    @IBAction func showFollowingUsers(sender: AnyObject) {
        let userListController = UIStoryboard(name: "Profile", bundle: ANParseKit.bundle()).instantiateViewControllerWithIdentifier("UserList") as! UserListViewController
        let query = userProfile.following().query()!
        userListController.initWithQuery(query, title: "Following")
        navigationController?.pushViewController(userListController, animated: true)
    }
    
    @IBAction func showFollowers(sender: AnyObject) {
        let userListController = UIStoryboard(name: "Profile", bundle: ANParseKit.bundle()).instantiateViewControllerWithIdentifier("UserList") as! UserListViewController
        let query = User.query()!
        query.whereKey("following", equalTo: userProfile)
        userListController.initWithQuery(query, title: "Followers")
        navigationController?.pushViewController(userListController, animated: true)
    }
    
    @IBAction func showSettings(sender: AnyObject) {
        
        var alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction!) -> Void in
            let settings = UIStoryboard(name: "Settings", bundle: nil).instantiateInitialViewController() as! UINavigationController
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

extension ProfileViewController: FetchControllerQueryDelegate {
    
    public override func queriesForSkip(#skip: Int) -> [PFQuery] {
        let query = TimelinePost.query()!
        query.skip = skip
        query.limit = FetchLimit
        query.whereKey("userTimeline", equalTo: userProfile)
        query.whereKey("replyLevel", equalTo: 0)
        query.orderByDescending("createdAt")
        query.includeKey("episode")
        query.includeKey("postedBy")
        query.includeKey("userTimeline")

        let innerQuery = TimelinePost.query()!
        innerQuery.skip = skip
        innerQuery.limit = FetchLimit
        innerQuery.whereKey("userTimeline", equalTo: userProfile)
        innerQuery.whereKey("replyLevel", equalTo: 0)
        innerQuery.orderByDescending("createdAt")
        
        let repliesQuery = TimelinePost.query()!
        repliesQuery.skip = 0
        repliesQuery.limit = 1000
        repliesQuery.whereKey("parentPost", matchesKey: "objectId", inQuery: innerQuery)
        repliesQuery.orderByAscending("createdAt")
        repliesQuery.includeKey("episode")
        repliesQuery.includeKey("postedBy")
        repliesQuery.includeKey("userTimeline")
        
        return [query, repliesQuery]
    }
}