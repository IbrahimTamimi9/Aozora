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
    @IBOutlet weak var postsBadge: UILabel!
    @IBOutlet weak var tagBadge: UILabel!
    @IBOutlet weak var proBottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var settingsTrailingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableBottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var segmentedControlHeight: NSLayoutConstraint!
    
    var userProfile: User?
    var username: String?
    var followingUser: Bool?
    
    public func initWithUser(user: User) {
        self.userProfile = user
    }
    
    public func initWithUsername(username: String) {
        self.username = username
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if userProfile == nil && username == nil {
            userProfile = User.currentUser()!
            segmentedControl.selectedSegmentIndex = 0
        } else {
            segmentedControl.selectedSegmentIndex = 1
            tableBottomSpaceConstraint.constant = 0
        }
        
        fetchPosts()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let profile = userProfile where profile.details.isDataAvailable() {
            updateFollowingButtons()
        }
    }
    
    func sizeHeaderToFit() {
        var header = tableView.tableHeaderView!

        if userProfile != User.currentUser() {
            segmentedControlHeight.constant = 0
            segmentedControl.hidden = true
        }
        
        header.setNeedsLayout()
        header.layoutIfNeeded()
        
        aboutLabel.preferredMaxLayoutWidth = aboutLabel.frame.size.width
        
        var height = header.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        var frame = header.frame
        
        frame.size.height = height
        header.frame = frame
        tableView.tableHeaderView = header
    }

    // MARK: - Fetching
    
    override public func fetchPosts() {
        super.fetchPosts()
        let username = self.username ?? userProfile!.aozoraUsername
        fetchUserDetails(username)
    }
    
    func fetchUserDetails(username: String) {
        
        if let profile = self.userProfile {
            configureFetchController()
        }
        
        let query = User.query()!
        query.whereKey("aozoraUsername", equalTo: username)
        query.includeKey("details")
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in

            if let user = result?.last as? User {
                self.userProfile = user
                self.updateViewWithUser(user)
                self.aboutLabel.text = user.details.about
                if user.details.posts >= 1000 {
                    self.postsBadge.text = (user.details.posts/1000).description + "k"
                } else {
                    self.postsBadge.text = user.details.posts.description
                }
                
                self.updateFollowingButtons()
                self.sizeHeaderToFit()
                // Start fetching if didn't had User class
                if let _ = self.username {
                    self.configureFetchController()
                }
            }
        }
        
        if User.currentUser() != userProfile {
            
            let relationQuery = User.currentUser()!.following().query()!
            relationQuery.whereKey("aozoraUsername", equalTo: username)
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
    
    func updateViewWithUser(user: User) {
        usernameLabel.text = user.aozoraUsername
        title = user.aozoraUsername
        if let avatarFile = user.avatarThumb {
            userAvatar.setImageWithPFFile(avatarFile)
        }
        
        if let bannerFile = user.banner {
            userBanner.setImageWithPFFile(bannerFile)
        }
        
        if let _ = tabBarController {
            navigationItem.leftBarButtonItem = nil
        }
        
        proBadge.hidden = true
        
        if user == User.currentUser()! {
            followButton.hidden = true
            settingsTrailingSpaceConstraint.constant = 8
            
            if let _ = InAppController.purchasedProPlus() {
                proBadge.hidden = false
                proBadge.text = "PRO+"
            } else if let _ = InAppController.purchasedPro() {
                proBadge.hidden = false
                proBadge.text = "PRO"
            }
        } else {
            followButton.hidden = false
            settingsButton.hidden = true
        }
        
        if user.badges.count > 0 {
            tagBadge.hidden = false
            tagBadge.text = user.badges.first
        } else {
            tagBadge.hidden = true
            proBottomLayoutConstraint.constant = 4
        }
        
    }
    
    func updateFollowingButtons() {
        if let profile = userProfile {
            self.followingButton.setTitle("\(profile.details.followingCount) FOLLOWING", forState: .Normal)
            self.followersButton.setTitle("\(profile.details.followersCount) FOLLOWERS", forState: .Normal)
        }
    }
    
    func configureFetchController() {
        self.fetchController.configureWith(self, queryDelegate: self, tableView: self.tableView, limit: self.FetchLimit, datasourceUsesSections: true)
    }
    
    // MARK: - IBAction
    @IBAction func segmentedControlValueChanged(sender: AnyObject) {
        configureFetchController()
    }
    
    @IBAction func showLibrary(sender: AnyObject) {
        
    }
    
    @IBAction func followOrUnfollow(sender: AnyObject) {
        
        if let thisProfileUser = userProfile {
            if let followingUser = followingUser, let currentUser = User.currentUser() where userProfile != currentUser {
                
                if !followingUser {
                    // Follow
                    self.followButton.setTitle("  Following", forState: .Normal)
                    let followingRelation = currentUser.following()
                    followingRelation.addObject(thisProfileUser)
                    thisProfileUser.details.incrementKey("followersCount", byAmount: 1)
                    currentUser.details.incrementKey("followingCount", byAmount: 1)
                    thisProfileUser.details.saveEventually()
                    thisProfileUser.saveEventually()
                    currentUser.saveEventually()
                    PFCloud.callFunctionInBackground("sendFollowingPushNotification", withParameters: ["toUser":thisProfileUser.objectId!])
                    updateFollowingButtons()
                } else {
                    // Unfollow
                    self.followButton.setTitle("  Follow", forState: .Normal)
                    let followingRelation = currentUser.following()
                    followingRelation.removeObject(thisProfileUser)
                    thisProfileUser.details.incrementKey("followersCount", byAmount: -1)
                    currentUser.details.incrementKey("followingCount", byAmount: -1)
                    thisProfileUser.details.saveEventually()
                    thisProfileUser.saveEventually()
                    currentUser.saveEventually()
                    updateFollowingButtons()
                }
                
                self.followingUser = !followingUser
            }
        }
    }
    
    public override func replyToThreadPressed(sender: AnyObject) {
        super.replyToThreadPressed(sender)
        
        if let profile = userProfile where User.currentUserLoggedIn() {
            let comment = ANParseKit.newPostViewController()
            comment.initWithTimelinePost(self, postedIn: profile)
            presentViewController(comment, animated: true, completion: nil)
        } else {
            presentBasicAlertWithTitle("Login first", message: "Select 'Me' tab")
        }
    }
    
    @IBAction func showFollowingUsers(sender: AnyObject) {
        let userListController = UIStoryboard(name: "Profile", bundle: ANParseKit.bundle()).instantiateViewControllerWithIdentifier("UserList") as! UserListViewController
        let query = userProfile!.following().query()!
        userListController.initWithQuery(query, title: "Following")
        navigationController?.pushViewController(userListController, animated: true)
    }
    
    @IBAction func showFollowers(sender: AnyObject) {
        let userListController = UIStoryboard(name: "Profile", bundle: ANParseKit.bundle()).instantiateViewControllerWithIdentifier("UserList") as! UserListViewController
        let query = User.query()!
        query.whereKey("following", equalTo: userProfile!)
        userListController.initWithQuery(query, title: "Followers")
        navigationController?.pushViewController(userListController, animated: true)
    }
    
    @IBAction func showSettings(sender: AnyObject) {
        
        var alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alert.addAction(UIAlertAction(title: "Edit Profile", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction!) -> Void in
            let editProfileController =  UIStoryboard(name: "Profile", bundle: ANParseKit.bundle()).instantiateViewControllerWithIdentifier("EditProfile") as! EditProfileViewController
            editProfileController.delegate = self
            self.presentViewController(editProfileController, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction!) -> Void in
            let settings = UIStoryboard(name: "Settings", bundle: nil).instantiateInitialViewController() as! UINavigationController
            self.presentViewController(settings, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

extension ProfileViewController: EditProfileViewControllerProtocol {
    
    func editProfileViewControllerDidEditedUser(user: User) {
        userProfile = user
        fetchUserDetails(user.aozoraUsername)
    }
}

extension ProfileViewController: FetchControllerQueryDelegate {
    
    public override func queriesForSkip(#skip: Int) -> [PFQuery] {
        
        let innerQuery = TimelinePost.query()!
        innerQuery.skip = skip
        innerQuery.limit = FetchLimit
        innerQuery.whereKey("replyLevel", equalTo: 0)
        innerQuery.orderByDescending("createdAt")
        
        if segmentedControl.selectedSegmentIndex == 1 {
            // 'Me' query
            innerQuery.whereKey("userTimeline", equalTo: userProfile!)
        } else {
            innerQuery.whereKey("userTimeline", matchesQuery: userProfile!.following().query()!)
        }

        // 'Feed' query
        let query = innerQuery.copy() as! PFQuery
        query.includeKey("episode")
        query.includeKey("postedBy")
        query.includeKey("userTimeline")
        
        let repliesQuery = TimelinePost.query()!
        repliesQuery.skip = 0
        repliesQuery.limit = 1000
        repliesQuery.whereKey("parentPost", matchesQuery: innerQuery)
        repliesQuery.orderByAscending("createdAt")
        repliesQuery.includeKey("episode")
        repliesQuery.includeKey("postedBy")
        repliesQuery.includeKey("userTimeline")
        
        return [query, repliesQuery]
    }
}