//
//  NewReviewViewController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 1/10/16.
//  Copyright © 2016 AnyTap. All rights reserved.
//

import Foundation
import Parse
import Bolts
import TTTAttributedLabel

public class NewReviewViewController: CommentViewController {
    
    let EditingSummaryCacheKey = "NewReview.SummaryContent"
    let EditingContentCacheKey = "NewThread.TextContent"
    
    @IBOutlet weak var reviewSummary: UITextField!
    
    @IBOutlet weak var ratingsLabel1: UILabel!
    @IBOutlet weak var ratingsLabel2: UILabel!
    
    var ratings: [Int] = []
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        if let title = NSUserDefaults.standardUserDefaults().objectForKey(EditingSummaryCacheKey) as? String {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(EditingSummaryCacheKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            reviewSummary.text = title
        }
        
        if let content = NSUserDefaults.standardUserDefaults().objectForKey(EditingContentCacheKey) as? String {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(EditingContentCacheKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            textView.text = content
        }
        
        textView.becomeFirstResponder()
        reviewSummary.textColor = UIColor.blackColor()
        
        if var thread = editingPost as? Thread {
            textView.text = thread.content
            reviewSummary.text = thread.title
            
            if let youtubeID = thread.youtubeID {
                selectedVideoID = youtubeID
                videoCountLabel.hidden = false
                photoCountLabel.hidden = true
            } else if let imageData = thread.imagesData?.last {
                selectedImageData = imageData
                videoCountLabel.hidden = true
                photoCountLabel.hidden = false
            }
        }
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if !dataPersisted && editingPost == nil {
            NSUserDefaults.standardUserDefaults().setObject(reviewSummary.text, forKey: EditingSummaryCacheKey)
            NSUserDefaults.standardUserDefaults().setObject(textView.text, forKey: EditingContentCacheKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    override func performPost() {
        super.performPost()
        
        if !validReview() {
            return
        }
        
        self.sendButton.setTitle("Creating...", forState: .Normal)
        self.sendButton.backgroundColor = UIColor.watching()
        self.sendButton.userInteractionEnabled = false
        
        var thread = Thread()
        thread.edited = false
        thread.title = reviewSummary.text!
        thread.content = textView.text
        var postable = thread as Postable
        postable.replyCount = 0
        thread.subscribers = [postedBy!]
        thread.lastPostedBy = postedBy
        
        if let selectedImageData = selectedImageData {
            thread.imagesData = [selectedImageData]
        }
        
        if let youtubeID = selectedVideoID {
            thread.youtubeID = youtubeID
        }
        
        thread.startedBy = postedBy
        thread.saveInBackgroundWithBlock({ (result, error) -> Void in
            self.postedBy?.incrementPostCount(1)
            self.completeRequest(thread, parentPost:nil, error: error)
        })
        
    }
    
    override func performUpdate(post: PFObject) {
        super.performUpdate(post)
        
        if !validReview() {
            return
        }
        
        self.sendButton.setTitle("Updating...", forState: .Normal)
        self.sendButton.backgroundColor = UIColor.watching()
        self.sendButton.userInteractionEnabled = false
        
        if var thread = post as? Review {
            thread.edited = true
            thread.content = textView.text
            
            if let summary = reviewSummary.text {
                thread.summary = summary
            }
            
            if let selectedImageData = selectedImageData {
                thread.imagesData = [selectedImageData]
            } else {
                thread.imagesData = []
            }
            
            if let youtubeID = selectedVideoID {
                thread.youtubeID = youtubeID
            } else {
                thread.youtubeID = nil
            }
            
            thread.saveInBackgroundWithBlock({ (result, error) -> Void in
                self.completeRequest(thread, parentPost:nil, error: error)
            })
        }
    }
    
    override func completeRequest(post: PFObject, parentPost: PFObject?, error: NSError?) {
        super.completeRequest(post, parentPost: parentPost, error: error)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(EditingSummaryCacheKey)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(EditingContentCacheKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func validReview() -> Bool {
        let content = textView.text
        
        if User.muted(self) {
            return false
        }
        
        if content.characters.count < 20 {
            presentBasicAlertWithTitle("Content too Short", message: "Content should be a 20 characters or longer, now \(content.characters.count)")
            return false
        }
        
        
        if let title = reviewSummary.text where title.characters.count != 0 && title.characters.count < 10 {
            presentBasicAlertWithTitle("Review summary too Short", message: "Review summary should either be empty or 10 characters or longer, now \(title.characters.count)")
            return false
        }
        
        if ratings.count == 0 {
            presentBasicAlertWithTitle("Add ratings", message: "You need to fill all ratings")
            return false
        }
        
        return true
    }
    
    // MARK: - IBActions
    @IBAction func setRatingsPressed(sender: AnyObject) {
        
    }
}

extension NewReviewViewController: ModalTransitionScrollable {
    public var transitionScrollView: UIScrollView? {
        return textView
    }
}