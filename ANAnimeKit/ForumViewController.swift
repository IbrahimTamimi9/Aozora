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

extension ForumViewController: StatusBarVisibilityProtocol {
    func shouldHideStatusBar() -> Bool {
        return false
    }
    func updateCanHideStatusBar(canHide: Bool) {
    }
}

public class ForumViewController: AnimeBaseViewController {
    
    var malScrapper: MALScrapper!
    var dataSource: [MALScrapper.Topic] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var loadingView: LoaderView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 150.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        loadingView = LoaderView()
        loadingView.addToViewController(self)
        loadingView.startAnimating()
        
        malScrapper = MALScrapper(viewController: self)
        malScrapper.topicsFor(anime: anime).continueWithBlock {
            (task: BFTask!) -> AnyObject! in
            
            self.tableView.animateFadeIn()
            self.loadingView.stopAnimating()
            if task.result != nil {
                self.dataSource = task.result as! [MALScrapper.Topic]
            }
            
            return nil
        }
    }
    
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowTopic" {
            let destination = segue.destinationViewController as! TopicViewController
            destination.topic = sender as! MALScrapper.Topic
        }
    }
}

extension ForumViewController: UITableViewDataSource {
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TopicCell") as! TopicCell
        
        let topic = dataSource[indexPath.row]
        let title = topic.title.stringByReplacingOccurrencesOfString("\(anime.title)", withString: "")
        cell.typeLabel.text = topic.type == MALScrapper.TopicType.Sticky ? " " : ""
        cell.title.text = title
        cell.information.text = "\(topic.replies)  · last post \(topic.lastPost.date) by \(topic.lastPost.user)"
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
        
        performSegueWithIdentifier("ShowTopic", sender: dataSource[indexPath.row])

    }
}