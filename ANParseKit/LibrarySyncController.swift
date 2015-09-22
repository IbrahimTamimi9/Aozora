//
//  LibrarySyncController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/2/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Parse
import Bolts
import Alamofire
import ANCommonKit

public let LibraryUpdatedNotification = "LibraryUpdatedNotification"
public let LibraryCreatedNotification = "LibraryCreatedNotification"

public class LibrarySyncController {
    
    public static let LastSyncDateDefaultsKey = "LibrarySync.LastSyncDate"
    
    public static let sharedInstance = LibrarySyncController()
    
    public let AnimeSync = "LibrarySync.AnimeSync"
    public let EpisodeSync = "LibrarySync.EpisodeSync"
    
    public enum Source {
        case MyAnimeList
        case Anilist
        case Hummingbird
    }
    
    // MARK: - Sync with Parse
    
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
                        print("Updated \(result.count) anime, saving with tag \(pinName)")
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
                        print("Updated \(result.count) episode, saving with tag \(pinName)")
                        NSUserDefaults.completedAction(actionID)
                        return PFObject.pinAllInBackground(result, withName: pinName)
                    })
                } else {
                    NSUserDefaults.completedAction(actionID)
                    return nil
                }         
        }
    }
    
    public class func syncAnimeProgressInformation() -> BFTask {
        
        let query = AnimeProgress.query()!
        query.limit = 1
        query.fromLocalDatastore()
        query.orderByDescending("updatedAt")
        return query.findObjectsInBackground()
            .continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
                
                if let result = task.result {
                    return BFTask(result: result)
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
                if let animeProgress = task.result as? [AnimeProgress] {
                    if let progress = animeProgress.last, let updatedAt = progress.updatedAt {
                        query.whereKey("updatedAt", greaterThan: updatedAt)
                        return query.findObjectsInBackground()
                    } else {
                        // Most likely syncing, do nothing
                        return BFTask(error: NSError(domain: "Aozora.Error", code: 0, userInfo: nil))
                    }
                } else if task.result == nil && task.error == nil {
                    return query.findObjectsInBackground()
                } else {
                    return task.error
                }
                
            }.continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
                
                if let result = task.result as? [AnimeProgress] where result.count != 0 {
                    return PFObject.unpinAllInBackground(result).continueWithBlock({ (task: BFTask!) -> AnyObject! in
                        print("Got \(result.count) AnimeProgress from Parse")
                        NSUserDefaults.completedAction(self.LastSyncDateDefaultsKey)
                        return PFObject.pinAllInBackground(result)
                    })
                } else {
                    NSUserDefaults.completedAction(self.LastSyncDateDefaultsKey)
                    return nil
                }
        }
    }
    
    // MARK: - Library management
    
    public class func fetchWatchingList(isRefreshing: Bool) -> BFTask {
        let shouldSyncData = NSUserDefaults.shouldPerformAction(LastSyncDateDefaultsKey, expirationDays: 1)
        
        if shouldSyncData || isRefreshing {
            print("Fetching all anime library from network..")
            
            var myAnimeListLibrary: [MALProgress] = []
            var allProgress: [AnimeProgress] = []
            
            let task = BFTask(result: nil).continueWithBlock({ (task: BFTask!) -> AnyObject! in
                
                var syncWithAServiceTask = BFTask(result: nil)
                let syncAnimeProgressTask = self.syncAnimeProgressInformation()
                
                // 1. For each source fetch all library
                if User.syncingWithMyAnimeList() {
                    print("Syncing with mal, continuing..")

                    syncWithAServiceTask = self.fetchMyAnimeListLibrary().continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
                        // 2. Save library in array
                        if let result = task.result["anime"] as? [[String: AnyObject]] {
                            print("MAL Library count \(result.count)")
                            for data in result {
                                let myAnimeListID = data["id"] as! Int
                                let status = data["watched_status"] as! String
                                let episodes = data["watched_episodes"] as! Int
                                let score = data["score"] as! Int
                                let malProgress = MALProgress(myAnimeListID: myAnimeListID, status: MALList(rawValue: status)!, episodes: episodes, score: score)
                                myAnimeListLibrary.append(malProgress)
                            }
                        }
                        return nil
                    })
                } else {
                    print("Not syncing with mal, continuing..")
                }
                
                return BFTask(forCompletionOfAllTasks: [syncWithAServiceTask, syncAnimeProgressTask])
                
            }).continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
                
                return self.fetchAozoraLibrary(onlyWatching: nil)
                
            }).continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
                
                // 3. Merge all existing libraries
                let parseLibrary = task.result as! [AnimeProgress]
                allProgress += parseLibrary
                
                // Caching ID to speed up loops
                for progress in parseLibrary {
                    progress.myAnimeListID = progress.anime.myAnimeListID
                }
                
                BFTask(result: nil).continueWithBlock({ (task: BFTask!) -> AnyObject! in
                    return self.mergeLibraries(myAnimeListLibrary, parseLibrary: parseLibrary)
                })
                
                // Create on PARSE
                var malProgressToCreate: [MALProgress] = []
                
                for malProgress in myAnimeListLibrary {
                    if parseLibrary.filter({$0.myAnimeListID == malProgress.myAnimeListID}).last == nil {
                        malProgressToCreate.append(malProgress)
                    }
                }
                
                let malProgressToCreateIDs = malProgressToCreate.map({ (malProgress: MALProgress) -> Int in
                    return malProgress.myAnimeListID
                })
                
                if malProgressToCreateIDs.count > 0 {
                    print("Need to create \(malProgressToCreateIDs.count) AnimeProgress on Parse")
                    let query = Anime.queryIncludingAddData()
                    query.whereKey("myAnimeListID", containedIn: malProgressToCreateIDs)
                    query.limit = 1000
                    return query.findObjectsInBackground()
                        .continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
                            let animeToCreate = task.result as! [Anime]
                            print("Creating \(animeToCreate.count) AnimeProgress on Parse")
                            var newProgress: [AnimeProgress] = []
                            for anime in animeToCreate {
                                // This prevents all anime object to be iterated thousands of times..
                                let myAnimeListID = anime.myAnimeListID
                                
                                if let malProgress = malProgressToCreate.filter({ $0.myAnimeListID == myAnimeListID }).last {
                                    // Creating on PARSE
                                    let malList = MALList(rawValue: malProgress.status)!
                                    let progress = AnimeProgress()
                                    progress.anime = anime
                                    progress.user = User.currentUser()!
                                    progress.startDate = NSDate()
                                    progress.updateList(malList)
                                    progress.watchedEpisodes = malProgress.episodes
                                    progress.collectedEpisodes = 0
                                    progress.score = malProgress.score
                                    newProgress.append(progress)
                                }
                            }
                            
                            allProgress += newProgress
                            PFObject.saveAllInBackground(newProgress).continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
                                return PFObject.pinAllInBackground(newProgress)
                            })
                            return nil
                        })
                } else {
                    return nil
                }
                
            }).continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
                
                return BFTask(result: allProgress)
                
            }).continueWithBlock({ (task: BFTask!) -> AnyObject! in
                if let error = task.error {
                    print(error)
                } else if let exception = task.exception {
                    print(exception)
                }
                
                return task
            })
            
            return task
        } else {
            return fetchAozoraLibrary(onlyWatching: true)
        }
    }
    
    public class func fetchTheRestOfLists() -> BFTask {

        return fetchAozoraLibrary(onlyWatching: false)
    }
    
    class func mergeLibraries(myAnimeListLibrary: [MALProgress], parseLibrary: [AnimeProgress]) -> BFTask {
        
        var updatedMyAnimeListLibrary = Set<MALProgress>()
        
        for progress in parseLibrary {
            // Check if user is syncing with MyAnimeList
            if User.syncingWithMyAnimeList() {
                if var malProgress = myAnimeListLibrary.filter({$0.myAnimeListID == progress.myAnimeListID}).last {
                    
                    // Update episodes
                    if malProgress.episodes > progress.watchedEpisodes {
                        // On Parse
                        print("updated episodes on parse \(progress.anime.title!)")
                        progress.watchedEpisodes = malProgress.episodes
                        progress.saveEventually()
                    } else if malProgress.episodes < progress.watchedEpisodes {
                        print("updated episodes on mal \(progress.anime.title!)")
                        // On MAL
                        malProgress.syncState = .Updated
                        malProgress.episodes = progress.watchedEpisodes
                        updatedMyAnimeListLibrary.insert(malProgress)
                    }
                    
                    // Update Score
                    if malProgress.score != progress.score {
                        if malProgress.score != 0 {
                            print("updated score on parse \(progress.anime.title!)")
                            progress.score = malProgress.score
                            progress.saveEventually()
                        } else if progress.score != 0 {
                            print("updated score on mal \(progress.anime.title!)")
                            malProgress.score = progress.score
                            malProgress.syncState = .Updated
                            updatedMyAnimeListLibrary.insert(malProgress)
                        }
                    }
                    
                    // Update list
                    let malListMAL = MALList(rawValue: malProgress.status)!
                    let malListParse = progress.myAnimeListList()
                    if malListMAL != malListParse {
                        print("List is different for: \(progress.anime.title!)")
                        var malList: MALList?
                        var aozoraList: AozoraList?
                        if malListMAL == .Completed || malListParse == .Completed {
                            if malListMAL != .Completed {
                                malList = .Completed
                            } else {
                                aozoraList = .Completed
                            }
                        } else if malListMAL == .Dropped || malListParse == .Dropped {
                            if malListMAL != .Dropped {
                                malList = .Dropped
                            } else {
                                aozoraList = .Dropped
                            }
                        } else if malListMAL == .OnHold || malListParse == .OnHold {
                            if malListMAL != .OnHold {
                                malList = .OnHold
                            } else {
                                aozoraList = .OnHold
                            }
                        } else if malListMAL == .Watching || malListParse == .Watching {
                            if malListMAL != .Watching {
                                malList = .Watching
                            } else {
                                aozoraList = .Watching
                            }
                        } else {
                            if malListMAL != .Planning {
                                malList = .Planning
                            } else {
                                aozoraList = .Planning
                            }
                        }
                        
                        if let status = malList {
                            print("updated list on mal \(progress.anime.title!)")
                            malProgress.status = status.rawValue
                            malProgress.syncState = .Updated
                            updatedMyAnimeListLibrary.insert(malProgress)
                        }
                        
                        if let aozoraList = aozoraList {
                            print("updated list on parse \(progress.anime.title!)")
                            progress.list = aozoraList.rawValue
                            progress.saveEventually()
                        }
                    }
                    
                } else {
                    print("Created \(progress.anime.title!) progress on mal")
                    // Create on MAL
                    var malProgress = MALProgress(myAnimeListID:
                        progress.anime.myAnimeListID,
                        status: progress.myAnimeListList(),
                        episodes: progress.watchedEpisodes,
                        score: progress.score)
                    malProgress.syncState = .Created
                    updatedMyAnimeListLibrary.insert(malProgress)
                }
            }
            
            // TODO: Check if user is syncing with Anilist
        }
        
        // Push updated objects to all sources
        for malProgress in updatedMyAnimeListLibrary {
            switch malProgress.syncState {
            case .Created:
                print("Creating on MAL \(malProgress.myAnimeListID)")
                self.addAnime(malProgress: malProgress)
            case .Updated:
                print("Updating on MAL \(malProgress.myAnimeListID)")
                self.updateAnime(malProgress: malProgress)
            default:
                break
            }
        }
        
        return BFTask(result: nil)
    }
    
    class func fetchAozoraLibrary(onlyWatching onlyWatching: Bool?) -> BFTask {
        
        let query = AnimeProgress.query()!
        query.fromLocalDatastore()
        query.includeKey("anime")
        query.limit = 1000
        if let onlyWatching = onlyWatching {
            if onlyWatching {
                query.whereKey("list", equalTo: "Watching")
            } else {
                query.whereKey("list", notEqualTo: "Watching")
            }
        }
        return query.findObjectsInBackground()
    }
    
    // MARK: - Class Methods
    
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
            
            return BFTask(result: animeList)
        }
    }
    
    // MARK: - General External Library Methods
    
    public class func addAnime(progress: AnimeProgress? = nil, malProgress: MALProgress? = nil) -> BFTask {
        let source = Source.MyAnimeList
        switch source {
        case .MyAnimeList:
            let malProgress = malProgress ?? animeProgressToAtarashiiObject(progress!)
            return myAnimeListRequestWithRouter(Atarashii.Router.animeAdd(progress: malProgress)).continueWithBlock({ (task: BFTask!) -> AnyObject! in
                return nil
            })
        case .Anilist:
            fallthrough
        case .Hummingbird:
            fallthrough
        default:
            return BFTask(result: nil)
        }
    }
    
    public class func updateAnime(progress: AnimeProgress? = nil, malProgress: MALProgress? = nil) -> BFTask {
        let source = Source.MyAnimeList
        switch source {
        case .MyAnimeList:
            let malProgress = malProgress ?? animeProgressToAtarashiiObject(progress!)
            return myAnimeListRequestWithRouter(Atarashii.Router.animeUpdate(progress: malProgress)).continueWithBlock({ (task: BFTask!) -> AnyObject! in
                return nil
            })
        case .Anilist:
            fallthrough
        case .Hummingbird:
            fallthrough
        default:
            return BFTask(result: nil)
        }
    }
    
    public class func deleteAnime(progress: AnimeProgress? = nil, malProgress: MALProgress? = nil) -> BFTask {
        let source = Source.MyAnimeList
        switch source {
        case .MyAnimeList:
            
            let malID = malProgress?.myAnimeListID ?? progress!.anime.myAnimeListID
            return myAnimeListRequestWithRouter(Atarashii.Router.animeDelete(id: malID)).continueWithBlock({ (task: BFTask!) -> AnyObject! in
                return nil
            })
        case .Anilist:
            fallthrough
        case .Hummingbird:
            fallthrough
        default:
            return BFTask(result: nil)
        }
    }
    
    // MARK: - MyAnimeList Library Methods
    
    class func fetchMyAnimeListLibrary() -> BFTask! {
        let completionSource = BFTaskCompletionSource()
        if let username = User.currentUser()!.myAnimeListUsername {
            
            let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
            let manager = Alamofire.Manager(configuration: configuration)
            let request = Atarashii.Router.animeList(username: username.lowercaseString)
            manager.request(request.URLRequest).validate().responseJSON {
                (req, res, result) -> Void in
                if result.isSuccess {
                    completionSource.setResult(result.value)
                } else {
                    completionSource.setError(nil)
                }
            }
        }
        return completionSource.task
    }

    
    class func myAnimeListRequestWithRouter(router: Atarashii.Router) -> BFTask {
        
        if !User.currentUserLoggedIn() {
            return BFTask(result: nil)
        }
        
        let completionSource = BFTaskCompletionSource()
        
        let malUsername = User.currentUser()!.myAnimeListUsername ?? ""
        let malPassword = User.currentUser()!.myAnimeListPassword ?? ""
        
        Alamofire.request(router)
            .authenticate(user: malUsername, password: malPassword)
            .validate()
            .responseJSON { (req, res, result) -> Void in
                if result.isSuccess {
                    completionSource.setResult(result.value)
                } else {
                    completionSource.setError(nil)
                }
        }
        return completionSource.task
        
    }
    
    class func animeProgressToAtarashiiObject(progress: AnimeProgress) -> MALProgress {
        return MALProgress(
            myAnimeListID: progress.anime.myAnimeListID,
            status: progress.myAnimeListList(),
            episodes: progress.watchedEpisodes,
            score: progress.score)
        
    }
    
    // MARK: - Anilist Library Methods
    
    // TODO
}