//
//  SeasonalChartWorker.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 5/23/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Parse
import Bolts

public enum SeasonalChart: String {
    case Winter = "Winter"
    case Summer = "Summer"
    case Spring = "Spring"
    case Fall = "Fall"
}

public class SeasonalChartService {
    public class func currentSeasonalChart() -> BFTask {
        let query = PFQuery(className: ParseKit.SeasonalChart)
        query.limit = 1
        query.orderByDescending("startDate")
        query.includeKey("")
        return query
            .findObjectsInBackground()
            .continueWithBlock { (task: BFTask!) -> BFTask! in
            return task
        }
    }
    
    // MARK: - Current season anime
    
    public class func currentSeasonAnime() -> BFTask {
        return PFQuery(className: ParseKit.Anime)
            .includeKey("tvAnime")
            .includeKey("movieAnime")
            .includeKey("ovaAnime")
            .includeKey("onaAnime")
            .includeKey("movieAnime")
        .findObjectsInBackground()
    }
    
    // MARK: - Set anime to chart
    
    public class func fillChartWithAnime(chart: SeasonalChart, year: Int) -> BFTask {
        return PFQuery(className: ParseKit.SeasonalChart)
        .whereKey("title", equalTo: "\(chart.rawValue) \(year)")
        .findObjectsInBackground()
        .continueWithBlock { (task: BFTask!) -> BFTask! in
            let season = (task.result as! [PFObject]).last!
            
            return AnimeService
                .findAnimeForSeasonalChart(season)
                .continueWithBlock({ (task: BFTask!) -> BFTask! in
                
                    if let result = task.result as? [PFObject] {
                        var tvAnime: [PFObject] = []
                        var movieAnime: [PFObject] = []
                        var specialAnime: [PFObject] = []
                        var ovaAnime: [PFObject] = []
                        var onaAnime: [PFObject] = []
                        
                        for anime in result {
                            let type = anime["type"] as! String
                            switch type {
                                case "TV": tvAnime.append(anime)
                                case "Movie": movieAnime.append(anime)
                                case "Special": specialAnime.append(anime)
                                case "OVA": ovaAnime.append(anime)
                                case "ONA": onaAnime.append(anime)
                                default: ()
                            }
                        }
                        season.addUniqueObjectsFromArray(tvAnime, forKey: "tvAnime")
                        season.addUniqueObjectsFromArray(movieAnime, forKey: "movieAnime")
                        season.addUniqueObjectsFromArray(ovaAnime, forKey: "ovaAnime")
                        season.addUniqueObjectsFromArray(onaAnime, forKey: "onaAnime")
                        season.addUniqueObjectsFromArray(specialAnime, forKey: "specialAnime")
                    }
                    
                    return season.saveInBackground()
            })
        }
    }
    
    // MARK: - Charts generation
    
    public class func generateSeasonalCharts() {
        var seasons: [SeasonalChart] = [.Winter, .Summer, .Spring, .Fall]
        
        for var year = 1990; year < 2015; year++ {
            for seasonEnum in seasons {
                var season = PFObject(className: ParseKit.SeasonalChart)
                season["title"] = "\(seasonEnum.rawValue) \(year)"
                season["startDate"] = startDateForSeason(seasonEnum, year: year)
                season["endDate"] = endDateForSeason(seasonEnum, year: year)
                
                season.saveInBackground()
            }
        }
    }
    
    class func startDateForSeason(season: SeasonalChart, year: Int) -> NSDate {
        let components = NSDateComponents()
        components.day = 1
        switch (season) {
        case .Winter:
            components.month = 1
        case .Spring:
            components.month = 4
        case .Summer:
            components.month = 7
        case .Fall:
            components.month = 10
        }
        components.year = year
        
        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone(name: "UTC")!
        
        return calendar.dateFromComponents(components)!
    }
    
    class func endDateForSeason(season: SeasonalChart, year: Int) -> NSDate {
        let components = NSDateComponents()
        
        switch (season) {
        case .Winter:
            components.month = 3
            components.day = 31
        case .Spring:
            components.month = 6
            components.day = 30
        case .Summer:
            components.month = 9
            components.day = 30
        case .Fall:
            components.month = 12
            components.day = 31
        }
        components.year = year
        
        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone(name: "UTC")!
        
        return calendar.dateFromComponents(components)!
    }
    

}