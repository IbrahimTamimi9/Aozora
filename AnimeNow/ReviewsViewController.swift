//
//  ReviewsViewController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 1/10/16.
//  Copyright © 2016 AnyTap. All rights reserved.
//

import Foundation
import ANParseKit

extension ReviewsViewController: StatusBarVisibilityProtocol {
    func shouldHideStatusBar() -> Bool {
        return false
    }
    func updateCanHideStatusBar(canHide: Bool) {
    }
}

// TODO: Refactor this 

extension ReviewsViewController: RequiresAnimeProtocol {
    func initWithAnime(anime: Anime) {
        self.anime = anime
    }
}

extension ReviewsViewController: CustomAnimatorProtocol {
    func scrollView() -> UIScrollView {
        return tableView
    }
}


class ReviewsViewController: ThreadViewController {
    
    var anime: Anime!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = tabBarController as? CustomTabBarController {
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "dismissViewControllerPressed")
            
            navigationController?.navigationBar.tintColor = UIColor.peterRiver()
            navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
            navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.blackColor()]
        }
        
        configureFetchController()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let tabBar = tabBarController as? CustomTabBarController {
            tabBar.setCurrentViewController(self)
        }
    }
    
    func configureFetchController() {
        fetchController.configureWith(self, queryDelegate: self, tableView: self.tableView, limit: self.FetchLimit, datasourceUsesSections: true)
    }
    
    // MARK: - FetchControllerQueryDelegate
    
    override func queriesForSkip(skip skip: Int) -> [PFQuery]? {
        
        let innerQuery = Review.query()!
        innerQuery.skip = skip
        innerQuery.limit = FetchLimit
        
        // 'Feed' query
        let query = innerQuery.copy() as! PFQuery
        query.includeKey("anime")
        query.includeKey("postedBy")
        
        return [query]
    }
    
    // MARK: - IBAction
    
    @IBAction func createReviewPressed(sender: AnyObject) {
        
    }
}