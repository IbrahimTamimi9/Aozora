//
//  UserProfileViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/22/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANCommonKit
import ANParseKit
import TTTAttributedLabel
import XCDYouTubeKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var createBBI: UIBarButtonItem!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
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
    var fetchController = FetchController()
    var refreshControl = UIRefreshControl()
    var loadingView: LoaderView!
    var playerController: XCDYouTubeVideoPlayerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.alpha = 0.0
        tableView.estimatedRowHeight = 112.0
        tableView.rowHeight = UITableViewAutomaticDimension
    
        PostCell.registerNibFor(tableView: tableView, type: PostCell.CellType.Text)
        PostCell.registerNibFor(tableView: tableView, type: PostCell.CellType.Image)
        CommentCell.registerNibFor(tableView: tableView, type: CommentCell.CellType.Text)
        CommentCell.registerNibFor(tableView: tableView, type: CommentCell.CellType.Image)
        WriteACommentCell.registerNibFor(tableView: tableView)
        
        usernameLabel.text = user.username
        title = user.aozoraUsername
        let avatarFile = user.avatarThumb
        let bannerFile = user.banner
        userAvatar.setImageWithPFFile(avatarFile)
        userBanner.setImageWithPFFile(bannerFile)
        
        let followingCount = user.following
        let followersCount = user.followers
        followingButton.setTitle("\(followingCount.count) FOLLOWING", forState: .Normal)
        followersButton.setTitle("\(followersCount.count) FOLLOWERS", forState: .Normal)
        
        if user == User.currentUser() {
            followButton.hidden = true
            animeListButton.hidden = true
            settingsTrailingSpaceConstraint.constant = 8
        } else {
            followButton.hidden = false
            animeListButton.hidden = false
            navigationItem.rightBarButtonItems = nil
            navigationItem.leftBarButtonItem = nil
            settingsTrailingSpaceConstraint.constant = 96
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
        
        loadingView = LoaderView(parentView: view)
        addRefreshControl(refreshControl, action:"fetchUserFeed", forTableView: tableView)
        fetchUserFeed()
        fetchUserDetails()
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
        
        let details = user.userDetails
        details.fetchIfNeededInBackgroundWithBlock { (details, error) -> Void in
            if let details = details as? UserDetails {
                self.aboutLabel.text = details.about
            }
        }
    }
    
    // MARK: - Internal functions
    func openProfile(user: User) {
        
    }
    
    func showImage(imageURLString: String, imageView: UIImageView) {
        if let imageURL = NSURL(string: imageURLString) {
            presentImageViewController(imageView, imageUrl: imageURL)
        }
    }
    
    func playTrailer(videoID: String) {
        playerController = XCDYouTubeVideoPlayerViewController(videoIdentifier: videoID)
        presentMoviePlayerViewControllerAnimated(playerController)
    }
    
    func replyTo(post: TimelinePost) {
        let comment = ANParseKit.commentViewController()
        comment.initWith(postType: .Timeline, delegate: self, parentPost: post)
        presentViewController(comment, animated: true, completion: nil)
    }
    
    func postForCell(cell: UITableViewCell) -> TimelinePost? {
        if let indexPath = tableView.indexPathForCell(cell), let timelinePost = fetchController.objectAtIndex(indexPath.section) as? TimelinePost {
            if indexPath.row == 0 {
                return timelinePost
            } else if timelinePost.replies.count > 0 && indexPath.row <= timelinePost.replies.count {
                return timelinePost.replies[indexPath.row - 1]
            }
        }
        
        return nil
    }
    
    // MARK: - IBAction
    
    @IBAction func showLibrary(sender: AnyObject) {
        
    }
    
    @IBAction func followOrUnfollow(sender: AnyObject) {
        
    }
    
    @IBAction func composeUpdatePressed(sender: AnyObject) {
        let comment = ANParseKit.commentViewController()
        comment.initWith(postType: .Timeline, delegate: self)
        presentViewController(comment, animated: true, completion: nil)
    }
    
    @IBAction func showFollowingUsers(sender: AnyObject) {
        let userListController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("UserList") as! UserListViewController
        let followingList = user.following
        userListController.initWithList(followingList, title: "Following")
        navigationController?.pushViewController(userListController, animated: true)
    }
    
    @IBAction func showFollowers(sender: AnyObject) {
        let userListController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("UserList") as! UserListViewController
        let followersList = user.followers
        userListController.initWithList(followersList, title: "Followers")
        navigationController?.pushViewController(userListController, animated: true)
    }
    
    @IBAction func showSettings(sender: AnyObject) {
        let settings = UIStoryboard(name: "Settings", bundle: nil).instantiateInitialViewController() as! UINavigationController
        presentViewController(settings, animated: true, completion: nil)
    }
}


extension ProfileViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchController.dataCount()
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let timelinePost = fetchController.objectAtIndex(section) as! TimelinePost
        if timelinePost.replies.count > 0 {
            return 1 + timelinePost.replies.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let timelinePost = fetchController.objectAtIndex(indexPath.section) as! TimelinePost
        
        if indexPath.row == 0 {
        
            if let episode = timelinePost.episode {
                // Post image cell
                let cell = tableView.dequeueReusableCellWithIdentifier("PostImageCell") as! PostCell
                cell.delegate = self
                updatePostCell(cell, with: timelinePost)
                cell.imageContent?.setImageFrom(urlString: episode.imageURLString(), animated: true)
                
                cell.layoutIfNeeded()
                return cell
            } else if let _ = timelinePost.images {
                // Post image cell
                let cell = tableView.dequeueReusableCellWithIdentifier("PostImageCell") as! PostCell
                cell.delegate = self
                updatePostCell(cell, with: timelinePost)
                cell.layoutIfNeeded()
                return cell
            } else if let _ = timelinePost.youtubeID {
                // Video comment
                let cell = tableView.dequeueReusableCellWithIdentifier("PostImageCell") as! PostCell
                cell.delegate = self
                updatePostCell(cell, with: timelinePost)
                cell.layoutIfNeeded()
                return cell
            } else {
                // Text post update
                let cell = tableView.dequeueReusableCellWithIdentifier("PostTextCell") as! PostCell
                cell.delegate = self
                updatePostCell(cell, with: timelinePost)
                cell.layoutIfNeeded()
                return cell
            }
            
        } else if timelinePost.replies.count > 0 && indexPath.row <= timelinePost.replies.count {
            let comment = timelinePost.replies[indexPath.row - 1]
            
            if let _ = comment.images {
                // Comment image cell
                let cell = tableView.dequeueReusableCellWithIdentifier("CommentImageCell") as! CommentCell
                cell.delegate = self
                updateCommentCell(cell, with: comment)
                cell.layoutIfNeeded()
                return cell
            } else if let _ = comment.youtubeID {
                // Video comment
                let cell = tableView.dequeueReusableCellWithIdentifier("CommentImageCell") as! CommentCell
                cell.delegate = self
                updateCommentCell(cell, with: comment)
                cell.layoutIfNeeded()
                return cell
            } else {
                // Text comment update
                let cell = tableView.dequeueReusableCellWithIdentifier("CommentTextCell") as! CommentCell
                cell.delegate = self
                updateCommentCell(cell, with: comment)
                cell.layoutIfNeeded()
                return cell
            }
            
        } else {
            
            // Write a comment cell
            let cell = tableView.dequeueReusableCellWithIdentifier("WriteACommentCell") as! WriteACommentCell
            cell.layoutIfNeeded()
            return cell
            
        }
        
    }
    
    func updatePostCell(cell: PostCell, with timelinePost: TimelinePost) {
        let avatarFile = timelinePost.postedBy!.avatarThumb
        cell.avatar.setImageWithPFFile(avatarFile)
        cell.username.text = timelinePost.userTimeline.aozoraUsername
        cell.date.text = timelinePost.createdAt?.timeAgo()
        
        if var postedAgo = cell.date.text where timelinePost.edited {
            postedAgo += " · Edited"
            cell.date.text = postedAgo
        }
        
        cell.textContent.text = timelinePost.content
        let replies = timelinePost.replies
        let buttonTitle = replies.count > 0 ? replies.count > 1 ? " \(replies.count) Comments" : " 1 Comment" : " Comment"
        cell.replyButton.setTitle(buttonTitle, forState: .Normal)
        self.updateAttributedTextProperties(cell.textContent)
        if let image = timelinePost.images?.first {
            cell.imageContent?.setImageFrom(urlString: image, animated: true)
        }
        
        prepareForVideo(cell.playButton, imageView: cell.imageContent, timelinePost: timelinePost)
    }
    
    func updateCommentCell(cell: CommentCell, with timelinePost: TimelinePost) {
        let avatarFile = timelinePost.postedBy!.avatarThumb
        let username = timelinePost.userTimeline.aozoraUsername
        let content = username + " " + timelinePost.content
        cell.avatar.setImageWithPFFile(avatarFile)
        self.updateAttributedTextProperties(cell.textContent)
        cell.date.text = timelinePost.createdAt?.timeAgo()
        
        if var postedAgo = cell.date.text where timelinePost.edited {
            postedAgo += " · Edited"
            cell.date.text = postedAgo
        }
        
        cell.textContent.setText(content, afterInheritingLabelAttributesAndConfiguringWithBlock: { (attributedString) -> NSMutableAttributedString! in
            
            return attributedString
        })
        
        let url = NSURL(string: "aozoraapp://profile/"+username)
        let range = (content as NSString).rangeOfString(username)
        cell.textContent.addLinkToURL(url, withRange: range)
        
        if let image = timelinePost.images?.first {
            cell.imageContent?.setImageFrom(urlString: image, animated: true)
        }
        prepareForVideo(cell.playButton, imageView: cell.imageContent, timelinePost: timelinePost)
    }
    
    func prepareForVideo(playButton: UIButton?, imageView: UIImageView?, timelinePost: TimelinePost) {
        if let playButton = playButton {
            if let youtubeID = timelinePost.youtubeID {
                
                let urlString = "https://i.ytimg.com/vi/\(youtubeID)/mqdefault.jpg"
                imageView?.setImageFrom(urlString: urlString, animated: true)
                
                playButton.hidden = false
                playButton.layer.borderWidth = 1.0;
                playButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.5).CGColor;
            } else {
                playButton.hidden = true
            }
        }
    }
    
    func updateAttributedTextProperties(textContent: TTTAttributedLabel) {
        textContent.linkAttributes = [kCTForegroundColorAttributeName: UIColor.peterRiver()]
        textContent.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
        textContent.delegate = self;
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let timelinePost = fetchController.objectAtIndex(indexPath.section) as! TimelinePost
        
        if indexPath.row == 0 {
            showSheetFor(timelinePost: timelinePost)
        } else if timelinePost.replies.count > 0 && indexPath.row <= timelinePost.replies.count {
            let comment = timelinePost.replies[indexPath.row - 1]
            showSheetFor(timelinePost: comment)
        } else {
            // Write a comment cell
            replyTo(timelinePost)
        }
    }
    
    func showSheetFor(#timelinePost: TimelinePost) {
        // If user's comment show delete/edit
        if timelinePost.postedBy == user {
            
            var alert = UIAlertController(title: "Manage Post", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            alert.addAction(UIAlertAction(title: "Edit", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction!) -> Void in
                let comment = ANParseKit.commentViewController()
                comment.initWith(postType: .Timeline, delegate: self, editingPost: timelinePost)
                self.presentViewController(comment, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: { (alertAction: UIAlertAction!) -> Void in
                timelinePost.deleteInBackgroundWithBlock({ (success, error) -> Void in
                    if let error = error {
                        // Show some error
                    } else {
                        self.fetchUserFeed()
                    }
                })
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

extension ProfileViewController: FetchControllerDelegate {
    func didFetchFor(#skip: Int) {
        refreshControl.endRefreshing()
    }
}

extension ProfileViewController: TTTAttributedLabelDelegate {
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        
        let (navController, webController) = ANCommonKit.webViewController()
        webController.initWithTitle(url.absoluteString!, initialUrl: url)
        presentViewController(navController, animated: true, completion: nil)
    }
}

extension ProfileViewController: CommentViewControllerDelegate {
    func commentViewControllerDidFinishedPosting(post: PFObject) {
        fetchUserFeed()
    }
}

extension ProfileViewController: PostCellDelegate {
    func postCellSelectedImage(postCell: PostCell) {
        if let post = postForCell(postCell), let imageView = postCell.imageContent {
            if let imageURL = post.images?.first {
                showImage(imageURL, imageView: imageView)
            } else if let videoID = post.youtubeID {
                playTrailer(videoID)
            }
        }
    }
    
    func postCellSelectedUserProfile(postCell: PostCell) {
        println("selected profile")
    }
    
    func postCellSelectedComment(postCell: PostCell) {
        if let post = postForCell(postCell) {
            replyTo(post)
        }
    }
}

extension ProfileViewController: CommentCellDelegate {
    func commentCellSelectedImage(commentCell: CommentCell) {
        // TODO: remove duplicate code
        if let post = postForCell(commentCell), let imageView = commentCell.imageContent {
            if let imageURL = post.images?.first {
                showImage(imageURL, imageView: imageView)
            } else if let videoID = post.youtubeID {
                playTrailer(videoID)
            }
        }
    }
    
    func commentCellSelectedUserProfile(commentCell: CommentCell) {
        println("selected profile")
    }
    
    func commentCellSelectedComment(commentCell: CommentCell) {
        if let post = postForCell(commentCell) {
            replyTo(post)
        }
    }
}