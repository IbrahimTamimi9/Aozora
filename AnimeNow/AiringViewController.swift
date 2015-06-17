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
    
    var weekdayStrings: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentOrder = OrderBy.NextAiringEpisode
        currentViewType = ViewType.Poster
        setViewType(currentViewType)
        
        navigationBarTitle.text = "Airing"
        fetchAiring()
    }
    
    func fetchAiring() {
        
        collectionView.animateFadeOut()
        
        let query = Anime.query()!
        query.whereKeyExists("startDateTime")
        query.whereKey("status", equalTo: "currently airing")
        query.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
            
            if let result = result as? [Anime] {
            
            var animeByWeekday: [[Anime]] = [[],[],[],[],[],[],[]]
            
            let calendar = NSCalendar.currentCalendar()
            let unitFlags: NSCalendarUnit = NSCalendarUnit.CalendarUnitWeekday
            
            for anime in result {
                let startDateTime = anime.nextEpisodeDate
                let dateComponents = calendar.components(unitFlags, fromDate: startDateTime)
                let weekday = dateComponents.weekday-1
                animeByWeekday[weekday].append(anime)
                
            }
            
            var todayWeekday = calendar.components(unitFlags, fromDate: NSDate()).weekday - 1
            while (todayWeekday > 0) {
                var currentFirstWeekdays = animeByWeekday[0]
                animeByWeekday.removeAtIndex(0)
                animeByWeekday.append(currentFirstWeekdays)
                todayWeekday -= 1
            }
            
            // Set weekday strings
            
            let today = NSDate()
            let unitFlags2: NSCalendarUnit = NSCalendarUnit.CalendarUnitWeekday | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "eeee, MMM dd"
            for daysAhead in 0..<7 {
                let date = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitDay, value: daysAhead, toDate: today, options: nil)
                let dateString = dateFormatter.stringFromDate(date!)
                self.weekdayStrings.append(dateString)
            }
            
            self.dataSource = animeByWeekday
            self.order(by: self.currentOrder)
                
            }
            
            self.loadingView.stopAnimating()
            self.collectionView.animateFadeIn()
        })
        

        
    }
    
    
    override func order(#by: OrderBy) {
        
        currentOrder = by
        orderTitleLabel.text = currentOrder.rawValue
        let today = NSDate()
        var index = 0
        dataSource = dataSource.map() { (var animeArray) -> [Anime] in
            switch self.currentOrder {
            case .Rating:
                animeArray.sort({ $0.rank < $1.rank})
            case .Popularity:
                animeArray.sort({ $0.popularityRank < $1.popularityRank})
            case .Title:
                animeArray.sort({ $0.title < $1.title})
            case .NextAiringEpisode:
                if index == 0 {
                    animeArray.sort({ (anime1: Anime, anime2: Anime) in
                        let anime1IsToday = anime1.nextEpisodeDate.timeIntervalSinceDate(today) < 60*60*24
                        let anime2IsToday = anime2.nextEpisodeDate.timeIntervalSinceDate(today) < 60*60*24
                        if anime1IsToday && anime2IsToday {
                            return anime1.nextEpisodeDate.compare(anime2.nextEpisodeDate) == .OrderedAscending
                        } else if !anime1IsToday && !anime2IsToday {
                            return anime1.nextEpisodeDate.compare(anime2.nextEpisodeDate) == .OrderedDescending
                        } else if anime1IsToday && !anime2IsToday {
                            return false
                        } else {
                            return true
                        }
                        
                    })
                } else {
                    animeArray.sort({ $0.nextEpisodeDate.compare($1.nextEpisodeDate) == .OrderedAscending })
                }
            }
            index += 1
            return animeArray
        }
        
        // Filter
        searchBar(searchBar, textDidChange: searchBar.text)
    }
    
}

extension AiringViewController: UICollectionViewDataSource {
    // TODO: Remove this duplicate code..
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var reuseIdentifier: String = ""
        
        switch currentViewType {
        case .Chart:
            reuseIdentifier = "AnimeCell"
        case .List:
            reuseIdentifier = "AnimeListCell"
        case .Poster:
            reuseIdentifier = "AnimeCellPoster"
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! AnimeCell
        
        let anime = filteredDataSource[indexPath.section][indexPath.row]
        
        cell.posterImageView?.setImageFrom(urlString: anime.imageUrl, animated: canFadeImages)
        cell.titleLabel.text = anime.title
        cell.genresLabel?.text = ", ".join(anime.genres)
        
        if let source = anime.source {
            cell.sourceLabel?.text = "Source: \(source)"
        } else {
            cell.sourceLabel?.text = ""
        }
        
        
        if let mainStudio = anime.studio.first {
            let studioString = mainStudio["studio_name"] as! String
            cell.studioLabel?.text = "\(studioString)"
        } else {
            cell.studioLabel?.text = ""
        }
        
        if var nextEpisode = anime.nextEpisode {
            let nextDate = anime.nextEpisodeDate
            
            if indexPath.section == 0 && nextDate.timeIntervalSinceNow > 60*60*24 {
                cell.etaLabel?.textColor = UIColor.pumpkin()
                cell.etaTimeLabel?.textColor = UIColor.pumpkin()
                cell.etaLabel?.text = "Episode \(nextEpisode-1) - Aired"
                cell.etaTimeLabel?.text = "Aired"
            } else {
                let (days, hours, minutes) = etaForDate(nextDate)
                let etaTime: String
                if days != 0 {
                    etaTime = "\(days)d \(hours)h \(minutes)m"
                    cell.etaLabel?.textColor = UIColor.belizeHole()
                    cell.etaTimeLabel?.textColor = UIColor.belizeHole()
                    cell.etaLabel?.text = "Episode \(nextEpisode) - " + etaTime
                } else if hours != 0 {
                    etaTime = "\(hours)h \(minutes)m"
                    cell.etaLabel?.textColor = UIColor.nephritis()
                    cell.etaTimeLabel?.textColor = UIColor.nephritis()
                    cell.etaLabel?.text = "Episode \(nextEpisode) - " + etaTime
                } else {
                    etaTime = "\(minutes)m"
                    cell.etaLabel?.textColor = UIColor.pumpkin()
                    cell.etaTimeLabel?.textColor = UIColor.pumpkin()
                    cell.etaLabel?.text = "Episode \(nextEpisode) - \(minutes)m"
                }
                
                cell.etaTimeLabel?.text = etaTime
            }
            
            cell.nextEpisodeNumberLabel?.text = nextEpisode.description
            
        } else {
            cell.etaLabel?.text = ""
        }
        
        
        
        cell.layoutIfNeeded()
        return cell
    }
    
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