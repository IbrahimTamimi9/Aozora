//
//  ChartController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/12/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import ANParseKit

class ChartController {
    
    class func fetchSeasonalChartAnime(seasonalChart: SeasonalChart) -> BFTask {
        let query = Anime.query()!
        query.limit = 1000
        query.whereKey("startDate", greaterThanOrEqualTo: seasonalChart.startDate)
        query.whereKey("startDate", lessThanOrEqualTo: seasonalChart.endDate)
        query.whereKey("genres", notContainedIn: ["Hentai"])
        
        let currentSeasonalChart = SeasonalChartService.seasonalChartString(0).title
        if currentSeasonalChart == seasonalChart.title {
            // Cached
            return query.findCachedOrNetwork("LocalDatastore.Anime", expirationDays: 1)
        } else {
            return query.findObjectsInBackground()
        }
    }
    
    class func fetchAllSeasons() -> BFTask {
        
        let query = SeasonalChart.query()!
        query.limit = 1000
        query.orderByDescending("startDate")
        
        return query.findCachedOrNetwork("LocalDatastore.AllSeasons", expirationDays: 1)
    }
}

