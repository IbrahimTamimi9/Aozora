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
import ANCommonKit
import Parse
import Bolts

class AiringViewController: BaseViewController {
    
    var weekdayStrings: [String] = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentOrder = OrderBy.NextAiringEpisode
        navigationBarTitle.text = "Airing"
        fetchAiring()
    }
    
    func fetchAiring() {
        
        animateCollectionViewFadeOut()
        
        let query = Anime.query()!
        query.whereKeyExists("startDateTime")
        query.whereKey("status", equalTo: "currently airing")
        query.findObjectsInBackground().continueWithBlock {
            (task: BFTask!) -> AnyObject! in
            
            if let result = task.result as? [Anime] {
                
                var animeByWeekday: [[Anime]] = [[],[],[],[],[],[],[]]
                
                let calendar = NSCalendar.currentCalendar()
                let unitFlags: NSCalendarUnit = NSCalendarUnit.CalendarUnitWeekday
                
                var todayWeekday = calendar.components(unitFlags, fromDate: NSDate()).weekday
                
                for anime in result {
                    if let startDateTime = anime.startDateTime {
                        let dateComponents = calendar.components(unitFlags, fromDate: startDateTime)
                        let weekday = dateComponents.weekday-1
                        animeByWeekday[weekday].append(anime)
                    }
                }
                
                todayWeekday -= 1
                while (todayWeekday > 0) {
                    var currentFirstWeekdays = animeByWeekday[0]
                    animeByWeekday.removeAtIndex(0)
                    animeByWeekday.append(currentFirstWeekdays)
                    
                    var weekdayString = self.weekdayStrings[0]
                    self.weekdayStrings.removeAtIndex(0)
                    self.weekdayStrings.append(weekdayString)
                    
                    todayWeekday -= 1
                }
                
                self.dataSource = animeByWeekday
                self.order(by: self.currentOrder)
            }
            
            self.animateCollectionViewFadeIn()
            return nil;
        }
    }
    
}

extension AiringViewController: UICollectionViewDataSource {
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableView: UICollectionReusableView!
        
        if kind == UICollectionElementKindSectionHeader {
            
            var headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! BasicCollectionReusableView
            
            headerView.titleLabel.text = weekdayStrings[indexPath.section]
            reusableView = headerView;
        }
        
        return reusableView
    }
    
}