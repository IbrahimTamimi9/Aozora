//
//  NewPostViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/20/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANParseKit
import Bolts

protocol NewPostViewControllerDelegate: class {
    func didPost()
}

public class NewPostViewController: UIViewController {

    var malScrapper: MALScrapper!
    var topic: MALScrapper.Topic!
    weak var delegate: NewPostViewControllerDelegate?
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textFieldBottomLayoutConstraint: NSLayoutConstraint!
    
    public func initWithTopic(topic: MALScrapper.Topic, scrapper: MALScrapper) {
        self.topic = topic
        self.malScrapper = scrapper
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        textView.becomeFirstResponder()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
        
        textFieldBottomLayoutConstraint.constant = height
        view.setNeedsUpdateConstraints()
        
    }
    
    @IBAction func sendPressed(sender: AnyObject) {
        
        if !User.loggedIn {
            return
        }
        
        let username = User.username ?? ""
        
        malScrapper.postToForum(topic.id, message: textView.text, with: username).continueWithBlock
            { (task: BFTask!) -> AnyObject! in
            
                if let _ = task.result {
                    self.delegate?.didPost()
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else if let error = task.error {
                    // TODO: Show error message/
                    println("\(error)")
                }
                
            return nil
        }
    }
    @IBAction func cancelPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension NewPostViewController: UINavigationBarDelegate {
    public func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
}