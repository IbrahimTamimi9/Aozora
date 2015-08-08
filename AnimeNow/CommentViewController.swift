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
    
    var selectedImageURL: String?
    var selectedVideoID: String?
    
    var initialStatusBarStyle: UIStatusBarStyle!
    var user = User.currentUser()!
    var parentPost: Postable?
    var postType: PostType = .Timeline
    var editingPost: PFObject?
    
    public enum PostType {
        case Timeline
        case Episode
        case Anime
        case Forum
    }
    
    public func initWith(#postType: PostType, delegate: CommentViewControllerDelegate?, editingPost: PFObject? = nil, parentPost: Postable? = nil) {
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
        self.sendButton.setTitle("Sending...", forState: .Normal)
        
        switch postType {
        case .Timeline:
            var timelinePost = TimelinePost()
            timelinePost.content = textView.text
            timelinePost.edited = false
            if let selectedImageURL = selectedImageURL {
                timelinePost.images = [selectedImageURL]
            }
            
            if let youtubeID = selectedVideoID {
                timelinePost.youtubeID = youtubeID
            }
            
            if let parentPost = parentPost as? TimelinePostable {
                timelinePost.replyLevel = 1
                timelinePost.userTimeline = parentPost.userTimeline
            } else {
                timelinePost.replyLevel = 0
                timelinePost.userTimeline = user
            }
            
            timelinePost.postedBy = user
            
            var objectsToUpdate = [(timelinePost as PFObject)]
            if let parentPost = parentPost as? PFObject {
                parentPost.addObject(timelinePost, forKey: "replies")
                objectsToUpdate.append(parentPost)
            }
            PFObject.saveAllInBackground(objectsToUpdate, block: { (result, error) -> Void in
                self.completeRequest(timelinePost, error: error)
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
            // Show error
            self.sendButton.setTitle("Send", forState: .Normal)
        } else {
            // Success!
            self.sendButton.setTitle("Sent!", forState: .Normal)
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
    func imagesViewControllerSelected(#imageURL: String) {
        selectedImageURL = imageURL
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