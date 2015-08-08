//
//  ThreadViewController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 8/7/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANCommonKit
import TTTAttributedLabel
import XCDYouTubeKit
import Parse

public class ThreadViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var thread: Thread?
    
    var fetchController = FetchController()
    var refreshControl = UIRefreshControl()
    var loadingView: LoaderView!
    var playerController: XCDYouTubeVideoPlayerViewController?
    
    public func initWithThread(thread: Thread) {
        self.thread = thread
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.alpha = 0.0
        tableView.estimatedRowHeight = 112.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        CommentCell.registerNibFor(tableView: tableView)
        WriteACommentCell.registerNibFor(tableView: tableView)
        
        loadingView = LoaderView(parentView: view)
        addRefreshControl(refreshControl, action:"updateThread", forTableView: tableView)
        
        if let thread = thread {
            updateUIWithThread(thread)
        }
        
        updateThread()
    }
    
    func updateUIWithThread(thread: Thread) {
        
    }
    
    // MARK: - Fetching
    
    func updateThread() {

    }
    
    // MARK: - Internal functions
    func openProfile(user: User) {
        if user != User.currentUser() {
            let navController = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController() as! UINavigationController
            let profileController = navController.viewControllers.first as! ProfileViewController
            profileController.initWithUser(user)
            presentViewController(navController, animated: true, completion: nil)
        }
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
        comment.initWith(postType:.Timeline, delegate: self, parentPost: post)
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
    
    @IBAction func dismissPressed(sender: AnyObject) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}


extension ThreadViewController: UITableViewDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchController.dataCount()
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let timelinePost = fetchController.objectAtIndex(section) as! TimelinePost
        if timelinePost.replies.count > 0 {
            return 1 + timelinePost.replies.count + 1
        } else {
            return 1
        }
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let timelinePost = fetchController.objectAtIndex(indexPath.section) as! TimelinePost
        
        if indexPath.row == 0 {
            
            var reuseIdentifier = ""
            if timelinePost.images != nil || timelinePost.youtubeID != nil || timelinePost.episode != nil {
                // Post image or video cell
                reuseIdentifier = "PostImageCell"
            } else {
                // Text post update
                reuseIdentifier = "PostTextCell"
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! PostCell
            cell.delegate = self
            updatePostCell(cell, with: timelinePost)
            if let episode = timelinePost.episode {
                cell.imageContent?.setImageFrom(urlString: episode.imageURLString(), animated: true)
            }
            cell.layoutIfNeeded()
            return cell
            
        } else if timelinePost.replies.count > 0 && indexPath.row <= timelinePost.replies.count {
            let comment = timelinePost.replies[indexPath.row - 1]
            
            var reuseIdentifier = ""
            if comment.images != nil || comment.youtubeID != nil {
                // Comment image cell
                reuseIdentifier = "CommentImageCell"
            } else {
                // Text comment update
                reuseIdentifier = "CommentTextCell"
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! CommentCell
            cell.delegate = self
            updateCommentCell(cell, with: comment)
            cell.layoutIfNeeded()
            return cell
            
        } else {
            
            // Write a comment cell
            let cell = tableView.dequeueReusableCellWithIdentifier("WriteACommentCell") as! WriteACommentCell
            cell.layoutIfNeeded()
            return cell
            
        }
        
    }
    
    func updatePostCell(cell: PostCell, with timelinePost: TimelinePost) {
        if let postedBy = timelinePost.postedBy, let avatarFile = postedBy.avatarThumb {
            cell.avatar.setImageWithPFFile(avatarFile)
        }
        
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
        
        let username = timelinePost.userTimeline.aozoraUsername
        let content = username + " " + timelinePost.content
        if let postedBy = timelinePost.postedBy, let avatarFile = postedBy.avatarThumb {
            cell.avatar.setImageWithPFFile(avatarFile)
        }
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

extension ThreadViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5.0
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let timelinePost = fetchController.objectAtIndex(indexPath.section) as! TimelinePost
        
        if indexPath.row == 0 {
            showSheetFor(timelinePost: timelinePost)
        } else if timelinePost.replies.count > 0 && indexPath.row <= timelinePost.replies.count {
            let comment = timelinePost.replies[indexPath.row - 1]
            showSheetFor(timelinePost: comment, parentPost: timelinePost)
        } else {
            // Write a comment cell
            replyTo(timelinePost)
        }
    }
    
    func showSheetFor(#timelinePost: TimelinePost, parentPost: TimelinePost? = nil) {
        // If user's comment show delete/edit
        if timelinePost.postedBy == User.currentUser() {
            
            var alert = UIAlertController(title: "Manage Post", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            alert.addAction(UIAlertAction(title: "Edit", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction!) -> Void in
                let comment = ANParseKit.commentViewController()
                comment.initWith(postType: .Timeline, delegate: self, editingPost: timelinePost)
                self.presentViewController(comment, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: { (alertAction: UIAlertAction!) -> Void in
                if let parentPost = parentPost {
                    // Remove reference from parent
                    parentPost.removeObject(timelinePost, forKey: "replies")
                    parentPost.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if let error = error {
                            // Show some error
                        } else {
                            self.deletePosts([timelinePost])
                        }
                    })
                } else {
                    // Remove child too
                    self.deletePosts([timelinePost] + timelinePost.replies)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func deletePosts(posts: [TimelinePost]) {
        PFObject.deleteAllInBackground(posts, block: { (success, error) -> Void in
            if let error = error {
                // Show some error
            } else {
                self.updateThread()
            }
        })
    }
}

extension ThreadViewController: FetchControllerDelegate {
    public func didFetchFor(#skip: Int) {
        refreshControl.endRefreshing()
    }
}

extension ThreadViewController: TTTAttributedLabelDelegate {
    
    public func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        
        let (navController, webController) = ANCommonKit.webViewController()
        webController.initWithTitle(url.absoluteString!, initialUrl: url)
        presentViewController(navController, animated: true, completion: nil)
    }
}

extension ThreadViewController: CommentViewControllerDelegate {
    public func commentViewControllerDidFinishedPosting(post: PFObject) {
        
    }
}

extension ThreadViewController: PostCellDelegate {
    public func postCellSelectedImage(postCell: PostCell) {
        if let post = postForCell(postCell), let imageView = postCell.imageContent {
            if let imageURL = post.images?.first {
                showImage(imageURL, imageView: imageView)
            } else if let videoID = post.youtubeID {
                playTrailer(videoID)
            }
        }
    }
    
    public func postCellSelectedUserProfile(postCell: PostCell) {
        if let post = postForCell(postCell), let postedByUser = post.postedBy {
            openProfile(postedByUser)
        }
    }
    
    public func postCellSelectedComment(postCell: PostCell) {
        if let post = postForCell(postCell) {
            replyTo(post)
        }
    }
}