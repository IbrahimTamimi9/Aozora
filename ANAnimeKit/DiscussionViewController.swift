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

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "ReviewDetails" {
            if
                let controller = segue.destinationViewController as? ReviewViewController,
                let indexPath = sender as? NSIndexPath {
                    let review = anime.reviews.reviewFor(index: indexPath.row)
                    controller.initWithReview(review)
            }
        }
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
        cell.reviewStatisticsLabel.text = animeReview.helpfulString()
        cell.layoutIfNeeded()
        return cell
    }
    
}

extension DiscussionViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("ReviewDetails", sender: indexPath)
        if let tabBar = tabBarController as? CustomTabBarController {
            tabBar.disableDragDismiss()
        }

    }
}