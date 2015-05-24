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
        // Do any additional setup after loading the view, typically from a nib.
//        let expirationDate = NSUserDefaults.standardUserDefaults().objectForKey("expiration_date") as? NSDate
//        let accessToken = NSUserDefaults.standardUserDefaults().stringForKey("access_token")
//        
//        if accessToken == nil || expirationDate?.compare(NSDate()) == .OrderedAscending {
//            Alamofire.request(AniList.Router.requestAccessToken())
//                .validate()
//                .responseJSON { (req, res, JSON, error) in
//                    
//                    if error == nil {
//                        let dictionary = (JSON as! NSDictionary)
//                        NSUserDefaults.standardUserDefaults().setObject(dictionary["access_token"], forKey: "access_token")
//                        NSUserDefaults.standardUserDefaults().setObject(NSDate(timeIntervalSinceNow: dictionary["expires_in"] as! Double), forKey: "expiration_date")
//                        NSUserDefaults.standardUserDefaults().synchronize()
//                        self.request()
//                    }else {
//                        println(error)
//                    }
//            }
//        } else {
//            request()
//        }
        
        //MALScrapper.getInfo(.Winter)
//        SeasonalChartService.currentSeasonalChart().continueWithBlock { (task: BFTask!) -> BFTask! in
//            println(task.result);
//            return task
//        }


//        AnimeService.allAnime().continueWithBlock { (task: BFTask!) -> AnyObject in
//            let result = task.result as! [PFObject]
//
//            for anime in result {
//
////                if let startDate = anime["startDate"] as? String {
////                    anime["startDate2"] = self.dateForString(startDate)
////                }
////                if let endDate = anime["endDate"] as? String {
////                    anime["endDate2"] = self.dateForString(endDate)
////                }
//         
//                anime.saveInBackground()
//                // This maximizes request to ~25/sec
//                NSThread.sleepForTimeInterval(0.035715)
//            }
//            return result
//        }
        
//        AnimeService.findAnimeBetterHigherThanNine().continueWithBlock { (task: BFTask!) -> AnyObject! in
//            let result = task.result
//            return task
//        }
        
        SeasonalChartService.fillChartWithAnime(SeasonalChart.Spring, year: 2015)
    }
    
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
    
    // MARK: - Anilist Testing
    
    func request() {
        Alamofire.request(AniList.Router.browseAnime(year: 2015, season: AniList.Season.Spring, type: nil, status: nil, genres: nil, excludedGenres: nil, sort: AniList.Sort.StartDate, airingData: true, fullPage: true, page: nil)).validate().responseJSON { (req, res, JSON, error) in
            if error == nil {
                println(JSON)
            } else {
                println(error)
            }
        }
    }
    
    // MARK: - Parse testing
    
    

}

