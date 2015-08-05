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

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var reminderBBI: UIBarButtonItem!
    @IBOutlet weak var settingsBBI: UIBarButtonItem!
    
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userBanner: UIImageView!
    @IBOutlet weak var animeListButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var aboutLabel: UILabel!
    
    var user: PFUser = PFUser.currentUser()!
    var fetchController = FetchController()
    var refreshControl = UIRefreshControl()
    var loadingView: LoaderView!
    
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
        let avatarFile = user["avatarThumb"] as! PFFile
        let bannerFile = user["banner"] as! PFFile
        userAvatar.setImageWithPFFile(avatarFile)
        userBanner.setImageWithPFFile(bannerFile)
        
        let followingCount = user["following"] as! [PFUser]
        let followersCount = user["followers"] as! [PFUser]
        followingButton.setTitle("\(followingCount.count) FOLLOWING", forState: .Normal)
        followersButton.setTitle("\(followersCount.count) FOLLOWERS", forState: .Normal)
        
        loadingView = LoaderView(parentView: view)
        
        fetchUserFeed()
        fetchUserDetails()
    }
    
    func refreshPulled() {
        fetchUserFeed()
    }
    
    func fetchUserFeed() {
        let query = TimelinePost.query()!
        query.skip = 0
        query.whereKey("userTimeline", equalTo: PFUser.currentUser()!)
        query.whereKey("replyLevel", equalTo: 0)
        query.orderByDescending("createdAt")
        query.includeKey("episode")
        query.includeKey("postedBy")
        query.includeKey("userTimeline")
        query.includeKey("replies")
        fetchController.configureWith(self, query: query, tableView: tableView)
    }
    
    func fetchUserDetails() {
        
        let details = user["userDetails"] as! UserDetails
        details.fetchIfNeededInBackgroundWithBlock { (details, error) -> Void in
            if let details = details as? UserDetails {
                self.aboutLabel.text = details.about
            }
        }
    }
    
    // MARK: - IBAction
    @IBAction func showLibrary(sender: AnyObject) {
        
    }
    
    @IBAction func followOrUnfollow(sender: AnyObject) {
        
    }
    
    @IBAction func showFollowingUsers(sender: AnyObject) {
        
        let userListController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("UserList") as! UserListViewController
        let followingList = user["following"] as! [PFUser]
        userListController.initWithList(followingList, title: "Followers")
        navigationController?.pushViewController(userListController, animated: true)
        
    }
    
    @IBAction func showFollowers(sender: AnyObject) {
        let userListController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("UserList") as! UserListViewController
        let followersList = user["followers"] as! [PFUser]
        userListController.initWithList(followersList, title: "Followers")
        navigationController?.pushViewController(userListController, animated: true)
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
                updatePostCell(cell, with: timelinePost)
                cell.imageContent?.setImageFrom(urlString: episode.imageURLString(), animated: true)
                
                cell.layoutIfNeeded()
                return cell
            } else if let _ = timelinePost.images {
                // Post image cell
                let cell = tableView.dequeueReusableCellWithIdentifier("PostImageCell") as! PostCell
                updatePostCell(cell, with: timelinePost)
                cell.layoutIfNeeded()
                return cell
            } else if let _ = timelinePost.youtubeID {
                // Video comment
                let cell = tableView.dequeueReusableCellWithIdentifier("PostImageCell") as! PostCell
                updatePostCell(cell, with: timelinePost)
                cell.layoutIfNeeded()
                return cell
            } else {
                // Text post update
                let cell = tableView.dequeueReusableCellWithIdentifier("PostTextCell") as! PostCell
                updatePostCell(cell, with: timelinePost)
                cell.layoutIfNeeded()
                return cell
            }
            
        } else if timelinePost.replies.count > 0 && indexPath.row <= timelinePost.replies.count {
            let comment = timelinePost.replies[indexPath.row - 1] as! TimelinePost
            
            if let _ = comment.images {
                // Comment image cell
                let cell = tableView.dequeueReusableCellWithIdentifier("CommentImageCell") as! CommentCell
                updateCommentCell(cell, with: comment)
                cell.layoutIfNeeded()
                return cell
            } else if let _ = comment.youtubeID {
                // Video comment
                let cell = tableView.dequeueReusableCellWithIdentifier("CommentImageCell") as! CommentCell
                updateCommentCell(cell, with: comment)
                cell.layoutIfNeeded()
                return cell
            } else {
                // Text comment update
                let cell = tableView.dequeueReusableCellWithIdentifier("CommentTextCell") as! CommentCell
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
        let avatarFile = timelinePost.postedBy!["avatarThumb"] as! PFFile
        cell.avatar.setImageWithPFFile(avatarFile)
        cell.username.text = timelinePost.userTimeline["aozoraUsername"] as? String
        cell.date.text = timelinePost.createdAt?.timeAgo()
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
        let avatarFile = timelinePost.postedBy!["avatarThumb"] as! PFFile
        let username = timelinePost.userTimeline["aozoraUsername"] as! String
        let content = username + " " + timelinePost.content
        cell.avatar.setImageWithPFFile(avatarFile)
        self.updateAttributedTextProperties(cell.textContent)
        cell.date.text = timelinePost.createdAt?.timeAgo()
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
        return 10
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