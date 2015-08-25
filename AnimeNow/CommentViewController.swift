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

public enum ThreadType {
    case Timeline
    case Episode
    case Custom
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
    
    @IBOutlet weak var threadTitle: UITextField!
    
    public weak var delegate: CommentViewControllerDelegate?
    
    var selectedImageData: ImageData?
    var selectedVideoID: String?
    
    var initialStatusBarStyle: UIStatusBarStyle!
    var postedBy = User.currentUser()
    var postedIn: User!
    var parentPost: Postable?
    var thread: Thread?
    var threadType: ThreadType = .Timeline
    var editingPost: PFObject?
    var anime: Anime?
    
    public func initWithTimelinePost(delegate: CommentViewControllerDelegate?, postedIn: User, editingPost: PFObject? = nil, parentPost: Postable? = nil) {
        self.postedIn = postedIn
        self.threadType = .Timeline
        self.editingPost = editingPost
        self.delegate = delegate
        self.parentPost = parentPost
    }
    
    public func initWith(thread: Thread? = nil, threadType: ThreadType, delegate: CommentViewControllerDelegate?, editingPost: PFObject? = nil, parentPost: Postable? = nil, anime: Anime? = nil) {
        self.postedBy = User.currentUser()!
        self.thread = thread
        self.threadType = threadType
        self.editingPost = editingPost
        self.delegate = delegate
        self.parentPost = parentPost
        self.anime = anime
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        photoCountLabel.hidden = true
        videoCountLabel.hidden = true
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
    
    // MARK: - Override
    func performPost() {
    }
    
    func performUpdate(post: PFObject) {
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