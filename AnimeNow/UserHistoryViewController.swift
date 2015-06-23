//
//  UserHistoryViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/22/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import Alamofire
import Bolts
import ANCommonKit

class UserHistoryViewController: UserBaseViewController {
    
    class HistoryItem {
        var id: Int = 0
        var title: String = ""
        var episodes: Int = 0
        var type: String = ""
        var updatedAt: NSDate = NSDate()
    }
    
    var dataSource: [HistoryItem] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension         
        
        userHistory().continueWithBlock
        { (task: BFTask!) -> AnyObject! in
            
            if let result = task.result as? [[String: AnyObject]] {
                
                var history: [HistoryItem] = []
                for historyItem in result {
                    
                    var item = HistoryItem()
                    let itemInfo = historyItem["item"] as! [String: AnyObject]
                    item.id = itemInfo["id"] as! Int
                    item.title = itemInfo["title"] as! String
                    item.episodes = itemInfo["episodes"] as! Int
                    item.type = historyItem["type"] as! String
                    item.updatedAt = (historyItem["time_updated"] as! String).dateWithISO8601()!
                    
                    history.append(item)
                }
                
                self.dataSource = history
            }
            
            return nil
        }
    }
    
    
    func userHistory() -> BFTask! {
        let completionSource = BFTaskCompletionSource()
        Alamofire.request(Atarashii.Router.history(username: username)).validate().responseJSON { (req, res, JSON, error) -> Void in
            if error == nil {
                completionSource.setResult(JSON)
            } else {
                completionSource.setError(error)
            }
        }
        return completionSource.task
    }
}


extension UserHistoryViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("InformationCell") as! BasicTableCell
        let historyItem = dataSource[indexPath.row]
        cell.titleLabel.text = historyItem.title
        cell.subtitleLabel.text = "Ep. " + historyItem.episodes.description
        cell.detailLabel.text = historyItem.type
        cell.detailSubtitleLabel.text = historyItem.updatedAt.daysAgo().description + " days ago"
        
        cell.layoutIfNeeded()
        return cell
        
    }
    
}

extension UserHistoryViewController: UITableViewDelegate {
    
}

