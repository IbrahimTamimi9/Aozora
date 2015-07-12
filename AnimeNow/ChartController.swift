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
    
    class func fetchSeasonalChart(seasonalChart: String) -> BFTask {
        let currentChartQuery = SeasonalChart.query()!
        currentChartQuery.limit = 1
        currentChartQuery.whereKey("title", equalTo:seasonalChart)
        currentChartQuery.includeKey("tvAnime")
        currentChartQuery.includeKey("leftOvers")
        currentChartQuery.includeKey("movieAnime")
        currentChartQuery.includeKey("ovaAnime")
        currentChartQuery.includeKey("onaAnime")
        currentChartQuery.includeKey("specialAnime")
        
        let currentSeasonalChart = SeasonalChartService.seasonalChartString(0).title
        if currentSeasonalChart == seasonalChart {
            // Cached
            return currentChartQuery.findCachedOrNetwork("LocalDataStore.CurrentChart", expirationDays: 1)
        } else {
            return currentChartQuery.findObjectsInBackground()
        }
    }
}

