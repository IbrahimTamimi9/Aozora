//
//  EpisodeViewController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 8/1/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANCommonKit
import ANParseKit
import TTTAttributedLabel
import Bolts

class EpisodeViewController: UIViewController {

    var fetchController = FetchController()
    var refreshControl = UIRefreshControl()
    var loadingView: LoaderView!
    var episode: Episode!
    
    @IBOutlet weak var episodeScreenshot: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 112.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        PostCell.registerNibFor(tableView: tableView, type: PostCell.CellType.Text)
        PostCell.registerNibFor(tableView: tableView, type: PostCell.CellType.Image)
        CommentCell.registerNibFor(tableView: tableView, type: CommentCell.CellType.Text)
        CommentCell.registerNibFor(tableView: tableView, type: CommentCell.CellType.Image)
        WriteACommentCell.registerNibFor(tableView: tableView)
        
        loadingView = LoaderView(parentView: view)
        addRefreshControl(refreshControl, action: "fetchEpisodeComments", forTableView: tableView)
        
        fetchEpisodeComments()
    }
    
    func fetchEpisodeComments() {
        let query = Thread.query()!
        query.limit = 1
//        query.whereKey("episode", equalTo: episode)
        query.findObjectsInBackground().continueWithBlock { (task: BFTask!) -> AnyObject! in
            
            if let result = task.result as? [Thread], let aThread = result.first {
                
            } else {
                // If does not exist, create one lazily
                
            }
            
            return nil
        }
    }
}
