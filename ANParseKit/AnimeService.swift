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
    
    static public func allRawValues() -> [String] {
        return [AnimeType.TV.rawValue, AnimeType.Movie.rawValue, AnimeType.Special.rawValue, AnimeType.OVA.rawValue, AnimeType.ONA.rawValue, AnimeType.Music.rawValue]
    }
}

public enum AnimeClassification: String {
    case G = "G - All Ages"
    case PG = "PG - Children"
    case PG13 = "PG-13 - Teens 13 or older"
    case R17 = "R - 17+ (violence & profanity)"
    case RPlus = "R+ - Mild Nudity"
    
    static func count() -> Int {
        return 5
    }
    
    static public func allRawValues() -> [String] {
        return [AnimeClassification.G.rawValue, AnimeClassification.PG.rawValue, AnimeClassification.PG13.rawValue, AnimeClassification.R17.rawValue, AnimeClassification.RPlus.rawValue]
    }
}

public enum AnimeStatus: String {
    case FinishedAiring = "finished airing"
    case CurrentlyAiring = "currently airing"
    case NotYetAired = "not yet aired"
    
    static func count() -> Int {
        return 3
    }
    
    static public  func allRawValues() -> [String] {
        return [AnimeStatus.FinishedAiring.rawValue, AnimeStatus.CurrentlyAiring.rawValue, AnimeStatus.NotYetAired.rawValue]
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
    
    static public func allRawValues() -> [String] {
        return [AnimeGenre.Action.rawValue, AnimeGenre.Adventure.rawValue, AnimeGenre.Cars.rawValue, AnimeGenre.Comedy.rawValue, AnimeGenre.Dementia.rawValue, AnimeGenre.Demons.rawValue, AnimeGenre.Drama.rawValue, AnimeGenre.Ecchi.rawValue, AnimeGenre.Fantasy.rawValue, AnimeGenre.Game.rawValue, AnimeGenre.Harem.rawValue, AnimeGenre.Historical.rawValue, AnimeGenre.Horror.rawValue, AnimeGenre.Josei.rawValue, AnimeGenre.Kids.rawValue, AnimeGenre.Magic.rawValue, AnimeGenre.MartialArts.rawValue, AnimeGenre.Mecha.rawValue, AnimeGenre.Military.rawValue, AnimeGenre.Music.rawValue, AnimeGenre.Mystery.rawValue, AnimeGenre.Parody.rawValue, AnimeGenre.Police.rawValue, AnimeGenre.Psychological.rawValue, AnimeGenre.Romance.rawValue, AnimeGenre.Samurai.rawValue, AnimeGenre.School.rawValue, AnimeGenre.SciFi.rawValue, AnimeGenre.Seinen.rawValue, AnimeGenre.Shoujo.rawValue, AnimeGenre.ShoujoAi.rawValue, AnimeGenre.Shounen.rawValue, AnimeGenre.ShounenAi.rawValue, AnimeGenre.SliceOfLife.rawValue, AnimeGenre.Space.rawValue, AnimeGenre.Sports.rawValue, AnimeGenre.SuperPower.rawValue, AnimeGenre.Supernatural.rawValue, AnimeGenre.Thriller.rawValue, AnimeGenre.Vampire.rawValue, AnimeGenre.Yaoi.rawValue, AnimeGenre.Yuri.rawValue]
    }
}

public enum AnimeSort: String {
    case AZ = "A-Z"
    case Popular = "Most Popular"
    case Rating = "Highest Rated"
}

public class AnimeService {

    public class func findAllAnime() -> BFTask {
        
        let query = PFQuery(className: ParseKit.Anime)
        query.limit = 1000
        query.skip = 0
        
        return findAllObjectsWith(query: query)
    }
    
    public class func findAllObjectsWith(query query: PFQuery, skip: Int? = 0) -> BFTask {
        query.limit = 1000
        query.skip = skip!
        
        return query
            .findObjectsInBackground()
            .continueWithBlock { (task: BFTask!) -> BFTask! in
            
            let result = task.result as! [PFObject]
                
                if result.count == query.limit {
                    return self.findAllObjectsWith(query: query, skip:query.skip + query.limit)
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
            query2.whereKey("type", notEqualTo: "TV")
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