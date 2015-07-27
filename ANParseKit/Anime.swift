//
//  Anime.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/11/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Bolts
import Parse
import ANCommonKit

public class Anime: PFObject, PFSubclassing {
    
    override public class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    public class func parseClassName() -> String {
        return "Anime"
    }
    
    @NSManaged public var rank: Int
    @NSManaged public var myAnimeListID: Int
    @NSManaged public var anilistID: Int
    @NSManaged public var tvdbID: Int
    @NSManaged public var traktID: Int
    @NSManaged public var traktSlug: String
    @NSManaged public var title: String?
    @NSManaged public var type: String
    @NSManaged public var episodes: Int
    
    @NSManaged public var startDate: NSDate?
    @NSManaged public var endDate: NSDate?
    @NSManaged public var genres: [String]
    @NSManaged public var imageUrl: String
    @NSManaged public var producers: [String]
    @NSManaged public var status: String
    
    @NSManaged public var details: AnimeDetail
    @NSManaged public var relations: AnimeRelation
    @NSManaged public var cast: AnimeCast
    @NSManaged public var characters: AnimeCharacter
    
    @NSManaged public var favoritedCount: Int
    @NSManaged public var membersCount: Int
    @NSManaged public var membersScore: Double
    @NSManaged public var popularityRank: Int
    @NSManaged public var year: Int
    @NSManaged public var fanart: String?
    @NSManaged public var hummingBirdID: Int
    @NSManaged public var hummingBirdSlug: String
    
    @NSManaged public var duration: Int
    @NSManaged public var externalLinks: [AnyObject]
    @NSManaged public var source: String?
    @NSManaged public var startDateTime: NSDate?
    @NSManaged public var studio: [NSDictionary]
    
    // Progress
    
    public var progress: AnimeProgress?
    
    // Episodes
    var cachedEpisodeList: [Episode] = []
    
    public enum PinName: String {
        case InLibrary = "Object.InLibrary"
    }
    
    public func episodeList(pin: Bool = false, tag: PinName) -> BFTask {
    
        if cachedEpisodeList.count != 0 || (episodes == 0 && pin && traktID == 0) {
            return BFTask(result: cachedEpisodeList)
        }
        
        return fetchEpisodes(myAnimeListID, fromLocalDatastore: true).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
            
            if let episodes = task.result as? [Episode] {
                if episodes.count == 0 {
                    return self.fetchEpisodes(self.myAnimeListID)
                } else {
                    self.cachedEpisodeList = episodes
                    return nil
                }
                
            } else {
                return nil
            }
            
        }.continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
            
            if let result = task.result as? [Episode] where result.count > 0 {
                println("Found \(result.count) eps from network, saving with tag \(tag.rawValue)")
                self.cachedEpisodeList += result
                if pin {
                    PFObject.pinAllInBackground(result, withName: tag.rawValue)
                }
            }
        
            return BFTask(result: self.cachedEpisodeList)
        }

    }
    
    func fetchEpisodes(myAnimeListID: Int, fromLocalDatastore: Bool = false) -> BFTask {
        let episodesQuery = Episode.query()!
        episodesQuery.limit = 1000
        if fromLocalDatastore {
            episodesQuery.fromLocalDatastore()
        }
        episodesQuery.orderByAscending("number")
        episodesQuery.whereKey("anime", equalTo: self)
        return episodesQuery.findObjectsInBackground()
    }
    
    
    // ETA
    
    public var nextEpisode: Int? {
        get {
            if !hasNextEpisodeInformation() {
                return nil
            }
            return nextEpisodeInternal
        }
    }
    
    public var nextEpisodeDate: NSDate? {
        get {
            if !hasNextEpisodeInformation() {
                return nil
            }
            return nextEpisodeDateInternal
        }
    }
    
    var nextEpisodeInternal: Int = 0
    var nextEpisodeDateInternal: NSDate = NSDate()
    
    func hasNextEpisodeInformation() -> Bool {
        if let startDate = startDateTime where AnimeStatus(rawValue: status) != .FinishedAiring {
            if nextEpisodeInternal == 0 {
                let (nextAiringDate, nextAiringEpisode) = nextEpisodeForStartDate(startDate)
                nextEpisodeInternal = nextAiringEpisode
                nextEpisodeDateInternal = nextAiringDate    
            }
            return true
        } else {
            return false
        }
    }
    
    func nextEpisodeForStartDate(startDate: NSDate) -> (nextDate: NSDate, nextEpisode: Int) {
        
        let now = NSDate()
        
        if startDate.compare(now) == NSComparisonResult.OrderedDescending {
            return (startDate, 1)
        }
        
        let cal = NSCalendar.currentCalendar()
        let unit: NSCalendarUnit = .CalendarUnitWeekOfYear
        let components = cal.components(unit, fromDate: startDate, toDate: now, options: nil)
        components.weekOfYear = components.weekOfYear+1
        
        let nextEpisodeDate: NSDate = cal.dateByAddingComponents(components, toDate: startDate, options: nil)!
        return (nextEpisodeDate, components.weekOfYear+1)
    }
    
    // Next episode to Watch
    
    public var nextEpisodeToWatch: Int? {
        get {
            if !hasNextEpisodeToWatchInformation() {
                return nil
            }
            return nextEpisodeToWatchInternal
        }
    }
    
    public var nextEpisodeToWatchDate: NSDate? {
        get {
            if !hasNextEpisodeToWatchInformation() {
                return nil
            }
            
            return nextEpisodeToWatchDateInternal
        }
    }
    
    var nextEpisodeToWatchInternal: Int = 0
    var nextEpisodeToWatchDateInternal: NSDate = NSDate()
    
    func hasNextEpisodeToWatchInformation() -> Bool {
        if let startDate = startDate, let progress = progress where MALList(rawValue: progress.status) != .Completed {
            if nextEpisodeToWatchInternal == 0 {
                let (nextAiringDate, nextAiringEpisode) = nextEpisodeToWatchForStartDate(startDate, progress: progress)
                nextEpisodeToWatchInternal = nextAiringEpisode
                nextEpisodeToWatchDateInternal = nextAiringDate
            }
            return true
        } else {
            return false
        }
    }
    
    func nextEpisodeToWatchForStartDate(startDate: NSDate, progress: AnimeProgress) -> (nextDate: NSDate, nextEpisode: Int) {
        
        let now = NSDate()
        
        if startDate.compare(now) == NSComparisonResult.OrderedDescending || progress.episodes == 0 {
            return (startDate, 1)
        }
        
        let cal = NSCalendar.currentCalendar()
        let unit: NSCalendarUnit = .CalendarUnitWeekOfYear
        let components = cal.components(unit, fromDate: startDate)
        components.weekOfYear = progress.episodes
        
        let nextEpisodeDate: NSDate = cal.dateByAddingComponents(components, toDate: startDate, options: nil)!
        return (nextEpisodeDate, components.weekOfYear + 1)
    }
    
    
    
    // External Links
    
    public enum ExternalLink: String {
        case Crunchyroll = "Crunchyroll"
        case OfficialSite = "Official Site"
        case Daisuki = "Daisuki"
        case Funimation = "Funimation"
        case MyAnimeList = "MyAnimeList"
        case Hummingbird = "Hummingbird"
        case Anilist = "Anilist"
        case Other = "Other"
    }
    
    public struct Link {
        public var site: ExternalLink
        public var url: String
    }
    
    public func linkAtIndex(index: Int) -> Link {
        
        let linkData: AnyObject = externalLinks[index]
        let externalLink = ExternalLink(rawValue: linkData["site"] as! String) ?? .Other

        return Link(site: externalLink, url: (linkData["url"] as! String))
    }
    
    // Fetching
    public class func queryIncludingAddData() -> PFQuery {
        let query = Anime.query()!
        query.includeKey("details")
        query.includeKey("cast")
        query.includeKey("characters")
        query.includeKey("relations")
        return query
    }
    
    public class func queryWith(#objectID: String) -> PFQuery {
        
        let query = Anime.queryIncludingAddData()
        query.limit = 1
        query.whereKey("objectId", equalTo: objectID)
        return query
    }
    
    public class func queryWith(#malID: Int) -> PFQuery {
        
        let query = Anime.queryIncludingAddData()
        query.limit = 1
        query.whereKey("myAnimeListID", equalTo: malID)
        return query
    }
    

}
