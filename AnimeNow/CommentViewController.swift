//
//  CommentViewController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 8/5/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation

public class CommentViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewBottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var inReply: UILabel!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    var initialStatusBarStyle: UIStatusBarStyle!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        textView.becomeFirstResponder()
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
    
    // MARK: - IBActions
    
    @IBAction func dimissViewControllerPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addImagePressed(sender: AnyObject) {
        let imagesController = ANParseKit.threadStoryboard().instantiateViewControllerWithIdentifier("Images") as! ImagesViewController
        presentViewController(imagesController, animated: true, completion: nil)
    }
    
    @IBAction func addVideoPressed(sender: AnyObject) {
        
    }

    @IBAction func sendPressed(sender: AnyObject) {
    }
    
}