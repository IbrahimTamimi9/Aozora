//
//  NewPostViewController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 8/24/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Parse
import Bolts

public class NewPostViewController: CommentViewController {
    
    @IBOutlet weak var spoilersButton: UIButton!
    @IBOutlet weak var spoilerContentHeight: NSLayoutConstraint!
    @IBOutlet weak var spoilerTextView: UITextView!
    
    var hasSpoilers = false {
        didSet {
            if hasSpoilers {
                spoilersButton.setTitle(" Spoilers", forState: .Normal)
                spoilersButton.setTitleColor(UIColor.dropped(), forState: .Normal)
                spoilerContentHeight.constant = 160
                
            } else {
                spoilersButton.setTitle("No Spoilers", forState: .Normal)
                spoilersButton.setTitleColor(UIColor(white: 0.75, alpha: 1.0), forState: .Normal)
                spoilerContentHeight.constant = 0
            }
            
            
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.85, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }) { (finished) -> Void in
            }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        spoilerContentHeight.constant = 0
        textView.becomeFirstResponder()
        
        if let editingPost = editingPost {
            
            let postable = editingPost as! Postable
            hasSpoilers = postable.hasSpoilers
            
            if hasSpoilers {
                spoilerTextView.text = postable.content
                textView.text = postable.nonSpoilerContent
            } else {
                textView.text = postable.content
            }
            
            if let youtubeID = (editingPost as! Postable).youtubeID {
                selectedVideoID = youtubeID
                videoCountLabel.hidden = false
                photoCountLabel.hidden = true
            } else if let imageData = (editingPost as! Postable).images.last{
                selectedImageData = imageData
                videoCountLabel.hidden = true
                photoCountLabel.hidden = false
            }
            
            if let parentPost = parentPost as? TimelinePostable {
                inReply.text = "  Editing Reply to \(parentPost.userTimeline.aozoraUsername)"
            } else {
                inReply.text = "  Editing Post"
            }

        } else {
            if let parentPost = parentPost as? TimelinePostable {
                inReply.text = "  In Reply to \(parentPost.userTimeline.aozoraUsername)"
            } else {
                inReply.text = "  New Post"
            }
        }
    }

    override func performPost() {
        super.performPost()
        
        if !validPost() {
            return
        }
        
        self.sendButton.setTitle("Sending...", forState: .Normal)
        self.sendButton.backgroundColor = UIColor.watching()
        self.sendButton.userInteractionEnabled = false
        
        switch threadType {
        case .Timeline:
            let timelinePost = TimelinePost()
            
            if hasSpoilers {
                timelinePost.content = spoilerTextView.text
                timelinePost.nonSpoilerContent = textView.text
            } else {
                timelinePost.content = textView.text
                timelinePost.nonSpoilerContent = nil
            }
            
            timelinePost.edited = false
            timelinePost.hasSpoilers = hasSpoilers
            timelinePost.postedBy = postedBy
            if let selectedImageData = selectedImageData {
                timelinePost.images = [selectedImageData]
            }
            
            if let youtubeID = selectedVideoID {
                timelinePost.youtubeID = youtubeID
            }
            
            var parentSaveTask = BFTask(result: nil)
            
            if let parentPost = parentPost as? TimelinePost {
                parentPost.addUniqueObject(postedBy!, forKey: "subscribers")
                parentSaveTask = parentPost.saveInBackground()
            } else {
                if postedBy! != postedIn {
                    timelinePost.subscribers = [postedBy!, postedIn]
                } else {
                    timelinePost.subscribers = [postedBy!]
                }
            }
            
            if let parentPost = parentPost as? TimelinePostable {
                timelinePost.replyLevel = 1
                timelinePost.userTimeline = parentPost.userTimeline
                timelinePost.parentPost = parentPost as? TimelinePost
            } else {
                timelinePost.replyLevel = 0
                timelinePost.userTimeline = postedIn
            }
            
            let postSaveTask = timelinePost.saveInBackground()
            
            BFTask(forCompletionOfAllTasks: [parentSaveTask, postSaveTask]).continueWithBlock({ (task: BFTask!) -> AnyObject! in
                
                // Send timeline post notification
                if let parentPost = self.parentPost as? TimelinePost {
                    let parameters = [
                        "toUserId": self.postedIn.objectId!,
                        "timelinePostId": parentPost.objectId!,
                        "toUserUsername": self.postedIn.aozoraUsername
                        ] as [String : AnyObject]
                    PFCloud.callFunctionInBackground("sendNewTimelinePostReplyPushNotification", withParameters: parameters)
                } else {
                    let parameters = [
                        "toUserId": self.postedIn.objectId!,
                        "timelinePostId": timelinePost.objectId!
                        ] as [String : AnyObject]
                    PFCloud.callFunctionInBackground("sendNewTimelinePostPushNotification", withParameters: parameters)
                }
                
                self.postedBy?.incrementPostCount(1)
                self.completeRequest(timelinePost, parentPost: self.parentPost as? PFObject, error: task.error)
                return nil
            })
            
        default:
            let post = Post()
            if hasSpoilers {
                post.content = spoilerTextView.text
                post.nonSpoilerContent = textView.text
            } else {
                post.content = textView.text
                post.nonSpoilerContent = nil
            }
            post.edited = false
            post.hasSpoilers = hasSpoilers
            post.postedBy = postedBy
            if let selectedImageData = selectedImageData {
                post.images = [selectedImageData]
            }
            
            if let youtubeID = selectedVideoID {
                post.youtubeID = youtubeID
            }
            
            // Add subscribers to parent post or current post if there is no parent
            var parentSaveTask = BFTask(result: nil)
            if let parentPost = parentPost as? Post {
                parentPost.addUniqueObject(postedBy!, forKey: "subscribers")
                parentSaveTask = parentPost.saveInBackground()
            } else {
                post.subscribers = [postedBy!]
            }
            
            if let parentPost = parentPost as? ThreadPostable {
                post.replyLevel = 1
                post.thread = parentPost.thread
                post.parentPost = parentPost as? Post
            } else {
                post.replyLevel = 0
                post.thread = thread!
            }
            post.thread.incrementKey("replies")
            post.thread.lastPostedBy = postedBy
               
            let postSaveTask = post.saveInBackground()
            
            BFTask(forCompletionOfAllTasks: [parentSaveTask, postSaveTask]).continueWithBlock({ (task: BFTask!) -> AnyObject! in
                
                // Send post notification
                if let parentPost = self.parentPost as? Post {
                    let parameters = [
                        "toUserId": parentPost.postedBy!.objectId!,
                        "postId": parentPost.objectId!,
                        "threadName": post.thread.title
                        ] as [String : AnyObject]
                    PFCloud.callFunctionInBackground("sendNewPostReplyPushNotification", withParameters: parameters)
                } else {
                    var parameters = [
                        "postId": post.objectId!,
                        "threadName": post.thread.title
                        ] as [String : AnyObject]
                    
                    // Only on user threads, episode threads do not have startedBy
                    if let startedBy = post.thread.startedBy {
                        parameters["toUserId"] = startedBy.objectId!
                    }
                    
                    PFCloud.callFunctionInBackground("sendNewPostPushNotification", withParameters: parameters)
                }
                // Incrementing post counts only if thread does not contain #ForumGame tag
                var game = false
                let forumGameId = "M4rpxLDwai"
                for tag in self.thread!.tags where
                    (tag as! ThreadTag).objectId! == forumGameId {
                        game = true
                        break
                }
                if !game {
                    self.postedBy?.incrementPostCount(1)
                }
                self.completeRequest(post, parentPost: self.parentPost as? PFObject, error: task.error)
                return nil
            })
        }
    }
    
    override func performUpdate(post: PFObject) {
        super.performUpdate(post)
        
        if !validPost() {
            return
        }
        
        self.sendButton.setTitle("Updating...", forState: .Normal)
        self.sendButton.backgroundColor = UIColor.watching()
        self.sendButton.userInteractionEnabled = false
        
        if var post = post as? Postable {
            post.hasSpoilers = hasSpoilers
            if hasSpoilers {
                post.content = spoilerTextView.text
                post.nonSpoilerContent = textView.text
            } else {
                post.content = textView.text
                post.nonSpoilerContent = nil
            }
            post.edited = true
            
            if let selectedImageData = selectedImageData {
                post.images = [selectedImageData]
            } else {
                post.images = []
            }
            
            if let youtubeID = selectedVideoID {
                post.youtubeID = youtubeID
            } else {
                post.youtubeID = nil
            }
        }
        
        post.saveInBackgroundWithBlock ({ (result, error) -> Void in
            self.completeRequest(post, parentPost: self.parentPost as? PFObject, error: error)
        })
    }
    
    func validPost() -> Bool {
        let content = textView.text
        // Validate post
        if content.characters.count < 2 {
            presentBasicAlertWithTitle("Too Short", message: "Message should be a 3 characters or longer")
            return false
        }
        return true
    }
  
    // MARK: - IBActions
    
    @IBAction func spoilersButtonPressed(sender: AnyObject) {
        
        hasSpoilers = !hasSpoilers
    }
}