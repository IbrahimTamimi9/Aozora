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

extension DiscussionViewController: StatusBarVisibilityProtocol {
    func shouldHideStatusBar() -> Bool {
        return false
    }
    func updateCanHideStatusBar(canHide: Bool) {
    }
}

public class DiscussionViewController: AnimeBaseViewController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 150.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }

}

extension DiscussionViewController: UITableViewDataSource {
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows = anime.reviews.reviews.count
        return numberOfRows
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ReviewCell") as! ReviewCell
        
        let animeReview = anime.reviews.reviewFor(index: indexPath.row)
        cell.reviewerLabel.text = animeReview.username
        cell.reviewerAvatar.setImageFrom(urlString: animeReview.avatarUrl)
        cell.reviewerOverallScoreLabel.text = animeReview.rating.description
        cell.reviewerReviewLabel.text = "\(animeReview.review)..."
        let percentageString = String(format: "%.0f%%",Double(animeReview.helpful)*100.0 / Double(animeReview.helpfulTotal))
        cell.reviewStatisticsLabel.text = "\(percentageString) of \(animeReview.helpfulTotal) people found this review helpful"
        cell.layoutIfNeeded()
        return cell
    }
    
}

extension DiscussionViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

    }
}