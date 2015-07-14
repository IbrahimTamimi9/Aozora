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
    
    public static let LastSyncDateDefaultsKey = "LibrarySync.LastSyncDate"
    
    public static let sharedInstance = LibrarySyncController()
    
    public let AnimeSync = "LibrarySync.AnimeSync"
    public let EpisodeSync = "LibrarySync.EpisodeSync"
    
    // MARK: - Sync Objects Information
    
    public func syncParseInformation() -> BFTask {
        let syncAnime = syncAnimeInformation()
        let syncEpisodes = syncEpisodeInformation()
        
        return BFTask(forCompletionOfAllTasks: [syncAnime, syncEpisodes])
    }
    
    public func syncAnimeInformation() -> BFTask {
        
        let shouldSyncAnime = NSUserDefaults.shouldPerformAction(AnimeSync, expirationDays: 1)
        
        if !shouldSyncAnime {
            return BFTask(result: nil)
        }
        
        let pinName = Anime.PinName.InLibrary.rawValue
        
        let query = Anime.query()!
        query.limit = 1
        query.fromPinWithName(pinName)
        query.orderByDescending("updatedAt")
        return query.findObjectsInBackground()
            .continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
            
            if let result = task.result as? [Anime], let anime = result.last {
                return BFTask(result: anime)
            } else {
                return nil
            }
            
            }.continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
            
                if let anime = task.result as? Anime {
                    
                    let updatedQuery = Anime.queryIncludingAddData()
                    updatedQuery.whereKey("updatedAt", greaterThan: anime.updatedAt!)
                    return updatedQuery.findObjectsInBackground()
                    
                } else {
                    return nil
                }
                
            }.continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
                
                if let result = task.result as? [Anime] where result.count != 0 {
                    return PFObject.unpinAllInBackground(result, withName: pinName).continueWithBlock({ (task: BFTask!) -> AnyObject! in
                        println("Updated \(result.count) anime, saving with tag \(pinName)")
                        NSUserDefaults.completedAction(self.AnimeSync)
                        return PFObject.pinAllInBackground(result, withName: pinName)
                    })
                } else {
                    NSUserDefaults.completedAction(self.AnimeSync)
                    return nil
                }
                
            }
    }
    
    public func syncEpisodeInformation() -> BFTask {
        
        let shouldSyncEpisode = NSUserDefaults.shouldPerformAction(EpisodeSync, expirationDays: 1)
        
        if !shouldSyncEpisode {
            return BFTask(result: nil)
        }
        
        let pinName = Anime.PinName.InLibrary.rawValue
        
        let query = Episode.query()!
        query.limit = 1
        query.fromLocalDatastore()
        query.orderByDescending("updatedAt")
        return query.findObjectsInBackground()
            .continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
                
                if let result = task.result as? [Episode], let episode = result.last {
                    return BFTask(result: episode)
                } else {
                    return nil
                }
                
            }.continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
                
                if let episode = task.result as? Episode {
                    let updatedQuery = Episode.query()!
                    updatedQuery.whereKey("updatedAt", greaterThan: episode.updatedAt!)
                    return updatedQuery.findObjectsInBackground()
                } else {
                    return nil
                }
                
            }.continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
                
                if let result = task.result as? [Episode] where result.count != 0 {
                    return PFObject.unpinAllInBackground(result, withName: pinName).continueWithBlock({ (task: BFTask!) -> AnyObject! in
                        println("Updated \(result.count) episode, saving with tag \(pinName)")
                        NSUserDefaults.completedAction(self.EpisodeSync)
                        return PFObject.pinAllInBackground(result, withName: pinName)
                    })
                } else {
                    NSUserDefaults.completedAction(self.EpisodeSync)
                    return nil
                }         
        }
    }
    
    
    // MARK: - Sync with MyAnimeList
    
    public class func fetchAnimeList(isRefreshing: Bool) -> BFTask {
        let shouldSyncData = NSUserDefaults.shouldPerformAction(LastSyncDateDefaultsKey, expirationDays: 1)
        
        if shouldSyncData || isRefreshing {
            println("Fetching all anime library from network..")
            return pushNonSyncedChanges().continueWithBlock({ (task: BFTask!) -> AnyObject! in
                    return self.loadAnimeList()
                
                }).continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
                
                let result = task.result["anime"] as! [[String: AnyObject]]
                let realm = Realm()
                var newAnimeProgress: [AnimeProgress] = []
                for data in result {
                    
                    var animeProgress = AnimeProgress()
                    animeProgress.myAnimeListID = data["id"] as! Int
                    animeProgress.status = data["watched_status"] as! String
                    animeProgress.episodes = data["watched_episodes"] as! Int
                    animeProgress.score = data["score"] as! Int
                    animeProgress.syncState = SyncState.InSync.rawValue
                    newAnimeProgress.append(animeProgress)
                }
                
                realm.write({ () -> Void in
                    realm.add(newAnimeProgress, update: true)
                })
                
                return self.fetchAllAnimeProgress()
            })
        } else {
            return fetchAllAnimeProgress()
        }
    }
    
    class func pushNonSyncedChanges() -> BFTask {
        
        // Fetch Progress
        let realm = Realm()
        let animeLibrary = realm.objects(AnimeProgress).filter("syncState != \(SyncState.InSync.rawValue)")
        
        var tasks: [BFTask] = []
        
        for progress in animeLibrary {
            let task: BFTask
            
            switch SyncState(rawValue: progress.syncState)! {
            case .Created:
                task = addAnime(progress)
            case .Updated:
                task = updateAnime(progress)
            case .Deleted:
                task = deleteAnime(progress)
            default:
                task = BFTask(result: nil)
            }
            
            tasks.append(task)
        }
        
        if tasks.count > 0 {
            println("Pushing \(tasks.count) non synced objects")
        }
        
        return BFTask(forCompletionOfAllTasks: tasks)
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
        let animeLibrary = realm.objects(AnimeProgress).filter("syncState != \(SyncState.Deleted.rawValue)")
        
        var idList: [Int] = []
        var animeList: [Anime] = []
        for animeProgress in animeLibrary {
            idList.append(animeProgress.myAnimeListID)
        }
        
        // Fetch from disk then network
        return fetchAnime(idList, withPinName: Anime.PinName.InLibrary.rawValue)
        .continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
            
            if let result = task.result as? [Anime] where result.count > 0 {
                animeList = result
            }
            
            return nil
        }.continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
            
            let missingIdList = idList.filter({ (myAnimeListID: Int) -> Bool in
                
                var filteredAnime = animeList.filter({ $0.myAnimeListID == myAnimeListID })
                return filteredAnime.count == 0
            })
            
            if missingIdList.count != 0 {
                return self.fetchAnime(missingIdList, includeAllData: true)
            } else {
                return nil
            }
            
        }.continueWithExecutor( BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task: BFTask!) -> AnyObject! in
            let pinName = Anime.PinName.InLibrary.rawValue
            if let result = task.result as? [Anime] where result.count > 0 {
                println("Found \(result.count) anime from network, saving with tag \(pinName)")
                animeList += result
                
                PFObject.pinAllInBackground(result, withName: pinName)
            }
            
            self.matchAnimeWithProgress(animeList)
            // Update last sync date
            NSUserDefaults.completedAction(self.LastSyncDateDefaultsKey)
            
            return BFTask(result: animeList)
        })
    }
    
    public class func fetchAnime(myAnimeListIDs: [Int], withPinName: String? = nil, includeAllData: Bool = false) -> BFTask {
        
        let query: PFQuery
        if includeAllData {
            query = Anime.queryIncludingAddData()
        } else {
            query = Anime.query()!
        }
        
        query.limit = 1000
        if let pinName = withPinName {
            query.fromPinWithName(pinName)
        }
        
        query.whereKey("myAnimeListID", containedIn: myAnimeListIDs)
        return query.findObjectsInBackground()
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
                if progress.myAnimeListID == anime.myAnimeListID {
                    anime.progress = progress
                    break
                }
            }
        }
    }
    
    // MARK: - Update Library Methods
    
    public class func addAnime(progress: AnimeProgress) -> BFTask {
        
        let malProgress = malProgressWithProgress(progress)
        return requestWithProgress(progress, router: Atarashii.Router.animeAdd(progress: malProgress)).continueWithBlock({ (task: BFTask!) -> AnyObject! in
            
            if let error = task.error {
                Realm().write({ () -> Void in
                    progress.syncState = SyncState.Created.rawValue
                })
            }
            
            return nil
        })
    }
    
    public class func updateAnime(progress: AnimeProgress) -> BFTask {
        
        let malProgress = malProgressWithProgress(progress)
        return requestWithProgress(progress, router: Atarashii.Router.animeUpdate(progress: malProgress)).continueWithBlock({ (task: BFTask!) -> AnyObject! in
            
            if let error = task.error {
                Realm().write({ () -> Void in
                    progress.syncState = SyncState.Updated.rawValue
                })
            }
            
            return nil
        })
    }
    
    public class func deleteAnime(progress: AnimeProgress) -> BFTask {
        
        return requestWithProgress(progress, router: Atarashii.Router.animeDelete(id: progress.myAnimeListID)).continueWithBlock({ (task: BFTask!) -> AnyObject! in
            
            if let error = task.error {
                Realm().write({ () -> Void in
                    progress.syncState = SyncState.Deleted.rawValue
                })
                return BFTask(error: NSError())
            } else {
                return BFTask(result: nil)
            }
            
        })
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
        return Atarashii.Progress(myAnimeListID: progress.myAnimeListID, status: malList, episodes: progress.episodes, score: progress.score)
        
    }
    
}