//
//  ForumViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/16/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANCommonKit
import ANParseKit
import Bolts
import iAd

extension ForumViewController: StatusBarVisibilityProtocol {
    func shouldHideStatusBar() -> Bool {
        return false
    }
    func updateCanHideStatusBar(canHide: Bool) {
    }
}

public class ForumViewController: AnimeBaseViewController {
    
    var dataSource: [Thread] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var loadingView: LoaderView!
    var fetchController = FetchController()
    
    @IBOutlet weak public var navigationBar: UINavigationItem!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.title = "\(anime.title!) Discussion"
        
        tableView.estimatedRowHeight = 150.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        loadingView = LoaderView(parentView: view)
        loadingView.startAnimating()
        fetchAnimeRelatedThreads()
    }
    
    func fetchAnimeRelatedThreads() {
        let query = Thread.query()!
        query.whereKey("anime", equalTo: anime)
        fetchController.configureWith(self, query: query, tableView: tableView, limit: 100)
    }
    
}

extension ForumViewController: UITableViewDataSource {
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return fetchController.dataCount()
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
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

extension ForumViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let tabBar = tabBarController as? CustomTabBarController {
            tabBar.disableDragDismiss()
        }
        
        // TODO: Support Anime threads..
        let thread = dataSource[indexPath.row]
        
        let episodeThreadController = ANParseKit.episodeThreadViewController()
        episodeThreadController.initWithEpisode(thread.episode!, anime: thread.anime!, postType: .Episode)
        
        if InAppController.purchasedAnyPro() == nil {
            episodeThreadController.interstitialPresentationPolicy = .Automatic
        }
        
        navigationController?.pushViewController(episodeThreadController, animated: true)
    }
}

extension ForumViewController: FetchControllerDelegate {
    public func didFetchFor(#skip: Int) {
        self.loadingView.stopAnimating()
    }
}