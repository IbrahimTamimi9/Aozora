//
//  EpisodeThreadViewController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 8/8/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation

public class EpisodeThreadViewController: ThreadViewController {
    
    @IBOutlet weak var episodeImage: UIImageView!
    @IBOutlet weak var animeTitle: UILabel!
    @IBOutlet weak var episodeTitle: UILabel!
    @IBOutlet weak var airedLabel: UILabel!
    
    var episode: Episode?
    
    public override func initWithThread(thread: Thread) {
        self.thread = thread
    }
    
    public func initWithEpisode(episode: Episode) {
        self.episode = episode
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func updateUIWithThread(thread: Thread) {
        super.updateUIWithThread(thread)
        
        if let anime = thread.anime {
            animeTitle.text = anime.title
        }
        
        if let episode = thread.episode {
            episodeImage.setImageFrom(urlString: episode.imageURLString(), animated: true)
            if let title = episode.title {
                episodeTitle.text = "Episode \(episode.number) / \(title) discussion"
            } else {
                episodeTitle.text = "Episode \(episode.number) discussion"
            }
            
            if let firstAired = episode.firstAired {
                airedLabel.text = "Aired on \(firstAired.mediumDate())"
            } else {
                airedLabel.text = ""
            }
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
                
                if let result = result, let thread = result.last as? Thread {
                    self.thread = thread
                } else {
                    // TODO: Show error
                }
            })
        }
    }
    
    override func updateThread() {
        super.updateThread()
        
        let query = Post.query()!
        query.skip = 0
        query.whereKey("thread", equalTo: thread!)
        query.orderByDescending("createdAt")
        query.includeKey("postedBy")
        query.includeKey("replies")
        fetchController.configureWith(self, query: query, tableView: tableView)
    }
}