//
//  EpisodeThreadViewController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 8/8/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Parse

public class EpisodeThreadViewController: ThreadViewController {
    
    @IBOutlet weak var episodeImage: UIImageView!
    @IBOutlet weak var animeTitle: UILabel!
    @IBOutlet weak var episodeTitle: UILabel!
    @IBOutlet weak var airedLabel: UILabel!
    
    var episode: Episode?
    var anime: Anime?
    
    public override func initWithThread(thread: Thread, postType: CommentViewController.PostType) {
        self.thread = thread
        self.postType = postType
    }
    
    public func initWithEpisode(episode: Episode, anime: Anime, postType: CommentViewController.PostType) {
        self.episode = episode
        self.anime = anime
        self.postType = postType
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "Loading..."
        navigationItem.leftBarButtonItems = nil
    }
    
    override func updateUIWithThread(thread: Thread) {
        super.updateUIWithThread(thread)
        
        if let anime = thread.anime {
            animeTitle.text = anime.title
        }
        
        if let episode = thread.episode {
            episodeImage.setImageFrom(urlString: episode.imageURLString(), animated: true)
            if let title = episode.title {
                episodeTitle.text = "Episode \(episode.number) · \(title) discussion"
            } else {
                episodeTitle.text = "Episode \(episode.number) discussion"
            }
            
            if let firstAired = episode.firstAired {
                airedLabel.text = "Aired on \(firstAired.mediumDate())"
            } else {
                airedLabel.text = ""
            }
        }
        
        if let anime = thread.anime, let animeTitle = anime.title, let episode = thread.episode {
            title = "\(animeTitle) - Episode \(episode.number)"
        } else {
            title = "Episode Discussion"
        }
    }
    
    override func fetchThread() {
        super.fetchThread()
        
        if let episode = episode {
            let query = Thread.query()!
            query.limit = 1
            query.whereKey("episode", equalTo: episode)
            query.includeKey("anime")
            query.includeKey("episode")
            query.includeKey("startedBy")
            query.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
                
                if let error = error {
                    // TODO: Show error
                } else if let result = result, let thread = result.last as? Thread {
                    self.thread = thread
                } else if let episode = self.episode, let anime = self.anime {
                    
                    // Create lazily
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
    }
    
    override func fetchPosts() {
        super.fetchPosts()
        fetchController.configureWith(self, queryDelegate: self, tableView: tableView, limit: FetchLimit, datasourceUsesSections: true)
    }
    
    // MARK: - IBAction
    
    public override func replyToThreadPressed(sender: AnyObject) {
        super.replyToThreadPressed(sender)
        
        if let thread = thread where User.currentUserLoggedIn() {
            let comment = ANParseKit.commentViewController()
            comment.initWithThread(thread, postType: postType, delegate: self)
            presentViewController(comment, animated: true, completion: nil)
        } else {
            presentBasicAlertWithTitle("Login first", message: "Select 'Me' tab")
        }
    }
}

extension EpisodeThreadViewController: FetchControllerQueryDelegate {
    
    public override func queriesForSkip(#skip: Int) -> [PFQuery] {
        
        let query = Post.query()!
        query.skip = skip
        query.limit = FetchLimit
        query.whereKey("thread", equalTo: thread!)
        query.whereKey("replyLevel", equalTo: 0)
        query.orderByAscending("createdAt")
        query.includeKey("postedBy")
        
        
        let innerQuery = Post.query()!
        innerQuery.skip = skip
        innerQuery.limit = FetchLimit
        innerQuery.whereKey("thread", equalTo: thread!)
        innerQuery.whereKey("replyLevel", equalTo: 0)
        innerQuery.orderByAscending("createdAt")
        
        let repliesQuery = Post.query()!
        repliesQuery.skip = 0
        repliesQuery.limit = 1000
        repliesQuery.whereKey("parentPost", matchesKey: "objectId", inQuery: innerQuery)
        repliesQuery.orderByAscending("createdAt")
        repliesQuery.includeKey("postedBy")
        
        return [query, repliesQuery]
    }
}