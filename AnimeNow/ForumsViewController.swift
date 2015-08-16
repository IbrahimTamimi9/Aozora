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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 150.0
        tableView.rowHeight = UITableViewAutomaticDimension

        loadingView = LoaderView(parentView: view)
        loadingView.startAnimating()
        
        fetchThreads()
    }
    
    func fetchThreads() {
        let query = Thread.query()!
        query.orderByDescending("updatedAt")
        fetchController.configureWith(self, query: query, tableView: tableView, limit: 100)
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
        //cell.typeLabel.text = topic.type == MALScrapper.TopicType.Sticky ? " " : ""
        cell.title.text = title
        cell.information.text = " \(thread.replies) comments · \(thread.updatedAt!.timeAgo())"
        cell.layoutIfNeeded()
        return cell
    }
}

extension ForumsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let thread = fetchController.objectAtIndex(indexPath.row) as! Thread
        
        let episodeThreadController = ANParseKit.episodeThreadViewController()
        episodeThreadController.initWithEpisode(thread.episode!, anime: thread.anime!, postType: .Episode)
        
        if InAppController.purchasedAnyPro() == nil {
            episodeThreadController.interstitialPresentationPolicy = .Automatic
        }
        
        navigationController?.pushViewController(episodeThreadController, animated: true)
    }
}

extension ForumsViewController: FetchControllerDelegate {
    func didFetchFor(#skip: Int) {
        self.loadingView.stopAnimating()
    }
}