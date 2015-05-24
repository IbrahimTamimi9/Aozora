//
//  AnimeService.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 5/23/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Parse
import Bolts

public class AnimeService {

    public class func allAnime() -> BFTask {
        return findAnimeWithSkip(0)
    }
    
    class func findAnimeWithSkip(skip: Int) -> BFTask {
        let limitSize = 1000
        let query = PFQuery(className: ParseKit.Anime)
        query.limit = limitSize
        query.skip = skip
        return query
            .selectKeys(["endDate2"])
            .findObjectsInBackground()
            .continueWithBlock { (task: BFTask!) -> BFTask! in
            
            let result = task.result as! [PFObject]
                
                if result.count == limitSize {
                    return self.findAnimeWithSkip(skip + limitSize)
                        .continueWithBlock({ (previousTask: BFTask!) -> AnyObject! in
                        let previousResults = previousTask.result as! [PFObject]
                        return BFTask(result: previousResults+result)
                    })
                } else {
                    return task
                }
        }
    }
    
    public class func findAnimeBetterHigherThanNine() -> BFTask {

        let innerQuery = PFQuery(className: ParseKit.AnimeStatistics)
        innerQuery.whereKey("membersScore", greaterThan: 9.0)
        
        return PFQuery(className: ParseKit.Anime)
        .whereKey("statistics", matchesQuery: innerQuery)
        .includeKey("statistics")
        .findObjectsInBackground()
        .continueWithBlock { (task: BFTask!) -> BFTask! in
            
            return task
        }
    }
    
    public class func findAnimeForSeasonalChart(season: PFObject) -> BFTask {
        if let startDate = season["startDate"] as? NSDate,
        let endDate = season["endDate"] as? NSDate {
            
            let query = PFQuery(className: ParseKit.Anime)
            query.whereKey("startDate2", greaterThanOrEqualTo: startDate)
            query.whereKey("startDate2", lessThanOrEqualTo: endDate)
            
            let query2 = PFQuery(className: ParseKit.Anime)
            query.whereKey("endDate2", greaterThanOrEqualTo: startDate)
            query.whereKey("endDate2", lessThanOrEqualTo: endDate)
            
            return PFQuery
                .orQueryWithSubqueries([query,query2])
                .findObjectsInBackground()
        }
        return BFTask(result: [])
    }
    
}