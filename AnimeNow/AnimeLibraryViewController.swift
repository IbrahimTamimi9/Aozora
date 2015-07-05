//
//  AnimeLibraryViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/21/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANCommonKit
import ANParseKit
import Parse
import Bolts
import XLPagerTabStrip
import RealmSwift

enum AnimeList: String {
    case Planning = "Planning"
    case Watching = "Watching"
    case Completed = "Completed"
    case OnHold = "On-Hold"
    case Dropped = "Dropped"
}

class AnimeLibraryViewController: XLButtonBarPagerTabStripViewController {
    
    var planning: AnimeListViewController!
    var watching: AnimeListViewController!
    var completed: AnimeListViewController!
    var dropped: AnimeListViewController!
    var onHold: AnimeListViewController!
    
    var currentConfiguration: Configuration {
        get {
            return configurations[Int(currentIndex)]
        }
        
        set (value) {
            configurations[Int(currentIndex)] = value
        }
    }
    var configurations: [Configuration] =
    [
        [
            (FilterSection.View, LibraryLayout.CheckIn.rawValue, LibraryLayout.allRawValues()),
            (FilterSection.Sort, SortType.Title.rawValue, [SortType.Title.rawValue, SortType.NextAiringEpisode.rawValue]),
        ],
        [
            (FilterSection.View, LibraryLayout.CheckIn.rawValue, LibraryLayout.allRawValues()),
            (FilterSection.Sort, SortType.Title.rawValue, [SortType.Title.rawValue, SortType.NextAiringEpisode.rawValue]),
        ],
        [
            (FilterSection.View, LibraryLayout.CheckIn.rawValue, LibraryLayout.allRawValues()),
            (FilterSection.Sort, SortType.Title.rawValue, [SortType.Title.rawValue, SortType.NextAiringEpisode.rawValue]),
        ],
        [
            (FilterSection.View, LibraryLayout.Compact.rawValue, LibraryLayout.allRawValues()),
            (FilterSection.Sort, SortType.Title.rawValue, [SortType.Title.rawValue, SortType.NextAiringEpisode.rawValue]),
        ],
        [
            (FilterSection.View, LibraryLayout.Compact.rawValue, LibraryLayout.allRawValues()),
            (FilterSection.Sort, SortType.Title.rawValue, [SortType.Title.rawValue, SortType.NextAiringEpisode.rawValue]),
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isProgressiveIndicator = true
        self.buttonBarView.selectedBar.backgroundColor = UIColor.peterRiver()
        
        fetchAnimeList(false)
    }
    
    func fetchAnimeList(isRefreshing: Bool) -> BFTask {
        return LibrarySyncController.fetchAnimeList(isRefreshing).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
            
            var animeList = task.result as! [Anime]
            
            var planningList: [Anime] = []
            var watchingList: [Anime] = []
            var completedList: [Anime] = []
            var droppedList: [Anime] = []
            var onHoldList: [Anime] = []
            
            for anime in animeList {
                let malList = MALList(rawValue: anime.progress!.status) ?? .Planning
                switch malList {
                case .Planning:
                    planningList.append(anime)
                case .Watching:
                    watchingList.append(anime)
                case .Completed:
                    completedList.append(anime)
                case .Dropped:
                    droppedList.append(anime)
                case .OnHold:
                    onHoldList.append(anime)
                }
            }
            
            self.planning.animeList = planningList
            self.watching.animeList = watchingList
            self.completed.animeList = completedList
            self.dropped.animeList = droppedList
            self.onHold.animeList = onHoldList
            
            return nil
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func presentSearchPressed(sender: AnyObject) {
        
        if let tabBar = tabBarController {
            let controller = UIStoryboard(name: "Browse", bundle: nil).instantiateViewControllerWithIdentifier("Search") as! SearchViewController
            controller.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            controller.modalPresentationStyle = .OverCurrentContext
            tabBar.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func showFilterPressed(sender: AnyObject) {
        
        if let tabBar = tabBarController {
            let controller = UIStoryboard(name: "Browse", bundle: nil).instantiateViewControllerWithIdentifier("Filter") as! FilterViewController
            
            controller.delegate = self
            controller.initWith(configuration: currentConfiguration)
            controller.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
            tabBar.presentViewController(controller, animated: true, completion: nil)
        }
        
    }
}


extension AnimeLibraryViewController: XLPagerTabStripViewControllerDataSource {
    override func childViewControllersForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> [AnyObject]! {
        let storyboard = UIStoryboard(name: "Library", bundle: nil)
        
        planning = storyboard.instantiateViewControllerWithIdentifier("AnimeList") as! AnimeListViewController
        watching = storyboard.instantiateViewControllerWithIdentifier("AnimeList") as! AnimeListViewController
        completed = storyboard.instantiateViewControllerWithIdentifier("AnimeList") as! AnimeListViewController
        dropped = storyboard.instantiateViewControllerWithIdentifier("AnimeList") as! AnimeListViewController
        onHold = storyboard.instantiateViewControllerWithIdentifier("AnimeList") as! AnimeListViewController
        
        watching.initWithList(.Watching, configuration: configurations[0])
        planning.initWithList(.Planning, configuration: configurations[1])
        onHold.initWithList(.OnHold, configuration: configurations[2])
        completed.initWithList(.Completed, configuration: configurations[3])
        dropped.initWithList(.Dropped, configuration: configurations[4])
        
        watching.delegate = self
        planning.delegate = self
        onHold.delegate = self
        completed.delegate = self
        dropped.delegate = self
        
        return [watching, planning, onHold, completed, dropped]
    }
}

extension AnimeLibraryViewController: FilterViewControllerDelegate {
    func finishedWith(#configuration: Configuration, selectedGenres: [String]) {

        currentConfiguration = configuration
        
        switch Int(currentIndex) {
        case 0:
            watching.currentConfiguration = currentConfiguration
        case 1:
            planning.currentConfiguration = currentConfiguration
        case 2:
            onHold.currentConfiguration = currentConfiguration
        case 3:
            completed.currentConfiguration = currentConfiguration
        case 4:
            dropped.currentConfiguration = currentConfiguration
        default: break
        }
    
    }
}

extension AnimeLibraryViewController: AnimeListControllerDelegate {
    func controllerRequestRefresh() -> BFTask {
        return fetchAnimeList(true)
    }
}