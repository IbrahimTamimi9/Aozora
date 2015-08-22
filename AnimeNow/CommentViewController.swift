//
//  CommentViewController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 8/5/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Parse
import Bolts

public protocol CommentViewControllerDelegate: class {
    func commentViewControllerDidFinishedPosting(post: PFObject)
}

public class CommentViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewBottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var inReply: UILabel!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var photoCountLabel: UILabel!
    @IBOutlet weak var videoCountLabel: UILabel!
    @IBOutlet weak var spoilersSwitch: UISwitch!
    
    public weak var delegate: CommentViewControllerDelegate?
    
    var selectedImageData: ImageData?
    var selectedVideoID: String?
    
    var initialStatusBarStyle: UIStatusBarStyle!
    var postedBy = User.currentUser()
    var postedIn: User!
    var parentPost: Postable?
    var thread: Thread?
    var postType: PostType = .Timeline
    var editingPost: PFObject?
    
    public enum PostType {
        case Timeline
        case Episode
        case Anime
        case Forum
    }
    
    public func initWithTimelinePost(delegate: CommentViewControllerDelegate?, postedIn: User, editingPost: PFObject? = nil, parentPost: Postable? = nil) {
        self.postedIn = postedIn
        self.postType = .Timeline
        self.editingPost = editingPost
        self.delegate = delegate
        self.parentPost = parentPost
    }
    
    public func initWithThread(thread: Thread, postType: PostType, delegate: CommentViewControllerDelegate?, editingPost: PFObject? = nil, parentPost: Postable? = nil) {
        self.postedBy = User.currentUser()!
        self.thread = thread
        self.postType = postType
        self.editingPost = editingPost
        self.delegate = delegate
        self.parentPost = parentPost
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        textView.becomeFirstResponder()
        
        photoCountLabel.hidden = true
        videoCountLabel.hidden = true
        
        if let editingPost = editingPost {
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
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if isBeingPresented() {
            initialStatusBarStyle = UIApplication.sharedApplication().statusBarStyle
        }
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isBeingDismissed() {
            UIApplication.sharedApplication().setStatusBarStyle(initialStatusBarStyle, animated: true)
            view.endEditing(true)
        }
    }
    
    // MARK: - NSNotificationCenter
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo! as NSDictionary
        
        let endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardEndFrame = view.convertRect(endFrameValue.CGRectValue(), fromView: nil)
        
        updateInputForHeight(keyboardEndFrame.size.height)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        updateInputForHeight(0)
    }
    
    // MARK: - Functions
    
    func updateInputForHeight(height: CGFloat) {
        
        textViewBottomSpaceConstraint.constant = height
        
        view.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseOut, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func performPost() {
        
        let content = textView.text
        // Validate post
        if count(content) < 2 {
            presentBasicAlertWithTitle("Too Short", message: "Message should be a 3 characters or longer")
            return
        }
        
        self.sendButton.setTitle("Sending...", forState: .Normal)
        self.sendButton.backgroundColor = UIColor.watching()
        self.sendButton.userInteractionEnabled = false
        
        switch postType {
        case .Timeline:
            var timelinePost = TimelinePost()
            timelinePost.content = content
            timelinePost.edited = false
            if let selectedImageData = selectedImageData {
                timelinePost.images = [selectedImageData]
            }
            
            if let youtubeID = selectedVideoID {
                timelinePost.youtubeID = youtubeID
            }
            
            if let parentPost = parentPost as? TimelinePostable {
                timelinePost.replyLevel = 1
                timelinePost.userTimeline = parentPost.userTimeline
                timelinePost.parentPost = parentPost as? TimelinePost
            } else {
                timelinePost.replyLevel = 0
                timelinePost.userTimeline = postedIn
            }
            
            timelinePost.postedBy = postedBy
            timelinePost.saveInBackgroundWithBlock({ (result, error) -> Void in
                self.postedBy?.details.incrementKey("posts", byAmount: 1)
                self.postedBy?.saveEventually()
                self.completeRequest(timelinePost, error: error)
            })
            
        case .Episode:
            var post = Post()
            post.content = textView.text
            post.edited = false
            
            if let selectedImageData = selectedImageData {
                post.images = [selectedImageData]
            }
            
            if let youtubeID = selectedVideoID {
                post.youtubeID = youtubeID
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
            post.postedBy = postedBy
            post.saveInBackgroundWithBlock({ (result, error) -> Void in
                self.postedBy?.details.incrementKey("posts", byAmount: 1)
                self.postedBy?.saveEventually()
                self.completeRequest(post, error: error)
            })
            
        default:
            break;
        }
    }
    
    func performUpdate(post: PFObject) {

        if var post = post as? Postable {
            post.content = textView.text
            post.edited = true
        }

        post.saveInBackgroundWithBlock ({ (result, error) -> Void in
            self.completeRequest(post, error: error)
        })
    }
    
    func completeRequest(post: PFObject, error: NSError?) {
        if let error = error {
            // TODO: Show error
            self.sendButton.setTitle("Send", forState: .Normal)
            self.sendButton.backgroundColor = UIColor.peterRiver()
            self.sendButton.userInteractionEnabled = true
        } else {
            // Success!
            self.delegate?.commentViewControllerDidFinishedPosting(post)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func dimissViewControllerPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addImagePressed(sender: AnyObject) {
        let imagesController = ANParseKit.commentStoryboard().instantiateViewControllerWithIdentifier("Images") as! ImagesViewController
        imagesController.delegate = self
        presentViewController(imagesController, animated: true, completion: nil)
    }
    
    @IBAction func addVideoPressed(sender: AnyObject) {
        let navController = ANParseKit.commentStoryboard().instantiateViewControllerWithIdentifier("BrowserSelector") as! UINavigationController
        let videoController = navController.viewControllers.last as! InAppBrowserSelectorViewController
        let initialURL = NSURL(string: "https://www.youtube.com")
        videoController.initWithTitle("Select a video", initialUrl: initialURL)
        videoController.delegate = self
        presentViewController(navController, animated: true, completion: nil)
    }

    @IBAction func sendPressed(sender: AnyObject) {
        if let editingPost = editingPost {
            performUpdate(editingPost)
        } else {
            performPost()
        }
    }
    
}

extension CommentViewController: ImagesViewControllerDelegate {
    func imagesViewControllerSelected(#imageData: ImageData) {
        selectedImageData = imageData
        photoCountLabel.hidden = false
        videoButton.enabled = false
    }
}

extension CommentViewController: InAppBrowserSelectorViewControllerDelegate {
    public func inAppBrowserSelectorViewControllerSelectedSite(siteURL: String) {
        if let url = NSURL(string: siteURL), let parameters = BFURL(URL: url).inputQueryParameters, let videoID = parameters["v"] as? String {
            selectedVideoID = videoID
            videoCountLabel.hidden = false
            photoButton.enabled = false
        }
    }
}