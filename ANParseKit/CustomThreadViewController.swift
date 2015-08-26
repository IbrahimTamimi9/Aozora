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
        
        if let episode = episode {
            updateUIWithEpisodeThread(thread)
        } else {
            updateUIWithGeneralThread(thread)
        }
        
        let repliesTitle = repliesButtonTitle(thread.replies)
        commentsButton.setTitle(repliesTitle, forState: .Normal)
        
        tagsLabel.updateTags(thread.tags, delegate: self)
        prepareForVideo(playButton, imageView: imageContent, imageHeightConstraint: imageHeightConstraint, youtubeID: thread.youtubeID)
    }
    
    var resizedTableHeader = false
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !resizedTableHeader && title != nil {
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
        
        // TODO: Merge this repeated code
        if let startedBy = thread.startedBy {
            avatar.setImageWithPFFile(startedBy.avatarThumb!)
            username.text = startedBy.username
            postedDate.text = thread.createdAt!.timeAgo()
        }
        
        setImages(thread.images, imageView: imageContent, imageHeightConstraint: imageHeightConstraint)
    }
    
    func sizeHeaderToFit() {
        var header = tableView.tableHeaderView!
        
        header.setNeedsLayout()
        header.layoutIfNeeded()
        
        username.preferredMaxLayoutWidth = username.frame.size.width
        threadTitle.preferredMaxLayoutWidth = threadTitle.frame.size.width
        threadContent.preferredMaxLayoutWidth = threadContent.frame.size.width
        tagsLabel.preferredMaxLayoutWidth = tagsLabel.frame.size.width
        
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
        query.includeKey("tags")
        query.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
            
            if let error = error {
                // TODO: Show error
            } else if let result = result, let thread = result.last as? Thread {
                self.thread = thread
            } else if let episode = self.episode, let anime = self.anime where self.threadType == ThreadType.Episode {
                
                // Create episode threads lazily
                let parameters = [
                    "animeID":anime.objectId!,
                    "episodeID":episode.objectId!,
                    "animeTitle": anime.title!,
                    "episodeNumber": episode.number
                ] as [String : AnyObject]
                
                PFCloud.callFunctionInBackground("createEpisodeThread", withParameters: parameters, block: { (result, error) -> Void in
                    
                    if let _ = error {
                        
                    } else {
                        println("Created episode thread")
                        self.fetchThread()
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