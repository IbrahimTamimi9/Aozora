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
import ANParseKit

public class ProfileViewController: ThreadViewController {
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var notificationsButton: UIButton!
    
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userBanner: UIImageView!
    @IBOutlet weak var animeListButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var aboutLabel: TTTAttributedLabel!
    @IBOutlet weak var activeAgo: UILabel!
    
    @IBOutlet weak var proBadge: UILabel!
    @IBOutlet weak var postsBadge: UILabel!
    @IBOutlet weak var tagBadge: UILabel!
    @IBOutlet weak var proBottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var settingsTrailingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableBottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var segmentedControlHeight: NSLayoutConstraint!
    
    public var userProfile: User?
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
        
        aboutLabel.linkAttributes = [kCTForegroundColorAttributeName: UIColor.peterRiver()]
        aboutLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
        aboutLabel.delegate = self;
        
        fetchPosts()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newNotifications", name: "newNotification", object: nil)
        
        checkIfThereAreNotifications()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let profile = userProfile where profile.details.isDataAvailable() {
            updateFollowingButtons()
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func newNotifications() {
        notificationsButton.setTitle("", forState: .Normal)
    }
    
    func noNewNotifications() {
        notificationsButton.setTitle("", forState: .Normal)
    }
    
    func sizeHeaderToFit() {
        let header = tableView.tableHeaderView!
        
        if userProfile != User.currentUser() {
            segmentedControlHeight.constant = 0
            segmentedControl.hidden = true
        }
        
        header.setNeedsLayout()
        header.layoutIfNeeded()
        
        aboutLabel.preferredMaxLayoutWidth = aboutLabel.frame.size.width
        
        let height = header.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        var frame = header.frame
        
        frame.size.height = height
        header.frame = frame
        tableView.tableHeaderView = header
    }
    
    func checkIfThereAreNotifications() {
        // TODO: Fix this mess with notificationsViewController
        let query = Notification.query()!
        query.limit = 50
        query.includeKey("readBy")
        query.includeKey("triggeredBy")
        query.whereKey("subscribers", containedIn: [User.currentUser()!])
        query.orderByDescending("lastUpdatedAt")
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if let result = result as? [Notification] {
                let unreadNotifications = result.filter { (notification: PFObject) -> Bool in
                    let notification = notification as! Notification
                    return !notification.readBy.contains(User.currentUser()!) && (notification.triggeredBy.count > 1 || (notification.triggeredBy.count == 1 && notification.triggeredBy.last != User.currentUser()!))
                }
                if unreadNotifications.count == 0 {
                    self.noNewNotifications()
                } else {
                    self.newNotifications()
                }
            }
        }
    }
    
    // MARK: - Fetching
    
    override public func fetchPosts() {
        super.fetchPosts()
        let username = self.username ?? userProfile!.aozoraUsername
        fetchUserDetails(username)
    }
    
    func fetchUserDetails(username: String) {
        
        if let _ = self.userProfile {
            configureFetchController()
        }
        
        let query = User.query()!
        query.whereKey("aozoraUsername", equalTo: username)
        query.includeKey("details")
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            
            if let user = result?.last as? User {
                self.userProfile = user
                self.updateViewWithUser(user)
                self.aboutLabel.setText(user.details.about, afterInheritingLabelAttributesAndConfiguringWithBlock: { (attributedString) -> NSMutableAttributedString! in
                    return attributedString
                })
                
                let activeEndString = user.activeEnd.timeAgo()
                let activeEndStringFormatted = activeEndString == "Just now" ? "active now" : "\(activeEndString) ago"
                self.activeAgo.text = user.active ? "active now" : activeEndStringFormatted
                
                if user.details.posts >= 1000 {
                    self.postsBadge.text = String(format: "%.1fk", Float(user.details.posts-49)/1000.0 )
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
        
        if User.currentUser() != userProfile && !User.currentUserIsGuest() {
            let relationQuery = User.currentUser()!.following().query()!
            relationQuery.whereKey("aozoraUsername", equalTo: username)
            relationQuery.findObjectsInBackgroundWithBlock { (result, error) -> Void in
                if let _ = result?.last as? User {
                    // Following this user
                    self.followButton.setTitle("  Following", forState: .Normal)
                    self.followButton.layoutIfNeeded()
                    self.followingUser = true
                } else if let _ = error {
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
        
        let proPlusString = "PRO+"
        let proString = "PRO"
        
        proBadge.hidden = true
        
        if user == User.currentUser() {
            // If is current user, only show PRO when unlocked in-apps
            if let _ = InAppController.purchasedProPlus() {
                proBadge.hidden = false
                proBadge.text = proPlusString
            } else if let _ = InAppController.purchasedPro() {
                proBadge.hidden = false
                proBadge.text = proString
            }
        } else {
            if user.badges.indexOf(proPlusString) != nil {
                proBadge.hidden = false
                proBadge.text = proPlusString
            } else if user.badges.indexOf(proString) != nil {
                proBadge.hidden = false
                proBadge.text = proString
            }
        }
        
        
        if user.isAdmin() {
            tagBadge.backgroundColor = UIColor.aozoraPurple()
        }
        
        if User.currentUserIsGuest() {
            followButton.hidden = true
            notificationsButton.hidden = true
            settingsButton.hidden = true
        } else if user == User.currentUser()! {
            followButton.hidden = true
            settingsTrailingSpaceConstraint.constant = -10
        } else {
            followButton.hidden = false
            notificationsButton.hidden = true
        }
        
        var hasABadge = false
        for badge in user.badges where badge != proString && badge != proPlusString {
            tagBadge.text = badge
            hasABadge = true
            break
        }
        
        if hasABadge {
            tagBadge.hidden = false
        } else {
            tagBadge.hidden = true
            proBottomLayoutConstraint.constant = 4
        }
    }
    
    func updateFollowingButtons() {
        if let profile = userProfile {
            followingButton.setTitle("\(profile.details.followingCount) FOLLOWING", forState: .Normal)
            followersButton.setTitle("\(profile.details.followersCount) FOLLOWERS", forState: .Normal)
        }
    }
    
    func configureFetchController() {
        let offset = tableView.contentOffset
        fetchController.configureWith(self, queryDelegate: self, tableView: self.tableView, limit: self.FetchLimit, datasourceUsesSections: true)
        tableView.setContentOffset(offset, animated: false)
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
                    PFCloud.callFunctionInBackground("sendFollowingPushNotificationV2", withParameters: ["toUser":thisProfileUser.objectId!])
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
    
    
    // MARK: - FetchControllerQueryDelegate
    
    public override func queriesForSkip(skip skip: Int) -> [PFQuery]? {
        
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
        repliesQuery.whereKey("parentPost", matchesKey: "objectId", inQuery: innerQuery)
        repliesQuery.orderByAscending("createdAt")
        repliesQuery.includeKey("episode")
        repliesQuery.includeKey("postedBy")
        repliesQuery.includeKey("userTimeline")
        
        return [query, repliesQuery]
    }
    
    
    // MARK: - CommentViewControllerDelegate
    
    public override func commentViewControllerDidFinishedPosting(newPost: PFObject, parentPost: PFObject?, edited: Bool) {
        super.commentViewControllerDidFinishedPosting(newPost, parentPost: parentPost, edited: edited)
        
        if edited {
            // Don't insert if edited
            tableView.reloadData()
            return
        }
        
        if let parentPost = parentPost {
            // Inserting a new reply in-place
            var parentPost = parentPost as! Postable
            parentPost.replies.append(newPost)
            tableView.reloadData()
        } else if parentPost == nil {
            // Inserting a new post in the top, if we're in the top of the thread
            fetchController.dataSource.insert(newPost, atIndex: 0)
            tableView.reloadData()
        }
    }
    
    
    // MARK: - FetchControllerDelegate
    
    public override func didFetchFor(skip skip: Int) {
        super.didFetchFor(skip: skip)
    }
    
    
    // MARK: - IBActions
    
    @IBAction func showFollowingUsers(sender: AnyObject) {
        let userListController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("UserList") as! UserListViewController
        let query = userProfile!.following().query()!
        query.orderByAscending("aozoraUsername")
        userListController.initWithQuery(query, title: "Following")
        navigationController?.pushViewController(userListController, animated: true)
    }
    
    @IBAction func showFollowers(sender: AnyObject) {
        let userListController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("UserList") as! UserListViewController
        let query = User.query()!
        query.whereKey("following", equalTo: userProfile!)
        query.orderByAscending("aozoraUsername")
        userListController.initWithQuery(query, title: "Followers")
        navigationController?.pushViewController(userListController, animated: true)
    }
    
    @IBAction func showSettings(sender: AnyObject) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alert.addAction(UIAlertAction(title: "View Library", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction) -> Void in
            if let userProfile = self.userProfile {
                let navVC = UIStoryboard(name: "Library", bundle: nil).instantiateViewControllerWithIdentifier("PublicLibraryNav") as! UINavigationController
                let publicList = navVC.viewControllers.first as! PublicListViewController
                publicList.initWithUser(userProfile)
                self.presentViewController(navVC, animated: true, completion: nil)
            }
        }))
        
        if userProfile == User.currentUser()! {
            alert.addAction(UIAlertAction(title: "Edit Profile", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction) -> Void in
                let editProfileController =  UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("EditProfile") as! EditProfileViewController
                editProfileController.delegate = self
                self.presentViewController(editProfileController, animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction) -> Void in
                let settings = UIStoryboard(name: "Settings", bundle: nil).instantiateInitialViewController() as! UINavigationController
                self.presentViewController(settings, animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Online Users", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction) -> Void in
                let userListController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("UserList") as! UserListViewController
                let query = User.query()!
                query.whereKeyExists("aozoraUsername")
                query.whereKey("active", equalTo: true)
                query.limit = 100
                userListController.initWithQuery(query, title: "Online Users")
                self.navigationController?.pushViewController(userListController, animated: true)
            }))
            
            alert.addAction(UIAlertAction(title: "New Users", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction) -> Void in
                let userListController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("UserList") as! UserListViewController
                let query = User.query()!
                query.orderByDescending("joinDate")
                query.whereKeyExists("aozoraUsername")
                query.limit = 100
                userListController.initWithQuery(query, title: "New Users")
                self.navigationController?.pushViewController(userListController, animated: true)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func showNotifications(sender: AnyObject) {
        let notificationsVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("Notifications") as! NotificationsViewController
        notificationsVC.delegate = self
        navigationController?.pushViewController(notificationsVC, animated: true)
    }
}

extension ProfileViewController: EditProfileViewControllerProtocol {
    
    func editProfileViewControllerDidEditedUser(user: User) {
        userProfile = user
        fetchUserDetails(user.aozoraUsername)
    }
}

extension ProfileViewController: NotificationsViewControllerDelegate {
    func notificationsViewControllerClearedAllNotifications() {
        noNewNotifications()
    }
}