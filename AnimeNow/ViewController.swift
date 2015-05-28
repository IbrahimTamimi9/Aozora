//
//  ViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 4/29/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import Alamofire
import ANParseKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: Use anilist to calculate eta
        
        
    }
    
    // MARK: - TraktV2
    
    func linkTraktWithMAL() {
        
        AnimeService.findAllAnime().continueWithBlock { (task: BFTask!) -> AnyObject! in
            
//.includeKey("details")
//.whereKeyDoesNotExist("traktID")
//.selectKeys(["details","myAnimeListID","year","title","startDate"])
//.whereKey("type", equalTo: "TV")
//.whereKey("startDate", greaterThan: NSDate().dateByAddingTimeInterval(-10*60*60*24*365))
            var sequence = BFTask(result: nil);
            
            for anime in task.result as! [PFObject] {
                sequence = sequence.continueWithBlock {
                (task: BFTask!) -> AnyObject! in
                let title = (anime["title"] as! String)
                let year = anime["year"] as! Int
                return self.traktRequestWith(route: TraktV2.Router.searchShowForTitle(title: title, year: year))
                
                }.continueWithBlock{
                    (task: BFTask!) -> AnyObject! in
                    
                    if let result = task.result as? NSArray where result.count > 0 {
                        
                        let title = (anime["title"] as! String)
                        println("Results for: \(title), found \(result.count) results")
                        let traktID = ((((result.firstObject as! NSDictionary)["show"] as! NSDictionary)["ids"] as! NSDictionary)["trakt"] as! Int)
                        return self.traktRequestWith(route: TraktV2.Router.showSummaryForId(id: traktID))
                        
                    } else {
                        //let title = (anime["title"] as! String)
                        //println("Failed for title \(title)")
                        NSThread.sleepForTimeInterval(0.2)
                        return BFTask(result: nil)
                    }
                    
                }.continueWithBlock{
                    (task: BFTask!) -> AnyObject! in
                    
                    if let result = task.result {
                        let date1 = (result["first_aired"] as! String).date
                        let date2 = anime["startDate"] as! NSDate
                        if NSCalendar.currentCalendar().isDate(date1, inSameDayAsDate: date2) {
                            println("Matched!")
                        }
                        return nil;
                    } else {
                        return nil;
                    }
                }
                
            }
            
            return nil;
            }.continueWithBlock {
                (task: BFTask!) -> AnyObject! in
                if (task.exception != nil) {
                    println(task.exception)
                }
                return nil
        }
        
    }
    
    func getShowIDsFromSlugs() {
//        .whereKeyExists("traktSlug")
//        .selectKeys(["traktSlug"])
        AnimeService.findAllAnime().continueWithBlock { (task: BFTask!) -> AnyObject! in
            
            var sequence = BFTask(result: nil);
            
            for anime in task.result as! [PFObject] {
                sequence = sequence.continueWithBlock {
                    (task: BFTask!) -> AnyObject! in
                    
                    let slug = (anime["traktSlug"] as! String)
                    return self.traktRequestWith(route: TraktV2.Router.showSummaryForSlug(slug: slug))
                    
                    }.continueWithBlock{
                        (task: BFTask!) -> AnyObject! in
                        
                        if let result = task.result as? NSDictionary {
                            let traktID = ((result["ids"] as! NSDictionary)["trakt"] as! Int)
                            anime["traktID"] = traktID
                            return anime.saveInBackground()
                        } else {
                            let slug = anime["traktSlug"]
                            println("Failed for slug \(slug)")
                            return BFTask(result: nil)
                        }
                        
                }
                
            }
            
            return nil;
        }
    }
    
    func traktRequestWith(#route: TraktV2.Router) -> BFTask {
        let completionSource = BFTaskCompletionSource()
        Alamofire.request(route).validate().responseJSON { (req, res, JSON, error) -> Void in
            if error == nil {
                completionSource.setResult(JSON)
            } else {
                completionSource.setError(error)
            }
        }
        return completionSource.task
    }
    
    // MARK: - TraktV1
    func getShowSlugs() {
        AnimeService.findAllAnime().continueWithBlock { (task: BFTask!) -> AnyObject! in
            
            var sequence = BFTask(result: nil);
            
            for anime in task.result as! [PFObject] {
                sequence = sequence.continueWithBlock {
                    (task: BFTask!) -> AnyObject! in
                    
                    return self.showSummary(anime["tvdbID"] as! Int)
                    
                    }.continueWithBlock{
                        (task: BFTask!) -> AnyObject! in
                        
                        let result = task.result as! NSDictionary
                        
                        let slug = (result["url"] as! String).stringByReplacingOccurrencesOfString("/shows/", withString: "")
                        
                        anime["traktSlug"] = slug
                        NSThread.sleepForTimeInterval(0.1)
                        return anime.saveInBackground()
                }
                
            }
            
            return nil;
        }
    }
    
    func showSummary(id: Int) -> BFTask! {
        let completionSource = BFTaskCompletionSource()
        Alamofire.request(TraktV1.Router.showSummaryForID(tvdbID: id)).validate().responseJSON { (req, res, JSON, error) -> Void in
            if error == nil {
                completionSource.setResult(JSON)
            } else {
                completionSource.setError(error)
            }
        }
        return completionSource.task
    }
    
    // MARK: - AnimeService
    
    func findAnime() {
        AnimeService
        .findAnime(genres:[.Action,.Adventure], classification:[.R17], types:[.TV], limit: 2)
            .continueWithBlock {
            (task: BFTask!) -> AnyObject! in

            for anime in task.result as! [PFObject] {
                let title: AnyObject? = anime["title"]
                let malID: AnyObject? = anime["myAnimeListID"]
                println("\(malID) \(title)")
            }
            
            return nil
        }
    }
    
    // MARK: - Utilities
    
    func dateForString(string: String) -> AnyObject! {
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if let date = dateFormatter.dateFromString(string) {
            return date
        } else {
            return NSNull()
        }
        
    }
    
    func getDataFromFile() {
        // Read JSON and store in string
        let filePath = NSBundle.mainBundle().pathForResource("ServiceIdentifier", ofType: "json")
        let data = NSData(contentsOfFile: filePath!)
        let result = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: nil) as! NSDictionary
        let serviceIdentifiers = result["results"] as! [NSDictionary]
    }
    
    // MARK: - Anilist Init
    
    func getAnilistAccessToken() {
        let expirationDate = NSUserDefaults.standardUserDefaults().objectForKey("expiration_date") as? NSDate
        let accessToken = NSUserDefaults.standardUserDefaults().stringForKey("access_token")
        
        if accessToken == nil || expirationDate?.compare(NSDate()) == .OrderedAscending {
            Alamofire.request(AniList.Router.requestAccessToken())
                .validate()
                .responseJSON { (req, res, JSON, error) in
                    
                    if error == nil {
                        let dictionary = (JSON as! NSDictionary)
                        NSUserDefaults.standardUserDefaults().setObject(dictionary["access_token"], forKey: "access_token")
                        NSUserDefaults.standardUserDefaults().setObject(NSDate(timeIntervalSinceNow: dictionary["expires_in"] as! Double), forKey: "expiration_date")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        self.request()
                    }else {
                        println(error)
                    }
            }
        } else {
            request()
        }
    }
    
    func request() {
    }
    
    // MARK: - Anilist Linker
    
    func convertMALTitleToAniListTitle(title: String) -> String {
        return title
            .stringByReplacingOccurrencesOfString("2nd season", withString: "2")
            .stringByReplacingOccurrencesOfString("2nd Season", withString: "2")
            .stringByReplacingOccurrencesOfString("TV", withString: " ")
            .stringByReplacingOccurrencesOfString("OVA", withString: " ")
            .stringByReplacingOccurrencesOfString("/", withString: " ")
            .stringByReplacingOccurrencesOfString("!", withString: " ")
            .stringByReplacingOccurrencesOfString("-", withString: " ")
            .stringByReplacingOccurrencesOfString("(", withString: " ")
            .stringByReplacingOccurrencesOfString(")", withString: " ")
            .componentsSeparatedByString(":")[0]
    }
    
    func searchAnime(query: String) -> BFTask! {
        let completionSource = BFTaskCompletionSource()
        let newTitle = convertMALTitleToAniListTitle(query)
        Alamofire.request(AniList.Router.searchAnime(query: newTitle)).validate().responseJSON { (req, res, JSON, error) -> Void in
            if error == nil {
                completionSource.setResult(JSON)
            } else {
                completionSource.setError(error)
            }
        }
        return completionSource.task
    }
    
    func anilistLinker() {
        let accessToken = NSUserDefaults.standardUserDefaults().stringForKey("access_token")
        println("using token: \(accessToken)")
        AnimeService.findAllAnime().continueWithBlock { (task: BFTask!) -> AnyObject! in
            
            var sequence = BFTask(result: nil);
            
            for anime in task.result as! [PFObject] {
                
                sequence = sequence.continueWithBlock {
                    (task: BFTask!) -> AnyObject! in
                    
                    return self.searchAnime(anime["title"] as! String)
                    
                    }.continueWithBlock({
                        (task: BFTask!) -> AnyObject! in
                        
                        if task.result == nil {
//                            let title: AnyObject? = anime["title"];
//                            println("Failed for: \(title)")
                            return BFTask(result: nil)
                        }
                        
                        var matchedAnime: NSDictionary?
                        var result = task.result as! NSArray
                        if result.count == 1 {
                            matchedAnime = result.firstObject as? NSDictionary
                        } else {
                            var matchCount = 0
                            var lastMatch: NSDictionary?
                            for animeDict in result {
                                if
                                    let type1 = animeDict["type"] as? String,
                                    let type2 = anime["type"] as? String,
                                    let eps1 = animeDict["total_episodes"] as? Int,
                                    let eps2 = anime["episodes"] as? Int
                                    where
                                    ((type1 == type2) || (type1 == "TV Short" && type2 == "TV")) &&
                                    (eps1 == eps2 || (eps1 == 0))
                                {
                                    matchCount++
                                    lastMatch = animeDict as? NSDictionary
                                }
                            }
                            if matchCount == 1 {
                                matchedAnime = lastMatch;
                            }
                            
                        }
                        
                        NSThread.sleepForTimeInterval(0.51)
                        
                        if let matchedAnime = matchedAnime,
                            let id = matchedAnime["id"] as? Int,
                            let id2 = anime["myAnimeListID"] as? Int
                        where id > 20449 {
                                println("Matched \(id) \(id2)")
                                anime["anilistID"] = id
                                //return BFTask(result: nil)
                                return anime.saveEventually()
                        } else {
                            //let title: AnyObject? = anime["title"];
                            //println("Failed for: \(title)")
                            return BFTask(result: nil)
                        }
                        
                    })
                
            }
            
            return sequence
            }.continueWithBlock {
                (task: BFTask!) -> AnyObject! in
                if (task.exception != nil) {
                    println(task.exception)
                }
                return nil
        }
        
        
//        Alamofire.request(AniList.Router.browseAnime(year: 2015, season: AniList.Season.Spring, type: nil, status: nil, genres: nil, excludedGenres: nil, sort: AniList.Sort.StartDate, airingData: true, fullPage: true, page: nil)).validate().responseJSON { (req, res, JSON, error) in
//            if error == nil {
//                println(JSON)
//            } else {
//                println(error)
//            }
//        }
    }

}

extension String {
    var date: NSDate {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return formatter.dateFromString(self)!
    }
}

