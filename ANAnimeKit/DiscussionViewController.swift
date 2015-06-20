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
    
    var expandedIndexPath: NSIndexPath?
    
    var canFadeInImages = true
    var loadingView: LoaderView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 150.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        loadingView = LoaderView(viewController: self)
        malScrapper = MALScrapper(viewController: self)
        
        loadingView.startAnimating()
        malScrapper.reviewsFor(anime: anime).continueWithBlock {
            (task: BFTask!) -> AnyObject! in
            
            self.tableView.animateFadeIn()
            self.loadingView.stopAnimating()
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
        cell.reviewerAvatar.setImageFrom(urlString: review.avatarUrl, animated: canFadeInImages)
        cell.reviewerOverallScoreLabel.text = "Rated \(review.rating.description) our of 10"
        cell.reviewerReviewLabel.text = "\(review.review)..."
        cell.reviewStatisticsLabel.text = review.helpful
        
        if expandedIndexPath?.row == indexPath.row {
            cell.reviewerReviewLabel.numberOfLines = 0
        } else {
            cell.reviewerReviewLabel.numberOfLines = 4
        }
        cell.layoutIfNeeded()
        return cell
    }
    
}

extension DiscussionViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let reviewCell = tableView.cellForRowAtIndexPath(indexPath) as! ReviewCell
        let cellIsContracted = reviewCell.reviewerReviewLabel.numberOfLines == 4
        
        reviewCell.reviewerReviewLabel.numberOfLines = cellIsContracted ? 0 : 4
        expandedIndexPath = cellIsContracted ? indexPath : nil
        
        canFadeInImages = false
        tableView.reloadData()
        tableView.layoutIfNeeded()
        canFadeInImages = true
        if reviewCell.reviewerReviewLabel.numberOfLines == 4 {
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        }

    }
}