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
    
    var hasSpoilers = false {
        didSet {
            if hasSpoilers {
                spoilersButton.setTitle(" Spoilers", forState: .Normal)
                spoilersButton.setTitleColor(UIColor.dropped(), forState: .Normal)
            } else {
                spoilersButton.setTitle("No Spoilers", forState: .Normal)
                spoilersButton.setTitleColor(UIColor(white: 0.75, alpha: 1.0), forState: .Normal)
            }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.becomeFirstResponder()
        
        if let editingPost = editingPost {
            hasSpoilers = (editingPost as! Postable).hasSpoilers
            textView.text = editingPost["content"] as? String
            if let parentPost = parentPost as? TimelinePostable {
                inReply.text = "  Editing Reply to \(parentPost.userTimeline.aozoraUsername)"
            } else {
                inReply.text = "  Editing Post"
            }
            photoButton.hidden = true
            videoButton.hidden = true
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
            var timelinePost = TimelinePost()
            
            timelinePost.content = textView.text
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
            
            var postSaveTask = timelinePost.saveInBackground()
            
            BFTask(forCompletionOfAllTasks: [parentSaveTask, postSaveTask]).continueWithBlock({ (task: BFTask!) -> AnyObject! in
                
                // Send timeline post notification
                if let parentPost = self.parentPost as? TimelinePost {
                    let parameters = [
                        "toUserId": self.postedIn.objectId!,
                        "timelinePostId": parentPost.objectId!,
                        "toUserUsername": self.postedIn.username!
                        ] as [String : AnyObject]
                    PFCloud.callFunctionInBackground("sendNewTimelinePostReplyPushNotification", withParameters: parameters)
                } else {
                    if self.postedBy! != self.postedIn {
                        let parameters = [
                            "toUserId": self.postedIn.objectId!,
                            "timelinePostId": timelinePost.objectId!
                            ] as [String : AnyObject]
                        PFCloud.callFunctionInBackground("sendNewTimelinePostPushNotification", withParameters: parameters)
                    }
                }
                
                self.postedBy?.incrementPostCount(1)
                self.completeRequest(timelinePost, error: task.error)
                return nil
            })
            
        default:
            var post = Post()
            post.content = textView.text
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
               
            var postSaveTask = post.saveInBackground()
            
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
                    if self.postedBy! != self.postedIn {
                        let parameters = [
                            "toUserId": post.thread.startedBy!.objectId!,
                            "postId": post.objectId!,
                            "threadName": post.thread.title
                            ] as [String : AnyObject]
                        PFCloud.callFunctionInBackground("sendNewPostPushNotification", withParameters: parameters)
                    }
                }
                
                self.postedBy?.incrementPostCount(1)
                self.completeRequest(post, error: task.error)
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
            post.content = textView.text
            post.edited = true
        }
        
        post.saveInBackgroundWithBlock ({ (result, error) -> Void in
            self.completeRequest(post, error: error)
        })
    }
    
    func validPost() -> Bool {
        let content = textView.text
        // Validate post
        if count(content) < 2 {
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