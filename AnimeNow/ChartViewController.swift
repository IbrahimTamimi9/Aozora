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
import Alamofire

class ChartViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentOrder = .Rating
        
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "changeSeasonalChart")
        navigationController?.navigationBar.addGestureRecognizer(tapGestureRecognizer)
        
        fetchSeasonalChart("Spring 2015")
    }
    
    func fetchSeasonalChart(seasonalChart: String) {
        
        navigationBarTitle.text = seasonalChart.stringByAppendingString(" "+angleDownIcon)
        
        
        animateCollectionViewFadeOut()
        
        let currentChartQuery = SeasonalChart.query()!
        currentChartQuery.limit = 1
        currentChartQuery.whereKey("title", equalTo:seasonalChart)
        currentChartQuery.includeKey("tvAnime")
        currentChartQuery.includeKey("leftOvers")
        currentChartQuery.includeKey("movieAnime")
        currentChartQuery.includeKey("ovaAnime")
        currentChartQuery.includeKey("onaAnime")
        currentChartQuery.includeKey("specialAnime")
        currentChartQuery.findObjectsInBackground().continueWithBlock {
            (task: BFTask!) -> AnyObject! in
            if let result = task.result as? [SeasonalChart], let season = result.last {
                
                self.dataSource = [season.tvAnime, season.movieAnime, season.ovaAnime, season.onaAnime, season.specialAnime]
                self.order(by: self.currentOrder)
                
                
            }
            
            self.animateCollectionViewFadeIn()
            
            
            return nil;
        }
    }
    
    func changeSeasonalChart() {
        if let bar = navigationController?.navigationBar {
            showDropDownController(bar, dataSource: ["Winter 2015","Spring 2015","Summer 2015","Fall 2015"], imageDataSource: ["icon-winter","icon-spring","icon-summer","icon-fall"])
        }
    }
    
}

extension ChartViewController: UICollectionViewDataSource {
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableView: UICollectionReusableView!
        
        if kind == UICollectionElementKindSectionHeader {
            
            var headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! BasicCollectionReusableView
            
            var title = ""
            switch indexPath.section {
                case 0: title = "TV"
                case 1: title = "Movies"
                case 2: title = "OVAs"
                case 3: title = "ONAs"
                case 4: title = "Specials"
                default: break
            }
            
            headerView.titleLabel.text = title
            
            reusableView = headerView;
        }
        
        return reusableView
    }
    
}

extension ChartViewController: DropDownListDelegate {
    override func selectedAction(trigger: UIView, action: String) {
        super.selectedAction(trigger, action: action)
        
        if trigger.isEqual(navigationController?.navigationBar) {
            fetchSeasonalChart(action)
        }
    }
}