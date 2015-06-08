//
//  Anime.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/6/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Parse

public class SeasonalChart: PFObject, PFSubclassing {
    override public class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    public class func parseClassName() -> String {
        return "SeasonalChart"
    }
    
    @NSManaged public var title: String
    @NSManaged public var startDate: NSDate
    @NSManaged public var endDate: NSDate
    @NSManaged public var tvAnime: [Anime]
    @NSManaged public var leftOvers: [Anime]
    @NSManaged public var movieAnime: [Anime]
    @NSManaged public var ovaAnime: [Anime]
    @NSManaged public var specialAnime: [Anime]
    @NSManaged public var onaAnime: [Anime]
}

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
    @NSManaged public var title: String
    @NSManaged public var type: String
    @NSManaged public var episodes: Int
    
    @NSManaged public var startDate: NSDate
    @NSManaged public var endDate: NSDate
    @NSManaged public var genres: [String]
    @NSManaged public var imageUrl: String
    @NSManaged public var producers: [String]
    @NSManaged public var status: String
    
    @NSManaged public var details: PFObject
    @NSManaged public var relations: PFObject
    @NSManaged public var cast: PFObject
    @NSManaged public var characters: PFObject
    @NSManaged public var forum: PFObject
    @NSManaged public var reviews: PFObject
    
    @NSManaged public var favoritedCount: Int
    @NSManaged public var membersCount: Int
    @NSManaged public var membersScore: Double
    @NSManaged public var popularityRank: Int
    @NSManaged public var year: Int
    @NSManaged public var fanart: String
    @NSManaged public var hummingBirdID: Int
    @NSManaged public var hummingBirdSlug: String
    
    @NSManaged public var duration: Int
    @NSManaged public var externalLinks: [NSDictionary]
    @NSManaged public var source: String?
    @NSManaged public var startDateTime: NSDate?
    @NSManaged public var studio: [NSDictionary]
    
    public var nextEpisode: Int? {
        get {
            if !hasNextEpisodeInformation() {
                return 0
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
        if let startDate = startDateTime {
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
    
    
}

