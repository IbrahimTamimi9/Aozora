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

public class CustomThreadViewController: ThreadViewController {
    
    @IBOutlet weak var imageContent: UIImageView!
    @IBOutlet weak var threadTitle: UILabel!
    @IBOutlet weak var threadContent: UILabel!
    @IBOutlet weak var tagsLabel: TTTAttributedLabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var postedDate: UILabel!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    var episode: Episode?
    var anime: Anime?
    
    public override func initWithThread(thread: Thread) {
        self.thread = thread
        self.threadType = .Custom
    }
    
    public func initWithEpisode(episode: Episode, anime: Anime) {
        self.episode = episode
        self.anime = anime
        self.threadType = .Episode
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func updateUIWithThread(thread: Thread) {
        super.updateUIWithThread(thread)
        
        title = "Loading..."
        navigationItem.leftBarButtonItems = nil
        
        if let episode = episode {
            updateUIWithEpisodeThread(thread)
        } else {
            updateUIWithGeneralThread(thread)
        }
    }
    
    var resizedTableHeader = false
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !resizedTableHeader {
            resizedTableHeader = true
            sizeHeaderToFit()
        }
    }
    
    func updateUIWithEpisodeThread(thread: Thread) {
        
        if let episode = thread.episode {
            imageContent.setImageFrom(urlString: episode.imageURLString(), animated: true)
            if let title = episode.title {
                threadTitle.text = title
            } else {
                threadTitle.text = ""
            }
            
            if let firstAired = episode.firstAired {
                postedDate.text = "Aired on \(firstAired.mediumDate())"
            } else {
                postedDate.text = ""
            }
            
            if let overview = episode.overview {
                threadContent.text = overview
            } else {
                threadContent.text = ""
            }
        }
        
        if let anime = thread.anime, let animeTitle = anime.title, let episode = thread.episode {
            title = "\(animeTitle) - Episode \(episode.number)"
        } else {
            title = ""
        }
        
        if let anime = thread.anime {
            avatar.setImageFrom(urlString: anime.imageUrl)
            username.text = title
        }
    }
    
    func updateUIWithGeneralThread(thread: Thread) {

        title = thread.title
        threadTitle.text = thread.title
        
        if let content = thread.content {
            threadContent.text = content
        }
        
        tagsLabel.updateTags(thread.tags, delegate: self)
        
        // TODO: Merge this repeated code
        if let startedBy = thread.startedBy {
            avatar.setImageWithPFFile(startedBy.avatarThumb!)
            username.text = startedBy.username
            postedDate.text = thread.createdAt!.timeAgo()
        }
        
        let repliesTitle = repliesButtonTitle(thread.replies)
        commentsButton.setTitle(repliesTitle, forState: .Normal)
        
        setImages(thread.images, imageView: imageContent, imageHeightConstraint: imageHeightConstraint)
        
        prepareForVideo(playButton, imageView: imageContent, imageHeightConstraint: imageHeightConstraint, youtubeID: thread.youtubeID)
    }
    
    func sizeHeaderToFit() {
        var header = tableView.tableHeaderView!
        
        header.setNeedsLayout()
        header.layoutIfNeeded()
        
        threadTitle.preferredMaxLayoutWidth = threadTitle.frame.size.width
        threadContent.preferredMaxLayoutWidth = threadContent.frame.size.width
        
        var height = header.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        var frame = header.frame
        
        frame.size.height = height
        header.frame = frame
        tableView.tableHeaderView = header
    }
    
    override func fetchThread() {
        super.fetchThread()

        let query = Thread.query()!
        query.limit = 1
        
        if let episode = episode {
            query.whereKey("episode", equalTo: episode)
            query.includeKey("episode")
        } else if let thread = thread, let objectId = thread.objectId {
            query.whereKey("objectId", equalTo: objectId)
        }
        
        query.includeKey("anime")
        query.includeKey("startedBy")
        query.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
            
            if let error = error {
                // TODO: Show error
            } else if let result = result, let thread = result.last as? Thread {
                self.thread = thread
            } else if let episode = self.episode, let anime = self.anime where self.threadType == ThreadType.Episode {
                
                // Create episode threads lazily
                let thread = Thread()
                thread.episode = episode
                thread.anime = anime
                thread.locked = false
                thread.replies = 0
                thread.title = "\(anime.title!) - Episode \(episode.number)"
                thread.saveInBackgroundWithBlock({ (result, error) -> Void in
                    if result {
                        self.thread = thread
                    }
                })
            }
        })
        
    }
    
    override func fetchPosts() {
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
        } else {
            presentBasicAlertWithTitle("Login first", message: "Select 'Me' tab")
        }
    }
    
    @IBAction func playTrailerPressed(sender: AnyObject) {
        if let thread = thread, let youtubeID = thread.youtubeID {
            playTrailer(youtubeID)
        }
    }
}

extension CustomThreadViewController: FetchControllerQueryDelegate {
    
    public override func queriesForSkip(#skip: Int) -> [PFQuery] {
        
        let innerQuery = Post.query()!
        innerQuery.skip = skip
        innerQuery.limit = FetchLimit
        innerQuery.whereKey("thread", equalTo: thread!)
        innerQuery.whereKey("replyLevel", equalTo: 0)
        innerQuery.orderByAscending("createdAt")
        
        let query = innerQuery.copy() as! PFQuery
        query.includeKey("postedBy")
        
        let repliesQuery = Post.query()!
        repliesQuery.skip = 0
        repliesQuery.limit = 1000
        repliesQuery.whereKey("parentPost", matchesKey: "objectId", inQuery: innerQuery)
        repliesQuery.orderByAscending("createdAt")
        repliesQuery.includeKey("postedBy")
        
        return [query, repliesQuery]
    }
}

extension CustomThreadViewController: TTTAttributedLabelDelegate {
    
    public override func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        super.attributedLabel(label, didSelectLinkWithURL: url)
        
        if let host = url.host where host == "tag",
            let index = url.pathComponents?[1] as? String,
            let idx = index.toInt() {
               println(idx)
        }
    }
}