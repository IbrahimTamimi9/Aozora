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
import ANParseKit

// Class intended to be subclassed
public class ThreadViewController: UIViewController {
   
    public let FetchLimit = 12
    
    @IBOutlet public weak var tableView: UITableView!
    
    public var thread: Thread?
    public var threadType: ThreadType!
    
    public var fetchController = FetchController()
    public var refreshControl = UIRefreshControl()
    public var loadingView: LoaderView!
    
    var playerController: XCDYouTubeVideoPlayerViewController?
    
    public func initWithThread(thread: Thread) {
        self.thread = thread
        self.threadType = .Custom
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerPlaybackDidFinish:", name: MPMoviePlayerPlaybackDidFinishNotification, object: nil)
        
        tableView.alpha = 0.0
        tableView.estimatedRowHeight = 112.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        CommentCell.registerNibFor(tableView: tableView)
        WriteACommentCell.registerNibFor(tableView: tableView)
        ShowMoreCell.registerNibFor(tableView: tableView)
        
        loadingView = LoaderView(parentView: view)
        addRefreshControl(refreshControl, action:"fetchPosts", forTableView: tableView)
        
        if let thread = thread {
            updateUIWithThread(thread)
        } else {
            fetchThread()
        }
        
    }
    
    deinit {
        fetchController.tableView = nil
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    public func updateUIWithThread(thread: Thread) {
        fetchPosts()
    }
    
    // MARK: - Fetching
    public func fetchThread() {
        
    }
    
    public func fetchPosts() {

    }
    
    // MARK: - Internal functions
    
    public func openProfile(user: User) {
        if let profileController = self as? ProfileViewController {
            if profileController.userProfile != user && user != User.currentUser() {
                openProfileNow(user)
            }
        } else if user != User.currentUser() {
            openProfileNow(user)
        }
    }
    
    func openProfileNow(user: User? = nil, username: String? = nil) {
        let (navController, profileController) = ANAnimeKit.profileViewController()
        if let user = user  {
            profileController.initWithUser(user)
        } else if let username = username {
            profileController.initWithUsername(username)
        }
        
        presentViewController(navController, animated: true, completion: nil)
    }
    
    public func showImage(imageURLString: String, imageView: UIImageView) {
        if let imageURL = NSURL(string: imageURLString) {
            presentImageViewController(imageView, imageUrl: imageURL)
        }
    }
    
    public func playTrailer(videoID: String) {
        playerController = XCDYouTubeVideoPlayerViewController(videoIdentifier: videoID)
        presentMoviePlayerViewControllerAnimated(playerController)
    }
    
    public func replyTo(post: Postable) {
        guard User.currentUserLoggedIn() else {
            presentBasicAlertWithTitle("Login first", message: "Select 'Me' tab")
            return
        }
        
        let comment = ANParseKit.newPostViewController()
        if let post = post as? ThreadPostable, let thread = thread where !thread.locked {
            if thread.locked {
                presentBasicAlertWithTitle("Thread is locked")
            } else {
                comment.initWith(thread, threadType: threadType, delegate: self, parentPost: post)
                presentViewController(comment, animated: true, completion: nil)
            }
            
        } else if let post = post as? TimelinePostable {
            comment.initWithTimelinePost(self, postedIn:post.userTimeline, parentPost: post)
            presentViewController(comment, animated: true, completion: nil)
        }
    }
    
    public func postForCell(cell: UITableViewCell) -> Postable? {
        if let indexPath = tableView.indexPathForCell(cell), let post = fetchController.objectAtIndex(indexPath.section) as? Postable {
            if indexPath.row == 0 {
                return post
            // TODO organize this code better it has dup lines everywhere D:
            } else if (post.replies.count <= 3 || post.showAllReplies) && indexPath.row - 1 < post.replies.count {
                return post.replies[indexPath.row - 1] as? Postable
            } else if post.replies.count > 3 && indexPath.row < 5 {
                return post.replies[post.replies.count - 5 + indexPath.row] as? Postable
            }
        }
        
        return nil
    }
    
    public func like(post: Postable) {
        if !User.currentUserLoggedIn() {
            presentBasicAlertWithTitle("Login first", message: "Select 'Me' tab")
            return
        }
        
        if let post = post as? PFObject {
            let likedBy = (post as! Postable).likedBy ?? []
            let currentUser = User.currentUser()!
            if likedBy.contains(currentUser) {
                post.removeObject(currentUser, forKey: "likedBy")
            } else {
                post.addUniqueObject(currentUser, forKey: "likedBy")
            }
            post.saveEventually()
        }
    }
    
    // MARK: - IBAction
    
    @IBAction public func dismissPressed(sender: AnyObject) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction public func replyToThreadPressed(sender: AnyObject) {
        
    }
}


extension ThreadViewController: UITableViewDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchController.dataCount()
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = fetchController.objectInSection(section) as! Postable
        if post.replies.count > 0 {
            if post.replies.count <= 3 || post.showAllReplies {
                return 1 + (post.replies.count ?? 0) + 1
            } else {
                // 1 post, 1 show more, 3 replies, 1 reply to post
                return 1 + 1 + 3 + 1
            }
        } else {
            return 1
        }
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = fetchController.objectAtIndex(indexPath.section) as! Postable
        
        if indexPath.row == 0 {
            
            var reuseIdentifier = ""
            if post.images.count != 0 || post.youtubeID != nil || post.episode != nil {
                // Post image or video cell
                reuseIdentifier = "PostImageCell"
            } else {
                // Text post update
                reuseIdentifier = "PostTextCell"
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! PostCell
            cell.delegate = self
            updatePostCell(cell, with: post)
            if let episode = post.episode {
                cell.imageContent?.setImageFrom(urlString: episode.imageURLString(), animated: false)
                cell.imageHeightConstraint?.constant = 180
            }
            cell.layoutIfNeeded()
            return cell
            
        } else if (post.replies.count <= 3 || post.showAllReplies) && indexPath.row - 1 < post.replies.count {
            
            let comment = post.replies[indexPath.row - 1] as! Postable
            
            var reuseIdentifier = ""
            if comment.images.count != 0 || comment.youtubeID != nil {
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
            
        } else if post.replies.count > 3 && indexPath.row < 5 {
            // Show all
            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("ShowMoreCell") as! ShowMoreCell
                cell.layoutIfNeeded()
                return cell
            } else {
                let comment = post.replies[post.replies.count - 5 + indexPath.row] as! Postable
                
                var reuseIdentifier = ""
                if comment.images.count != 0 || comment.youtubeID != nil {
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
            }
        } else {
            
            // Write a comment cell
            let cell = tableView.dequeueReusableCellWithIdentifier("WriteACommentCell") as! WriteACommentCell
            cell.layoutIfNeeded()
            return cell
            
        }
        
    }
    
    func updatePostCell(cell: PostCell, with post: Postable) {
        if let postedBy = post.postedBy, let avatarFile = postedBy.avatarThumb {
            cell.avatar.setImageWithPFFile(avatarFile)
            cell.username?.text = postedBy.aozoraUsername
            cell.onlineIndicator.hidden = !postedBy.active
        }
        
        if let timelinePostable = post as? TimelinePostable where timelinePostable.userTimeline != post.postedBy {
            cell.toUsername?.text = timelinePostable.userTimeline.aozoraUsername
            cell.toIcon?.text = ""
        } else {
            cell.toUsername?.text = ""
            cell.toIcon?.text = ""
        }
        
        cell.date.text = post.createdDate?.timeAgo()
        
        if var postedAgo = cell.date.text where post.edited {
            postedAgo += " · Edited"
            cell.date.text = postedAgo
        }
        
        if let nonSpoilerContent = post.nonSpoilerContent {
            cell.textContent.text = nonSpoilerContent+"\n\n"
        } else {
            cell.textContent.text = ""
        }
        
        if post.hasSpoilers && post.isSpoilerHidden {
            cell.textContent.text! += "(Show Spoilers)"
            cell.imageHeightConstraint?.constant = 0
            cell.playButton?.hidden = true
        } else {
            cell.textContent.text! += post.content
            setImages(post.images, imageView: cell.imageContent, imageHeightConstraint: cell.imageHeightConstraint)
            prepareForVideo(cell.playButton, imageView: cell.imageContent, imageHeightConstraint: cell.imageHeightConstraint, youtubeID: post.youtubeID)
        }
        
        let repliesTitle = repliesButtonTitle(post.replies.count)
        cell.replyButton.setTitle(repliesTitle, forState: .Normal)
        
        updateAttributedTextProperties(cell.textContent)
        
        updateLikeButton(cell, post: post)
    }
    
    func updateCommentCell(cell: CommentCell, with post: Postable) {
        
        if let postedBy = post.postedBy, let avatarFile = postedBy.avatarThumb  {
            
            cell.onlineIndicator.hidden = !postedBy.active
            
            let username = postedBy.aozoraUsername
            var content = username + " "
            if let nonSpoilerContent = post.nonSpoilerContent {
                content += nonSpoilerContent+"\n\n"
            }
            
            if post.hasSpoilers && post.isSpoilerHidden {
                content += "(Show Spoilers)"
                cell.imageHeightConstraint?.constant = 0
                cell.playButton?.hidden = true
            } else {
                content += post.content
                setImages(post.images, imageView: cell.imageContent, imageHeightConstraint: cell.imageHeightConstraint)
                prepareForVideo(cell.playButton, imageView: cell.imageContent, imageHeightConstraint: cell.imageHeightConstraint, youtubeID: post.youtubeID)
            }
            
            cell.avatar.setImageWithPFFile(avatarFile)
            
            updateAttributedTextProperties(cell.textContent)
            cell.textContent.setText(content, afterInheritingLabelAttributesAndConfiguringWithBlock: { (attributedString) -> NSMutableAttributedString! in
                
                return attributedString
            })
            
            
            if let encodedUsername = username.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet()),
                let url = NSURL(string: "aozoraapp://profile/"+encodedUsername) {
                let range = (content as NSString).rangeOfString(username)
                cell.textContent.addLinkToURL(url, withRange: range)
            }
        }
        
        cell.date.text = post.createdDate?.timeAgo()
        
        if var postedAgo = cell.date.text where post.edited {
            postedAgo += " · Edited"
            cell.date.text = postedAgo
        }
        
        updateLikeButton(cell, post: post)
    }
    
    public func setImages(images: [ImageData], imageView: UIImageView?, imageHeightConstraint: NSLayoutConstraint?) {
        if let image = images.first {
            imageHeightConstraint?.constant = (view.bounds.size.width-59.0) * CGFloat(image.height)/CGFloat(image.width)
            imageView?.setImageFrom(urlString: image.url, animated: false)
        } else {
            imageHeightConstraint?.constant = 0
        }
    }
    
    public func repliesButtonTitle(repliesCount: Int) -> String {
        if repliesCount > 0 {
            return " \(repliesCount)"
        } else {
            return " "
        }
    }
    
    public func prepareForVideo(playButton: UIButton?, imageView: UIImageView?, imageHeightConstraint: NSLayoutConstraint?, youtubeID: String?) {
        if let playButton = playButton {
            if let youtubeID = youtubeID {
                
                let urlString = "https://i.ytimg.com/vi/\(youtubeID)/mqdefault.jpg"
                imageView?.setImageFrom(urlString: urlString, animated: false)
                imageHeightConstraint?.constant = 180
                
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
    
    func updateLikeButton(cell: PostCell, post: Postable) {
        if let likedBy = post.likedBy where likedBy.count > 0 {
            cell.likeButton.setTitle(" \(likedBy.count)", forState: .Normal)
        } else {
            cell.likeButton.setTitle(" ", forState: .Normal)
        }
        
        if let likedBy = post.likedBy where likedBy.contains(User.currentUser()!) {
            cell.likeButton.setImage(UIImage(named: "icon-like-red"), forState: .Normal)
        } else {
            cell.likeButton.setImage(UIImage(named: "icon-like-gray"), forState: .Normal)
        }
    }
}

extension ThreadViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 4.0
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var post = fetchController.objectAtIndex(indexPath.section) as! Postable
        
        if indexPath.row == 0 {
            if post.hasSpoilers && post.isSpoilerHidden == true {
                post.isSpoilerHidden = false
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            } else {
                showSheetFor(post: post)
            }
            
        } else if (post.replies.count <= 3 || post.showAllReplies) && indexPath.row - 1 < post.replies.count {
            if let comment = post.replies[indexPath.row - 1] as? Postable {
                pressedOnAComment(post, comment: comment, indexPath: indexPath)
            }
        } else if post.replies.count > 3 && indexPath.row < 5 {
            // Show all
            if indexPath.row == 1 {
                post.showAllReplies = true
                tableView.reloadData()
            } else {
                if let comment = post.replies[post.replies.count - 5 + indexPath.row] as? Postable {
                    pressedOnAComment(post, comment: comment, indexPath: indexPath)
                }
            }
        } else {
            // Write a comment cell
            replyTo(post)
        }
    }
    func pressedOnAComment(post: Postable, var comment: Postable, indexPath: NSIndexPath) {
        if comment.hasSpoilers && comment.isSpoilerHidden == true {
            comment.isSpoilerHidden = false
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        } else {
            showSheetFor(post: comment, parentPost: post)
        }
    }
    func showSheetFor(post post: Postable, parentPost: Postable? = nil) {
        // If user's comment show delete/edit
        let administrating = User.currentUser()!.isAdmin() && !post.postedBy!.isAdmin()
        if post.postedBy == User.currentUser() ||
            // Current user is admin and posted by non-admin user
            administrating {
            
                let alert: UIAlertController!
                
                if administrating {
                    alert = UIAlertController(title: "Warning: Editing \(post.postedBy!.aozoraUsername) post", message: "Only edit user posts if they are breaking guidelines", preferredStyle: UIAlertControllerStyle.ActionSheet)
                } else {
                    alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
                }
                
                alert.addAction(UIAlertAction(title: "Edit", style: administrating ? UIAlertActionStyle.Destructive : UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction!) -> Void in
                    let comment = ANParseKit.newPostViewController()
                    if let post = post as? TimelinePost {
                        comment.initWithTimelinePost(self, postedIn:User.currentUser()!, editingPost: post)
                    } else if let post = post as? Post, let thread = self.thread {
                        comment.initWith(thread, threadType: self.threadType, delegate: self, editingPost: post)
                    }
                    self.presentViewController(comment, animated: true, completion: nil)
                }))
                
                if !administrating {
                    alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: { (alertAction: UIAlertAction!) -> Void in
                        if let post = post as? PFObject {
                            if let parentPost = parentPost as? PFObject {
                                // Just delete child post
                                self.deletePosts([post], parentPost: parentPost, removeParent: false)
                            } else {
                                // This is parent post, remove child too
                                var className = ""
                                if let _ = post as? Post {
                                    className = "Post"
                                } else if let _ = post as? TimelinePost {
                                    className = "TimelinePost"
                                }
                                
                                let childPostsQuery = PFQuery(className: className)
                                childPostsQuery.whereKey("parentPost", equalTo: post)
                                childPostsQuery.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
                                    if let result = result as? [PFObject] {
                                        self.deletePosts(result, parentPost: post, removeParent: true)
                                    } else {
                                        // TODO: Show error
                                    }
                                })
                            }
                        }
                    }))
                }
                
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func deletePosts(childPosts: [PFObject] = [], parentPost: PFObject, removeParent: Bool) {
        var allPosts = childPosts
        
        if removeParent {
            allPosts.append(parentPost)
        }
        
        PFObject.deleteAllInBackground(allPosts, block: { (success, error) -> Void in
            if let _ = error {
                // Show some error
            } else {
                // Decrement post counts only if thread does not contain #ForumGame tag
                var game = false
                let forumGameId = "M4rpxLDwai"
                for tag in self.thread!.tags where
                    (tag as! ThreadTag).objectId! == forumGameId {
                    game = true
                    break
                }
                
                if !game {
                    for post in allPosts {
                        (post["postedBy"] as? User)?.incrementPostCount(-1)
                        print(self.thread?.tags[0]["name"] as? String)
                    }
                }
                self.thread?.incrementKey("replies", byAmount: -allPosts.count)
                self.thread?.saveEventually()
                
                if removeParent {
                    // Delete parent post, and entire section
                    if let section = self.fetchController.dataSource.indexOf(parentPost) {
                        self.fetchController.dataSource.removeAtIndex(section)
                        self.tableView.reloadData()
                    }
                } else {
                    // Delete child post
                    var parentPost = parentPost as! Postable
                    if let index = parentPost.replies.indexOf(childPosts.last!) {
                        parentPost.replies.removeAtIndex(index)
                        self.tableView.reloadData()
                    }
                }
            }
        })
    }
    
    func moviePlayerPlaybackDidFinish(notification: NSNotification) {
        playerController = nil;
    }
}

extension ThreadViewController: FetchControllerDelegate {
    public func didFetchFor(skip skip: Int) {
        refreshControl.endRefreshing()
    }
}

extension ThreadViewController: TTTAttributedLabelDelegate {
    
    public func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        
        if let host = url.host where host == "profile",
            let username = url.pathComponents?[1] {
                let isNotCurrentUser = username != User.currentUser()!.aozoraUsername
                if let profileController = self as? ProfileViewController {
                    if profileController.userProfile?.aozoraUsername != username && isNotCurrentUser {
                        openProfileNow(username: username)
                    }
                } else if isNotCurrentUser {
                    openProfileNow(username: username)
                }
            
        } else if url.scheme != "aozoraapp" {
            let (navController, webController) = ANCommonKit.webViewController()
            webController.initWithTitle(url.absoluteString, initialUrl: url)
            presentViewController(navController, animated: true, completion: nil)
        }
    }
}

extension ThreadViewController: CommentViewControllerDelegate {
    public func commentViewControllerDidFinishedPosting(newPost: PFObject, parentPost: PFObject?, edited: Bool) {
        if let thread = newPost as? Thread {
            self.thread = thread
        }
    }
}

extension ThreadViewController: PostCellDelegate {
    public func postCellSelectedImage(postCell: PostCell) {
        if let post = postForCell(postCell), let imageView = postCell.imageContent {
            print(post)
            if let imageData = post.images.first {
                showImage(imageData.url, imageView: imageView)
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
    
    public func postCellSelectedToUserProfile(postCell: PostCell) {
        if let post = postForCell(postCell) as? TimelinePostable {
            openProfile(post.userTimeline)
        }
    }
    
    public func postCellSelectedLike(postCell: PostCell) {
        if let post = postForCell(postCell) {
            like(post)
            updateLikeButton(postCell, post: post)
        }
    }
}

extension ThreadViewController: FetchControllerQueryDelegate {
    
    public func queriesForSkip(skip skip: Int) -> [PFQuery]? {
        let query = PFQuery()
        return [query]
    }
    
    public func processResult(result result: [PFObject]) -> [PFObject] {
        
        let posts = result.filter({ $0["replyLevel"] as? Int == 0 })
        let replies = result.filter({ $0["replyLevel"] as? Int == 1 })
        
        for post in posts {
            let postReplies = replies.filter({ $0["parentPost"] as? PFObject == post }) as [PFObject]
            var postable = post as! Postable
            postable.replies = postReplies
        }

        return posts
    }
}