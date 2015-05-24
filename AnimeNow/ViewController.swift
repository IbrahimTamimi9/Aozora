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

        // Using findAnime()
//        AnimeService
//        .findAnime(genres:[.Action,.Adventure], classification:[.R17], types:[.TV], limit: 2)
//            .continueWithBlock {
//            (task: BFTask!) -> AnyObject! in
//            
//            for anime in task.result as! [PFObject] {
//                let title: AnyObject? = anime["title"]
//                let malID: AnyObject? = anime["myAnimeListID"]
//                println("\(malID) \(title)")
//            }
//            
//            return nil
//        }
        
        
//        // Read JSON and store in string
//        let filePath = NSBundle.mainBundle().pathForResource("ServiceIdentifier", ofType: "json")
//        let data = NSData(contentsOfFile: filePath!)
//        let result = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: nil) as! NSDictionary
//        let serviceIdentifiers = result["results"] as! [NSDictionary]
        
//        AnimeService.findAllAnime().continueWithBlock { (task: BFTask!) -> AnyObject! in
//            
//            for anime in task.result as! [PFObject] {
//
//                NSThread.sleepForTimeInterval(0.01)
//            }
//
//            return nil
//        }.continueWithBlock {
//            (task: BFTask!) -> AnyObject! in
//            if (task.exception != nil || task.error != nil) {
//                println("duh")
//                println(task.error)
//                println(task.exception)
//            }
//            return nil
//        }
        
        // Filter class by value(s) of pointer column
//        let query = PFQuery(className: "Test1")
//        let innerQuery = PFQuery(className: "Test2")
//        innerQuery.whereKey("types", containsAllObjectsInArray: ["tv"])
//        query.whereKey("test2", matchesQuery: innerQuery)
//        query.findObjectsInBackground().continueWithBlock {
//            (task: BFTask!) -> AnyObject! in
//            for test1 in task.result as! [PFObject] {
//                println(test1["title"])
//                let objects: [PFObject] = [test1,test1["test2"] as! PFObject];
//                PFObject.deleteAll(objects);
//                break;
//                
//            }
//            
//            return nil
//        }
    
        
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

}

