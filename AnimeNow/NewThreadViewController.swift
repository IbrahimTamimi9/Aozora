//
//  NewThreadViewController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 8/24/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Parse
import Bolts
import TTTAttributedLabel

public class NewThreadViewController: CommentViewController {
    
    @IBOutlet weak var tagLabel: TTTAttributedLabel!

    var tags: [PFObject] = [] {
        didSet {
            tagLabel.updateTags(tags, delegate: self)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        threadTitle.becomeFirstResponder()
        threadTitle.textColor = UIColor.blackColor()
        tagLabel.attributedText = nil
        
        if let anime = anime, let animeTitle = anime.title {
            threadTitle.placeholder = "Enter a thread title for \(animeTitle)"
        } else {
            threadTitle.placeholder = "Enter a thread title"
        }
        
        if let anime = anime {
            tags = [anime]
        }
    }
    
    override func performPost() {
        super.performPost()
        
        if !validThread() {
            return
        }
        
        var thread = Thread()
        thread.edited = false
        thread.title = threadTitle.text
        thread.content = textView.text
        thread.replies = 0
        thread.tags = tags
        
        if let selectedImageData = selectedImageData {
            thread.images = [selectedImageData]
        }
        
        if let youtubeID = selectedVideoID {
            thread.youtubeID = youtubeID
        }
    
        thread.startedBy = postedBy
        thread.saveInBackgroundWithBlock({ (result, error) -> Void in
            self.postedBy?.details.incrementKey("posts", byAmount: 1)
            self.postedBy?.saveEventually()
            
            if let error = error {
                // TODO: Show error
                self.sendButton.setTitle("Send", forState: .Normal)
                self.sendButton.backgroundColor = UIColor.peterRiver()
                self.sendButton.userInteractionEnabled = true
            } else {
                // Success!
                self.delegate?.commentViewControllerDidFinishedPosting(thread)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        })
        
    }
    
    override func performUpdate(post: PFObject) {
        super.performUpdate(post)
        
        if !validThread() {
            return
        }
    }
    
    func validThread() -> Bool {
        let content = textView.text
        if count(content) < 40 {
            presentBasicAlertWithTitle("Content too Short", message: "Content should be a 40 characters or longer, now \(count(content))")
            return false
        }
        
        let title = threadTitle.text
        if count(title) < 10 {
            presentBasicAlertWithTitle("Title too Short", message: "Thread title should be 10 characters or longer, now \(count(content))")
            return false
        }
        
        if tags.count == 0 {
            presentBasicAlertWithTitle("Add a tag", message: "You need to add at least one tag")
            return false
        }
        return true
    }
    
    // MARK: - IBActions
    
    @IBAction func addTags(sender: AnyObject) {
        let tagsController = ANParseKit.commentStoryboard().instantiateViewControllerWithIdentifier("Tags") as! TagsViewController
        tagsController.selectedDataSource = tags
        tagsController.delegate = self
        presentViewController(tagsController, animated: true, completion: nil)
    }
}

extension NewThreadViewController: TagsViewControllerDelegate {
    func tagsViewControllerSelected(#tags: [PFObject]) {
        self.tags = tags
    }
}

extension NewThreadViewController: TTTAttributedLabelDelegate {
    
    public func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        if let host = url.host where host == "tag", let index = url.pathComponents?[1] as? String, let idx = index.toInt() {
            tags.removeAtIndex(idx)
        }
    }
}