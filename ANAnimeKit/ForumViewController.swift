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
import Parse

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
        // TODO: Delete this query
        let query = Thread.query()!
        query.whereKey("anime", equalTo: anime)
        
        let query2 = Thread.query()!
        query2.whereKey("tags", containedIn: [anime])
        
        let orQuery = PFQuery.orQueryWithSubqueries([query,query2])
        orQuery.includeKey("tags")
        orQuery.includeKey("anime")
        orQuery.includeKey("startedBy")
        fetchController.configureWith(self, query: orQuery, tableView: tableView, limit: 100)
    }
    
    @IBAction func createAnimeThread(sender: AnyObject) {
        let comment = ANParseKit.newThreadViewController()
        comment.initWith(threadType: .Custom, delegate: self, anime: anime)
        presentViewController(comment, animated: true, completion: nil)
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

extension ForumViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let tabBar = tabBarController as? CustomTabBarController {
            tabBar.disableDragDismiss()
        }
        
        let thread = fetchController.objectAtIndex(indexPath.row) as! Thread
        
        let controller: UIViewController!
        
        let threadController = ANParseKit.customThreadViewController()
        if let episode = thread.episode {
            // Episode thread
            threadController.initWithEpisode(thread.episode!, anime: thread.anime!)
        } else {
            // Custom thread
            threadController.initWithThread(thread)
        }
        
        controller = threadController
        
        if InAppController.purchasedAnyPro() == nil {
            controller.interstitialPresentationPolicy = .Automatic
        }
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ForumViewController: FetchControllerDelegate {
    public func didFetchFor(#skip: Int) {
        self.loadingView.stopAnimating()
    }
}

extension ForumViewController: CommentViewControllerDelegate {
    public func commentViewControllerDidFinishedPosting(post: PFObject) {
        fetchAnimeRelatedThreads()
    }
}