//
//  AnimeThreadViewController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 8/8/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Parse
import TTTAttributedLabel
import ANCommonKit
import ANParseKit

public class NotificationThreadViewController: ThreadViewController {
    
    @IBOutlet weak var threadTitle: UILabel!
    
    var timelinePost: TimelinePostable?
    var post: ThreadPostable?
    
    public func initWithPost(post: Postable) {
        if let timelinePost = post as? TimelinePostable {
            self.timelinePost = timelinePost
        } else if let threadPost = post as? ThreadPostable {
            self.post = threadPost
        }
        self.threadType = .Custom
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        fetchPosts()
    }
    
    override public func updateUIWithThread(thread: Thread) {
        super.updateUIWithThread(thread)
        
        title = "Loading..."
        
        if thread.locked {
            navigationItem.rightBarButtonItem?.enabled = false
        }
    }
    
    var resizedTableHeader = false
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !resizedTableHeader && title != nil {
            resizedTableHeader = true
            sizeHeaderToFit()
        }
    }

    
    func sizeHeaderToFit() {
        var header = tableView.tableHeaderView!
        
        header.setNeedsLayout()
        header.layoutIfNeeded()
        
        threadTitle.preferredMaxLayoutWidth = threadTitle.frame.size.width
        
        var height = header.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        var frame = header.frame
        
        frame.size.height = height
        header.frame = frame
        tableView.tableHeaderView = header
    }
    
    override public func fetchPosts() {
        super.fetchPosts()
        fetchController.configureWith(self, queryDelegate: self, tableView: tableView, limit: FetchLimit, datasourceUsesSections: true)
    }
    
    // MARK: - IBAction
    
    public override func replyToThreadPressed(sender: AnyObject) {
        super.replyToThreadPressed(sender)
        
        if let thread = thread where User.currentUserLoggedIn() {
            let comment = ANParseKit.newPostViewController()
            comment.initWith(thread: thread, threadType: threadType, delegate: self)
            presentViewController(comment, animated: true, completion: nil)
        } else if let thread = thread where thread.locked {
            presentBasicAlertWithTitle("Thread is locked", message: nil)
        } else {
            presentBasicAlertWithTitle("Login first", message: "Select 'Me' tab")
        }
    }
    
    @IBAction func openUserProfile(sender: AnyObject) {
        if let startedBy = thread?.startedBy {
            openProfile(startedBy)
        }
    }
    
    @IBAction func dismissViewController(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension NotificationThreadViewController: FetchControllerQueryDelegate {
    
    public override func queriesForSkip(#skip: Int) -> [PFQuery] {
        
        var innerQuery: PFQuery!
        var repliesQuery: PFQuery!
        if let timelinePost = timelinePost as? TimelinePost {
            innerQuery = TimelinePost.query()!
            innerQuery.whereKey("objectId", equalTo: timelinePost.objectId!)
            
            repliesQuery = TimelinePost.query()!
        } else if let post = post as? Post {
            innerQuery = Post.query()!
            innerQuery.whereKey("objectId", equalTo: post.objectId!)
            
            repliesQuery = Post.query()!
        }
        
        var query = innerQuery.copy() as! PFQuery
        query.includeKey("postedBy")
        
        repliesQuery.skip = 0
        repliesQuery.limit = 1000
        repliesQuery.whereKey("parentPost", matchesKey: "objectId", inQuery: innerQuery)
        repliesQuery.orderByAscending("createdAt")
        repliesQuery.includeKey("postedBy")
        
        return [query, repliesQuery]
    }
}

extension NotificationThreadViewController: CommentViewControllerDelegate {
    public override func commentViewControllerDidFinishedPosting(post: PFObject) {
        fetchThread()
    }
}

extension NotificationThreadViewController: FetchControllerDelegate {
    public override func didFetchFor(#skip: Int) {
        
        let post = fetchController.objectInSection(0)
        if let post = post as? TimelinePostable {
            navigationItem.title = "Timeline Post"
        } else {
            navigationItem.title = "Thread Post"
        }
    }
}

extension NotificationThreadViewController: UINavigationBarDelegate {
    public func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
}
