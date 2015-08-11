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
        let actionID = AnimeSync
        let shouldSyncAnime = NSUserDefaults.shouldPerformAction(actionID, expirationDays: 1)
        
        if !shouldSyncAnime {
            return BFTask(result: nil)
        }
        
        let pinName = Anime.PinName.InLibrary.rawValue
        
        let query = Anime.queryIncludingAddData()
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
                        NSUserDefaults.completedAction(actionID)
                        return PFObject.pinAllInBackground(result, withName: pinName)
                    })
                } else {
                    NSUserDefaults.completedAction(actionID)
                    return nil
                }
                
            }
    }
    
    public func syncEpisodeInformation() -> BFTask {
        let actionID = EpisodeSync
        let shouldSyncEpisode = NSUserDefaults.shouldPerformAction(actionID, expirationDays: 1)
        
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
                        NSUserDefaults.completedAction(actionID)
                        return PFObject.pinAllInBackground(result, withName: pinName)
                    })
                } else {
                    NSUserDefaults.completedAction(actionID)
                    return nil
                }         
        }
    }
    
    
    // MARK: - Sync with MyAnimeList
    
    public class func fetchWatchingList(isRefreshing: Bool) -> BFTask {
        let shouldSyncData = NSUserDefaults.shouldPerformAction(LastSyncDateDefaultsKey, expirationDays: 1)
        
        if shouldSyncData || isRefreshing {
            println("Fetching all anime library from network..")
//            return pushNonSyncedChanges().continueWithBlock({ (task: BFTask!) -> AnyObject! in
//                    return self.loadAnimeList()
//                
//                }).continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
//                
//                let result = task.result["anime"] as! [[String: AnyObject]]
//
//                var newAnimeProgress: [AnimeProgress] = []
//                for data in result {
//                    
//                    var animeProgress = AnimeProgress()
//                    animeProgress.myAnimeListID = data["id"] as! Int
//                    animeProgress.status = data["watched_status"] as! String
//                    animeProgress.episodes = data["watched_episodes"] as! Int
//                    animeProgress.score = data["score"] as! Int
//                    animeProgress.syncState = SyncState.InSync.rawValue
//                    newAnimeProgress.append(animeProgress)
//                }
//                
//                realm.write({ () -> Void in
//                    realm.add(newAnimeProgress, update: true)
//                })
//                
//                return self.fetchAnimeProgress(onlyWatching: true)
//            })
            return syncAnimeProgressInformation().continueWithBlock({ (task: BFTask!) -> AnyObject! in
                return self.fetchAnimeProgress(onlyWatching: true)
            })
        } else {
            return fetchAnimeProgress(onlyWatching: true)
        }
    }
    
    public class func fetchTheRestOfLists() -> BFTask {

        return fetchAnimeProgress(onlyWatching: false)
    }
    
    public class func syncAnimeProgressInformation() -> BFTask {
        
        let query = AnimeProgress.query()!
        query.limit = 1
        query.fromLocalDatastore()
        query.orderByDescending("updatedAt")
        return query.findObjectsInBackground()
            .continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
                
                if let result = task.result as? [AnimeProgress], let AnimeProgress = result.last {
                    return BFTask(result: AnimeProgress)
                } else {
                    return nil
                }
                
            }.continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
                
                let query = AnimeProgress.query()!
                query.includeKey("anime")
                query.includeKey("anime.cast")
                query.includeKey("anime.details")
                query.includeKey("anime.characters")
                query.includeKey("anime.relations")
                query.whereKey("user", equalTo: User.currentUser()!)
                query.limit = 1000
                // TODO: Support more than 1000 anime in library
                
                if let animeProgress = task.result as? AnimeProgress {
                    query.whereKey("updatedAt", greaterThan: animeProgress.updatedAt!)
                    return query.findObjectsInBackground()
                } else if task.result == nil && task.error == nil {
                    return query.findObjectsInBackground()
                } else {
                    return task.error
                }
                
            }.continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
                
                if let result = task.result as? [AnimeProgress] where result.count != 0 {
                    return PFObject.unpinAllInBackground(result).continueWithBlock({ (task: BFTask!) -> AnyObject! in
                        println("Updated \(result.count) AnimeProgress")
                        NSUserDefaults.completedAction(self.LastSyncDateDefaultsKey)
                        return PFObject.pinAllInBackground(result)
                    })
                } else {
                    NSUserDefaults.completedAction(self.LastSyncDateDefaultsKey)
                    return nil
                }
        }
    }
//    class func pushNonSyncedChanges() -> BFTask {
//        
//        // Fetch Progress
//        let realm = Realm()
//        let animeLibrary = realm.objects(AnimeProgress).filter("syncState != \(SyncState.InSync.rawValue)")
//        
//        var tasks: [BFTask] = []
//        
//        for progress in animeLibrary {
//            let task: BFTask
//            
//            switch SyncState(rawValue: progress.syncState)! {
//            case .Created:
//                task = addAnime(progress)
//            case .Updated:
//                task = updateAnime(progress)
//            case .Deleted:
//                task = deleteAnime(progress)
//            default:
//                task = BFTask(result: nil)
//            }
//            
//            tasks.append(task)
//        }
//        
//        if tasks.count > 0 {
//            println("Pushing \(tasks.count) non synced objects")
//        }
//        
//        return BFTask(forCompletionOfAllTasks: tasks)
//    }
    
    
//    class func loadAnimeList() -> BFTask! {
//        let completionSource = BFTaskCompletionSource()
//        if let username = PFUser.malUsername {
//            Alamofire.request(Atarashii.Router.animeList(username: username)).validate().responseJSON {
//                (req, res, JSON, error) -> Void in
//                if error == nil {
//                    completionSource.setResult(JSON)
//                } else {
//                    completionSource.setError(error)
//                }
//            }
//        }
//        return completionSource.task
//    }
    
    
    class func fetchAnimeProgress(onlyWatching: Bool = false) -> BFTask {
        
        let query = AnimeProgress.query()!
        query.fromLocalDatastore()
        query.includeKey("anime")
        query.limit = 1000
        if onlyWatching {
            query.whereKey("list", equalTo: "Watching")
        } else {
            query.whereKey("list", notEqualTo: "Watching")
        }
        return query.findObjectsInBackground()
//            .continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task: BFTask!) -> AnyObject! in
//            
//            return nil
//        })
        
//        let realm = Realm()
//        
//        var filterString = "syncState != \(SyncState.Deleted.rawValue)"
//        
//        if onlyWatching {
//            filterString += " && status == 'watching'"
//        } else {
//            filterString += " && status != 'watching'"
//        }
//        
//        let animeLibrary = realm.objects(AnimeProgress).filter(filterString)
//        
//        var idList: [Int] = []
//        var animeList: [Anime] = []
//        for animeProgress in animeLibrary {
//            idList.append(animeProgress.myAnimeListID)
//        }
//        // Fetch from disk then network
//        return fetchAnime(idList, fromLocalDatastore: true)
//        .continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
//            
//            if let result = task.result as? [Anime] where result.count > 0 {
//                animeList = result
//            }
//            return nil
//        }.continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
//            
//            let missingIdList = idList.filter({ (myAnimeListID: Int) -> Bool in
//                
//                var filteredAnime = animeList.filter({ $0.myAnimeListID == myAnimeListID })
//                return filteredAnime.count == 0
//            })
//            
//            if missingIdList.count != 0 {
//                println("Missing IDs \(missingIdList) fetching from network..")
//                return self.fetchAnime(missingIdList, includeAllData: true)
//            } else {
//                return nil
//            }
//            
//        }.continueWithExecutor( BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task: BFTask!) -> AnyObject! in
//            let pinName = Anime.PinName.InLibrary.rawValue
//            if let result = task.result as? [Anime] where result.count > 0 {
//                println("Found \(result.count) anime from network, saving with tag \(pinName)")
//                animeList += result
//                
//                PFObject.pinAllInBackground(result, withName: pinName)
//            }
//            
//            self.matchAnimeWithProgress(animeList)
//            // Update last sync date
//            NSUserDefaults.completedAction(self.LastSyncDateDefaultsKey)
//            return BFTask(result: animeList)
//        })
    }
    
    public class func fetchAnime(myAnimeListIDs: [Int], withPinName: String? = nil, fromLocalDatastore: Bool = false, includeAllData: Bool = false) -> BFTask {
        
        let query: PFQuery
        if includeAllData {
            query = Anime.queryIncludingAddData()
        } else {
            query = Anime.query()!
        }
        
        query.limit = 1000
        
        if fromLocalDatastore {
            query.fromLocalDatastore()
        }
        
        if let pinName = withPinName {
            query.fromPinWithName(pinName)
        }
        
        query.whereKey("myAnimeListID", containedIn: myAnimeListIDs)
        return query.findObjectsInBackground()
    }
    
    // MARK: - Anime Methods
    
    public class func matchAnimeWithProgress(animeList: [Anime]) -> BFTask {
        // Match all anime with it's progress..
        let animeLibraryQuery = AnimeProgress.query()!
        animeLibraryQuery.fromLocalDatastore()
        animeLibraryQuery.whereKey("anime", containedIn: animeList)
        return animeLibraryQuery.findObjectsInBackground().continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
            
            if let animeLibrary = task.result as? [AnimeProgress] {
                for anime in animeList {
                    if anime.progress != nil {
                        continue
                    }
                    for progress in animeLibrary {
                        if progress.anime.objectId == anime.objectId {
                            anime.progress = progress
                            break
                        }
                    }
                }
            }
            
            return nil
        }
    }
    
    // MARK: - Update Library Methods
    
    public class func addAnime(progress: AnimeProgress) -> BFTask {
        
        let malProgress = malProgressWithProgress(progress)
        return requestWithProgress(progress, router: Atarashii.Router.animeAdd(progress: malProgress)).continueWithBlock({ (task: BFTask!) -> AnyObject! in
            
            if let error = task.error {
                progress.myAnimeListSyncState = SyncState.Created.rawValue
                progress.saveEventually()
            }
            
            return nil
        })
    }
    
    public class func updateAnime(progress: AnimeProgress) -> BFTask {
        
        let malProgress = malProgressWithProgress(progress)
        return requestWithProgress(progress, router: Atarashii.Router.animeUpdate(progress: malProgress)).continueWithBlock({ (task: BFTask!) -> AnyObject! in
            
            if let error = task.error {
                progress.myAnimeListSyncState = SyncState.Updated.rawValue
                progress.saveEventually()
            }
            
            return nil
        })
    }
    
    public class func deleteAnime(progress: AnimeProgress) -> BFTask {
        
        return requestWithProgress(progress, router: Atarashii.Router.animeDelete(id: progress.anime.myAnimeListID)).continueWithBlock({ (task: BFTask!) -> AnyObject! in
            
            if let error = task.error {
                progress.myAnimeListSyncState = SyncState.Deleted.rawValue
                progress.saveEventually()
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
        return Atarashii.Progress(
            myAnimeListID: progress.anime.myAnimeListID,
            status: progress.myAnimeListList(),
            episodes: progress.watchedEpisodes,
            score: progress.score)
        
    }
    
}