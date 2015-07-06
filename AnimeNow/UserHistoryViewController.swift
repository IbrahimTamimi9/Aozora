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
                    if let itemInfo = historyItem["item"] as? [String: AnyObject],
                        let id = itemInfo["id"] as? Int,
                        let title = itemInfo["title"] as? String,
                        let episodes = itemInfo["episodes"] as? Int,
                        let type = historyItem["type"] as? String,
                        let timeUpdated = historyItem["time_updated"] as? String {
                            item.id = id
                            item.title = title
                            item.episodes = episodes
                            item.type = type
                            if let updatedAt = timeUpdated.dateWithISO8601() ?? timeUpdated.dateWithISO8601NoMinutes() {
                                item.updatedAt = updatedAt
                            }
                            history.append(item)
                    }
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
        cell.detailSubtitleLabel.text = historyItem.updatedAt.timeAgo()
        
        cell.layoutIfNeeded()
        return cell
        
    }
    
}

extension UserHistoryViewController: UITableViewDelegate {
    
}

