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



public enum AnimeType: String {
    case TV = "TV"
    case Movie = "Movie"
    case Special = "Special"
    case OVA = "OVA"
    case ONA = "ONA"
    case Music = "Music"
    
    static func count() -> Int {
        return 6
    }
}

public enum AnimeClassification: String {
    case G = "G - All Ages"
    case PG = "PG - Children"
    case PG13 = "PG-13 - Teens 13 or older"
    case R17 = "R - 17+ (violence & profanity)"
    case RPlus = "R+ - Mild Nudity"
    case Rx = "Rx - Hentai"
    
    static func count() -> Int {
        return 6
    }
}

public enum AnimeStatus: String {
    case FinishedAiring = "finished airing"
    case CurrentlyAiring = "currently airing"
    case NotYetAired = "not yet aired"
    
    static func count() -> Int {
        return 3
    }
}

public enum AnimeGenre: String {
    case Action = "Action"
    case Adventure = "Adventure"
    case Cars = "Cars"
    case Comedy = "Comedy"
    case Dementia = "Dementia"
    case Demons = "Demons"
    case Drama = "Drama"
    case Ecchi = "Ecchi"
    case Fantasy = "Fantasy"
    case Game = "Game"
    case Harem = "Harem"
    case Hentai = "Hentai"
    case Historical = "Historical"
    case Horror = "Horror"
    case Josei = "Josei"
    case Kids = "Kids"
    case Magic = "Magic"
    case MartialArts = "Martial Arts"
    case Mecha = "Mecha"
    case Military = "Military"
    case Music = "Music"
    case Mystery = "Mystery"
    case Parody = "Parody"
    case Police = "Police"
    case Psychological = "Psychological"
    case Romance = "Romance"
    case Samurai = "Samurai"
    case School = "School"
    case SciFi = "Sci-Fi"
    case Seinen = "Seinen"
    case Shoujo = "Shoujo"
    case ShoujoAi = "Shoujo Ai"
    case Shounen = "Shounen"
    case ShounenAi = "Shounen Ai"
    case SliceOfLife = "Slice of Life"
    case Space = "Space"
    case Sports = "Sports"
    case SuperPower = "Super Power"
    case Supernatural = "Supernatural"
    case Thriller = "Thriller"
    case Vampire = "Vampire"
    case Yaoi = "Yaoi"
    case Yuri = "Yuri"
    
    static func count() -> Int {
        return 43
    }
}

public enum AnimeSort: String {
    case AZ = "A-Z"
    case Popular = "Most Popular"
    case Rating = "Highest Rated"
}

public class AnimeService {

    public class func findAllAnime() -> BFTask {
        return findAnimeWithSkip(0)
    }
    
    class func findAnimeWithSkip(skip: Int) -> BFTask {
        let limitSize = 1000
        let query = PFQuery(className: ParseKit.Anime)
        query.limit = limitSize
        query.skip = skip
        return query
//            .whereKey("myAnimeListID", equalTo: 11783)
//            .includeKey("statistics")
//            .whereKeyDoesNotExist("details")
            .selectKeys(["startDate","endDate"])
//            .whereKey("type", equalTo: "TV")
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
    
    public class func findAnimeForSeasonalChart(season: PFObject) -> BFTask {
        if let startDate = season["startDate"] as? NSDate,
        let endDate = season["endDate"] as? NSDate {
            
            let query = PFQuery(className: ParseKit.Anime)
            query.whereKey("startDate", greaterThanOrEqualTo: startDate)
            query.whereKey("startDate", lessThanOrEqualTo: endDate)
            
            let query2 = PFQuery(className: ParseKit.Anime)
            query2.whereKey("endDate", greaterThanOrEqualTo: startDate)
            query2.whereKey("endDate", lessThanOrEqualTo: endDate)
            
            return PFQuery
                .orQueryWithSubqueries([query,query2])
                .findObjectsInBackground()
        }
        return BFTask(result: [])
    }
    
    public class func findAnime(sort: AnimeSort? = .AZ, years: [Int]? = [], genres: [AnimeGenre]? = [], types: [AnimeType]? = [], classification: [AnimeClassification]? = [], status: [AnimeStatus]? = [] , includeClasses: [String]? = [] , limit: Int? = 1000) -> BFTask {
        let query = PFQuery(className: ParseKit.Anime)
        
        query.limit = limit!
        
        switch sort! {
            case .AZ: query.orderByAscending("title")
            case .Popular: query.orderByDescending("popularityRank")
            case .Rating: query.orderByDescending("rank")
        }
        
        if let years = years where years.count != 0 {
            
            var includeYears: [Int] = []
            for year in years {
                includeYears.append(year)
            }
            query.whereKey("year", containedIn: includeYears)
        }
        
        if let genres = genres where genres.count != AnimeGenre.count() && genres.count != 0 {
            var includeGenres: [String] = []
            for genre in genres {
                includeGenres.append(genre.rawValue)
            }
            query.whereKey("genres", containsAllObjectsInArray: includeGenres)
        }
        
        
        if let types = types where types.count != AnimeType.count() && types.count != 0  {
            var includeTypes: [String] = []
            for type in types {
                includeTypes.append(type.rawValue)
            }
            query.whereKey("type", containedIn: includeTypes)
        }
        
        if let classification = classification where classification.count != AnimeClassification.count() && classification.count != 0  {
            var includeClassifications: [String] = []
            for aClassification in classification {
                includeClassifications.append(aClassification.rawValue)
            }
            let innerQuery = PFQuery(className: ParseKit.AnimeDetail)
            innerQuery.whereKey("classification", containedIn: includeClassifications)
            query.whereKey("details", matchesQuery: innerQuery)
        }
        
        if let status = status where status.count != AnimeStatus.count() && status.count != 0  {
            var includeStatus: [String] = []
            for aStatus in status {
                includeStatus.append(aStatus.rawValue)
            }
            query.whereKey("status", containedIn: includeStatus)
        }
        
        return query.findObjectsInBackground()
        
    }
    
}