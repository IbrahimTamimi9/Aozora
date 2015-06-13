//
//  DiscussionViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/11/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANCommonKit
import ANParseKit
import Bolts

extension DiscussionViewController: StatusBarVisibilityProtocol {
    func shouldHideStatusBar() -> Bool {
        return false
    }
    func updateCanHideStatusBar(canHide: Bool) {
    }
}

public class DiscussionViewController: AnimeBaseViewController {
    
    var malScrapper: MALScrapper!
    var dataSource: [MALScrapper.Review] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 150.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        malScrapper = MALScrapper(viewController: self)
        malScrapper.reviewsFor(anime: anime).continueWithBlock {
            (task: BFTask!) -> AnyObject! in
            
            if task.result != nil {
                self.dataSource = task.result as! [MALScrapper.Review]
            }
            return nil
        }
    }
}

extension DiscussionViewController: UITableViewDataSource {
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return dataSource.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ReviewCell") as! ReviewCell
        
        let review = dataSource[indexPath.row]
        cell.reviewerLabel.text = review.username
        cell.reviewerAvatar.setImageFrom(urlString: review.avatarUrl)
        cell.reviewerOverallScoreLabel.text = "Rated \(review.rating.description) our of 10"
        cell.reviewerReviewLabel.text = "\(review.review)..."
        cell.reviewStatisticsLabel.text = review.helpful
        cell.layoutIfNeeded()
        return cell
    }
    
}

extension DiscussionViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let reviewCell = tableView.cellForRowAtIndexPath(indexPath) as! ReviewCell
        
        reviewCell.reviewerReviewLabel.numberOfLines = reviewCell.reviewerReviewLabel.numberOfLines == 4 ? 0 : 4
        tableView.reloadData()
        if reviewCell.reviewerReviewLabel.numberOfLines == 4 {
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        }

    }
}