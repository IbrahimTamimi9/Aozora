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
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            
            self.loadingView.stopAnimating()
            self.tableView.animateFadeIn()
            if let error = error {
                // TODO: Show error
            } else if let result = result as? [Thread] {
                self.dataSource = result
            }
        }
    }
    
}

extension ForumsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TopicCell") as! TopicCell
        
        let thread = dataSource[indexPath.row]
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

    }
}