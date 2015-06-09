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

class AiringViewController: BaseViewController {
    
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
                
                for anime in result {
                    if let startDateTime = anime.startDateTime {
                        let dateComponents = calendar.components(unitFlags, fromDate: startDateTime)
                        let weekday = dateComponents.weekday-1
                        animeByWeekday[weekday].append(anime)
                    }
                }
                
                var sunday = animeByWeekday[0]
                animeByWeekday.removeAtIndex(0)
                animeByWeekday.append(sunday)
                
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
            
            var title = ""
            switch indexPath.section {
            case 0: title = "Monday"
            case 1: title = "Tuesday"
            case 2: title = "Wednesday"
            case 3: title = "Thursday"
            case 4: title = "Friday"
            case 5: title = "Saturday"
            case 6: title = "Sunday"
            default: break
            }
            
            headerView.titleLabel.text = title
            
            reusableView = headerView;
        }
        
        return reusableView
    }
    
}