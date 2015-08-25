//
//  ForumViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/21/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANCommonKit
import ANAnimeKit
import ANParseKit

class ForumsViewController: UIViewController {
    
    var loadingView: LoaderView!
    var dataSource: [Thread] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!

    var fetchController = FetchController()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 150.0
        tableView.rowHeight = UITableViewAutomaticDimension

        loadingView = LoaderView(parentView: view)
        loadingView.startAnimating()
        
        addRefreshControl(refreshControl, action:"fetchThreads", forTableView: tableView)
        
        fetchThreads()
    }
    
    func fetchThreads() {
        let query = Thread.query()!
        query.whereKey("replies", greaterThan: 0)
        query.whereKeyExists("episode")
        
        let query2 = Thread.query()!
        query2.whereKeyDoesNotExist("episode")
        
        let orQuery = PFQuery.orQueryWithSubqueries([query, query2])
        orQuery.includeKey("tags")
        orQuery.orderByDescending("updatedAt")
        fetchController.configureWith(self, query: orQuery, tableView: tableView, limit: 100)
    }
    
}

extension ForumsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return fetchController.dataCount()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TopicCell") as! TopicCell
        
        let thread = fetchController.objectAtIndex(indexPath.row) as! Thread
        let title = thread.title
        
        if let _ = thread.episode {
            cell.typeLabel.text = " "
        } else {
            cell.typeLabel.text = ""
        }
        
        cell.title.text = title
        cell.information.text = "\(thread.replies) comments · \(thread.updatedAt!.timeAgo())"
        cell.layoutIfNeeded()
        return cell
    }
}

extension ForumsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let thread = fetchController.objectAtIndex(indexPath.row) as! Thread
        
        let threadController = ANParseKit.customThreadViewController()
        
        if let episode = thread.episode, let anime = thread.anime {
            threadController.initWithEpisode(episode, anime: anime)
        } else {
            threadController.initWithThread(thread)
        }
        
        if InAppController.purchasedAnyPro() == nil {
            threadController.interstitialPresentationPolicy = .Automatic
        }
        
        navigationController?.pushViewController(threadController, animated: true)
    }
}

extension ForumsViewController: FetchControllerDelegate {
    func didFetchFor(#skip: Int) {
        refreshControl.endRefreshing()
        loadingView.stopAnimating()
    }
}