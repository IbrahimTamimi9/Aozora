//
//  ChartViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/4/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANParseKit
import SDWebImage
import ANCommonKit

class ArchiveViewController: UIViewController {
    
    let HeaderCellHeight: CGFloat = 44.0
    
    var showTableView = true
    
    var dataSource: [SeasonalChart] = [] {
        didSet {
            filteredDataSource = dataSource
        }
    }
    
    var filteredDataSource: [SeasonalChart] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    // TODO: create loading view from code, generalize to be used on UICollectionViews
    @IBOutlet weak var loadingView: LoaderView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.hidesBarsOnTap = false
        
        collectionView.alpha = 0.0
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: view.bounds.size.width, height: 36)
        
        fetchAllSeasons()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        animateCollectionViewFadeIn()
    }
    
    // MARK: - Internal functions
    
    func fetchAllSeasons() {
        animateCollectionViewFadeOut()
        
        let query = SeasonalChart.query()!
        query.limit = 200
        query.whereKey("startDate", lessThan: NSDate())
        query.orderByDescending("startDate")
        query.findObjectsInBackground().continueWithBlock {
            (task: BFTask!) -> AnyObject! in
            
            var seasons: [Int:[SeasonalChart]] = [:]
            var result = task.result as! [SeasonalChart]
            
            self.dataSource = result
            
            self.animateCollectionViewFadeIn()
            return nil;
        }
    }
    
    // MARK: - UI Functions
    
    func animateCollectionViewFadeIn() {
        
        loadingView.stopAnimating()
        collectionView.alpha = 0.0
        collectionView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7)
        
        UIView.animateWithDuration(0.8, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options:UIViewAnimationOptions.AllowUserInteraction|UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.collectionView.alpha = 1.0
            self.collectionView.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
    
    func animateCollectionViewFadeOut() {
        
        loadingView.startAnimating()
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.collectionView.alpha = 0.0
            self.collectionView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7)
            }, completion: nil)
    }
    
}

extension ArchiveViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredDataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let reuseIdentifier = "SeasonCell";
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! BasicCollectionCell
        
        let seasonalChart = filteredDataSource[indexPath.row]
        cell.titleLabel.text = seasonalChart.title
        cell.layoutIfNeeded()
        return cell
    }
    
}

extension ArchiveViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        tabBarController?.selectedIndex = 0
        
        let seasonalChart = filteredDataSource[indexPath.row]
        
        let chartNavController = tabBarController?.viewControllers?.first as! UINavigationController
        let chartVC = chartNavController.viewControllers.first as! ChartViewController
        chartVC.fetchSeasonalChart(seasonalChart.title)
    }
}
