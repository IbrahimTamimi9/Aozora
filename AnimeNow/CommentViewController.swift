//
//  CommentViewController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 8/5/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Parse

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
    var replyingToUser: User?
    var postType: PostType = .Timeline
    
    public enum PostType {
        case Timeline
        case Episode
        case Anime
        case Forum
    }
    
    public func initWith(#postType: PostType, replyingToUser: User? = nil) {
        self.postType = postType
        self.replyingToUser = replyingToUser
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        textView.becomeFirstResponder()
        
        photoCountLabel.hidden = true
        videoCountLabel.hidden = true
        
        if let replyingToUser = replyingToUser {
            inReply.text = "  In Reply to \(replyingToUser.aozoraUsername)"
        } else {
            inReply.text = "  New Post"
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
            if let selectedImageURL = selectedImageURL {
                timelinePost.images = [selectedImageURL]
            }
            
            if let youtubeID = selectedVideoID {
                timelinePost.youtubeID = youtubeID
            }
            
            if let replyingToUser = replyingToUser {
                timelinePost.replyLevel = 1
                timelinePost.userTimeline = replyingToUser
            } else {
                timelinePost.replyLevel = 0
                timelinePost.userTimeline = user
            }
            
            timelinePost.postedBy = user
            timelinePost.saveInBackgroundWithBlock({ (result, error) -> Void in
                if let error = error {
                    // Show error
                    self.sendButton.setTitle("Send", forState: .Normal)
                } else {
                    // Success!
                    self.sendButton.setTitle("Sent!", forState: .Normal)
                    self.delegate?.commentViewControllerDidFinishedPosting(timelinePost)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })
        default:
            break;
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func dimissViewControllerPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addImagePressed(sender: AnyObject) {
        let imagesController = ANParseKit.threadStoryboard().instantiateViewControllerWithIdentifier("Images") as! ImagesViewController
        imagesController.delegate = self
        presentViewController(imagesController, animated: true, completion: nil)
    }
    
    @IBAction func addVideoPressed(sender: AnyObject) {
        
    }

    @IBAction func sendPressed(sender: AnyObject) {
        performPost()
    }
    
}

extension CommentViewController: ImagesViewControllerDelegate {
    func imagesViewControllerSelected(#imageURL: String) {
        selectedImageURL = imageURL
        photoCountLabel.hidden = false
        videoButton.enabled = false
    }
}