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

class ChartViewController: BaseViewController {
    
    var currentSeasonalChartName: String = "Spring 2015"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "changeSeasonalChart")
        navigationController?.navigationBar.addGestureRecognizer(tapGestureRecognizer)
        
        prepareForList(selectedList)
    }
    
    func prepareForList(selectedList: SelectedList) {
        
        self.selectedList = selectedList
        collectionView.animateFadeOut()
        loadingView.startAnimating()
        
        switch selectedList {
        case .SeasonalChart:
            navigationBarTitle.text = currentSeasonalChartName
            fetchSeasonalChart(currentSeasonalChartName)
        case .AllSeasons:
            navigationBarTitle.text = "All Seasons"
            fetchAllSeasons()
        case .Calendar:
            navigationBarTitle.text = "Calendar"
            fetchAiring()
        case .TBA:
            navigationBarTitle.text = "To Be Announced"
            fetchTBA()
        }
        
        navigationBarTitle.text! += " " + FontAwesome.AngleDown.rawValue
        setViewType(currentViewType)
    }
    
    func fetchSeasonalChart(seasonalChart: String) {
        
        let currentChartQuery = SeasonalChart.query()!
        currentChartQuery.limit = 1
        currentChartQuery.whereKey("title", equalTo:seasonalChart)
        currentChartQuery.includeKey("tvAnime")
        currentChartQuery.includeKey("leftOvers")
        currentChartQuery.includeKey("movieAnime")
        currentChartQuery.includeKey("ovaAnime")
        currentChartQuery.includeKey("onaAnime")
        currentChartQuery.includeKey("specialAnime")
        currentChartQuery.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
            if let result = result as? [SeasonalChart], let season = result.last {
                self.dataSource = [season.tvAnime, season.movieAnime, season.ovaAnime, season.onaAnime, season.specialAnime]
                self.order(by: self.currentOrder)
            }
            
            self.loadingView.stopAnimating()
            self.collectionView.animateFadeIn()
        })
    }
    
    func fetchAllSeasons() {
        
        let query = SeasonalChart.query()!
        query.limit = 200
        query.whereKey("startDate", lessThan: NSDate())
        query.orderByDescending("startDate")
        query.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
            
            var seasons: [Int:[SeasonalChart]] = [:]
            var result = result as! [SeasonalChart]
            
            self.chartsDataSource = result
            
            self.loadingView.stopAnimating()
            self.collectionView.animateFadeIn()
        })
        
        
    }
    
    func fetchAiring() {
        
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
    
    func fetchTBA() {
        
        let query = Anime.query()!
        query.whereKeyExists("startDate")
        query.whereKey("status", equalTo: "not yet aired")
        query.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
            if let result = result as? [Anime] {
                
                var animeByType: [[Anime]] = [[],[],[],[],[],[],[]]
                
                for anime in result {
                    var index = 0
                    switch anime.type {
                    case "TV": index = 0
                    case "Movie": index = 1
                    case "OVA": index = 2
                    case "ONA": index = 3
                    case "Special": index = 4
                    default: break;
                    }
                    animeByType[index].append(anime)
                }
                
                self.dataSource = animeByType
                self.order(by: self.currentOrder)
            }
            
            self.loadingView.stopAnimating()
            self.collectionView.animateFadeIn()
        })
        
        
    }
    
    
    func changeSeasonalChart() {
        if let sender = navigationController?.navigationBar,
            let viewController = tabBarController{
            let dataSource = [["Winter 2015","Spring 2015","Summer 2015","Fall 2015"],["All Seasons"]]
            let imageDataSource = [["icon-winter","icon-spring","icon-summer","icon-fall"],["icon-archived"]]
            
            DropDownListViewController.showDropDownListWith(sender: sender, viewController: viewController, delegate: self, dataSource: dataSource, imageDataSource: imageDataSource)
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

extension ChartViewController: UICollectionViewDelegate {
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        super.collectionView(collectionView, didSelectItemAtIndexPath: indexPath)
        
        if selectedList == SelectedList.AllSeasons {
            let seasonalChart = chartsDataSource[indexPath.row]
            currentSeasonalChartName = seasonalChart.title
            prepareForList(.SeasonalChart)
        }
    }
}



extension ChartViewController: DropDownListDelegate {
    override func selectedAction(trigger: UIView, action: String, indexPath: NSIndexPath) {
        super.selectedAction(trigger, action: action, indexPath: indexPath)
        
        if trigger.isEqual(navigationController?.navigationBar) {
            switch (indexPath.row, indexPath.section) {
            case (_, 0):
                currentSeasonalChartName = action
                prepareForList(.SeasonalChart)
            case (0,1):
                prepareForList(.AllSeasons)
            case (1,1):
                prepareForList(.Calendar)
            case (2,1):
                prepareForList(.TBA)
            default: break
            }
            
        }
    }
}