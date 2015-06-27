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
    
    // Set board to load board instead of anime
    public var board: Int?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 150.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        loadingView = LoaderView(parentView: self.view)
        malScrapper = MALScrapper(viewController: self)
        
        loadingView.startAnimating()
        
        if let anime = anime {
            malScrapper.topicsFor(anime: anime).continueWithBlock {
                (task: BFTask!) -> AnyObject! in
                
                self.tableView.animateFadeIn()
                self.loadingView.stopAnimating()
                if task.result != nil {
                    self.dataSource = task.result as! [MALScrapper.Topic]
                }
                
                return nil
            }
        } else if let board = board {
            malScrapper.topicsFor(board: board).continueWithBlock {
                (task: BFTask!) -> AnyObject! in
                
                self.tableView.animateFadeIn()
                self.loadingView.stopAnimating()
                if task.result != nil {
                    self.dataSource = task.result as! [MALScrapper.Topic]
                }
                
                return nil
            }
        }
        
    }
    
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowTopic" {
            let destination = segue.destinationViewController as! TopicViewController
            let topic = sender as! MALScrapper.Topic
            destination.initWith(topic: topic, scrapper: malScrapper)
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
        let title = topic.title
        cell.typeLabel.text = topic.type == MALScrapper.TopicType.Sticky ? " " : ""
        cell.title.text = title
        cell.information.text = "\(topic.replies)  · \(topic.lastPost.date) by \(topic.lastPost.user)"
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