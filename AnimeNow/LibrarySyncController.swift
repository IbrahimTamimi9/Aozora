//
//  LibrarySyncController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/2/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import ANCommonKit
import Parse
import Bolts
import Alamofire
import RealmSwift

public class LibrarySyncController {
    
    static let lastSyncDateDefaultsKey = "LibrarySync.LastSyncDate"
    class var shouldSyncData: Bool {
        get {
            let lastSyncDate = NSUserDefaults.standardUserDefaults().objectForKey(lastSyncDateDefaultsKey) as! NSDate?
            if let lastSyncDate = lastSyncDate {
                
                let cal = NSCalendar.currentCalendar()
                let unit:NSCalendarUnit = .CalendarUnitDay
                let components = cal.components(unit, fromDate: lastSyncDate, toDate: NSDate(), options: nil)
                
                return components.day >= 1 ? true : false
                
            } else {
                return true
            }
        }
    }
    
    class func syncedData() {
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: lastSyncDateDefaultsKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    public class func fetchAnimeList(isRefreshing: Bool) -> BFTask {
        
        if shouldSyncData || isRefreshing {
            println("Fetching all anime library from network")
            return loadAnimeList().continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
                
                let result = task.result["anime"] as! [[String: AnyObject]]
                let realm = Realm()
                var newAnimeProgress: [AnimeProgress] = []
                for data in result {
                    
                    var animeProgress = AnimeProgress()
                    animeProgress.animeID = data["id"] as! Int
                    animeProgress.status = data["watched_status"] as! String
                    animeProgress.episodes = data["watched_episodes"] as! Int
                    animeProgress.score = data["score"] as! Int
                    newAnimeProgress.append(animeProgress)
                }
                
                realm.write({ () -> Void in
                    realm.add(newAnimeProgress, update: true)
                })
                
                return self.fetchAllAnimeProgress()
            })
        } else {
            println("Only fetching from parse")
            return fetchAllAnimeProgress()
        }
    }
    
    
    class func loadAnimeList() -> BFTask! {
        let completionSource = BFTaskCompletionSource()
        if let username = PFUser.malUsername {
            Alamofire.request(Atarashii.Router.animeList(username: username)).validate().responseJSON {
                (req, res, JSON, error) -> Void in
                if error == nil {
                    completionSource.setResult(JSON)
                } else {
                    completionSource.setError(error)
                }
            }
        }
        return completionSource.task
    }
    
    
    class func fetchAllAnimeProgress() -> BFTask {
        let realm = Realm()
        let animeLibrary = realm.objects(AnimeProgress)
        
        var idList: [Int] = []
        var animeList: [Anime] = []
        for animeProgress in animeLibrary {
            idList.append(animeProgress.animeID)
        }
        
        // Fetch from disk then network
        return fetchAnimeFromLocalDatastore(idList)
        .continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
            
            if let result = task.result as? [Anime] where result.count > 0 {
                println("found \(result.count) objects from local datastore")
                animeList = result
            }
            
            return nil
        }.continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
            
            let missingIdList = idList.filter({ (myAnimeListID: Int) -> Bool in
                
                var filteredAnime = animeList.filter({ $0.myAnimeListID == myAnimeListID })
                return filteredAnime.count == 0
            })
            
            if missingIdList.count != 0 {
                return self.fetchAnimeFromNetwork(missingIdList)
            } else {
                return nil
            }
            
        }.continueWithExecutor( BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task: BFTask!) -> AnyObject! in
            
            if let result = task.result as? [Anime] where result.count > 0 {
                println("found \(result.count) objects from network")
                animeList += result
                
                PFObject.pinAllInBackground(result, withName: Anime.PinName.InLibrary.rawValue)
            }
            
            self.matchAnimeWithProgress(animeList)
            // Update last sync date
            self.syncedData()
            
            return BFTask(result: animeList)
        })
    }
    
    public class func fetchAnimeFromLocalDatastore(myAnimeListIDs: [Int]) -> BFTask {
        println("From local datastore...")
        let query = Anime.query()!
        query.limit = 1000
        query.fromLocalDatastore()
        query.whereKey("myAnimeListID", containedIn: myAnimeListIDs)
        return query.findObjectsInBackground()
    }
    
    class func fetchAnimeFromNetwork(myAnimeListIDs: [Int]) -> BFTask {
        // Fetch from network for missing titles
        println("From network...")
        let networkQuery = Anime.query()!
        networkQuery.limit = 1000
        networkQuery.whereKey("myAnimeListID", containedIn: myAnimeListIDs)
        return networkQuery.findObjectsInBackground()
    }
    
    public class func matchAnimeWithProgress(animeList: [Anime]) {
        // Match all anime with it's progress..
        let realm = Realm()
        let animeLibrary = realm.objects(AnimeProgress)
        
        for anime in animeList {
            
            if anime.progress != nil {
                continue
            }
            for progress in animeLibrary {
                if progress.animeID == anime.myAnimeListID {
                    anime.progress = progress
                    break
                }
            }
        }
    }
    
    // MARK: - Update Library Methods
    
    public class func addAnime(progress: AnimeProgress) -> BFTask {
        
        let malProgress = malProgressWithProgress(progress)
        return requestWithProgress(progress, router: Atarashii.Router.animeAdd(progress: malProgress))
    }
    
    public class func updateAnime(progress: AnimeProgress) -> BFTask {
        
        let malProgress = malProgressWithProgress(progress)
        return requestWithProgress(progress, router: Atarashii.Router.animeUpdate(progress: malProgress))
    }
    
    public class func deleteAnime(progress: AnimeProgress) -> BFTask {
        
        return requestWithProgress(progress, router: Atarashii.Router.animeDelete(id: progress.animeID))
    }
    
    class func requestWithProgress(progress: AnimeProgress, router: Atarashii.Router) -> BFTask {
        
        if !PFUser.currentUserLoggedIn() {
            return BFTask(result: nil)
        }
        
        let completionSource = BFTaskCompletionSource()
        
        let malUsername = PFUser.malUsername!
        let malPassword = PFUser.malPassword!
        
        Alamofire.request(router)
            .authenticate(user: malUsername, password: malPassword)
            .validate()
            .responseJSON { (req, res, JSON, error) -> Void in
                if error == nil {
                    completionSource.setResult(JSON)
                } else {
                    completionSource.setError(error)
                }
        }
        return completionSource.task
        
    }
    
    class func malProgressWithProgress(progress: AnimeProgress) -> Atarashii.Progress {
        let malList = MALList(rawValue: progress.status)!
        return Atarashii.Progress(animeID: progress.animeID, status: malList, episodes: progress.episodes, score: progress.score)
        
    }
    
}