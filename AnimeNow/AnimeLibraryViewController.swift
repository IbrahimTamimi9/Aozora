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
import ANAnimeKit
import XLPagerTabStrip
import RealmSwift

enum AnimeList: String {
    case Planning = "Planning"
    case Watching = "Watching"
    case Completed = "Completed"
    case OnHold = "On-Hold"
    case Dropped = "Dropped"
}

enum LibraryLayout: String {
    case CheckIn = "Check-In"
    case Compact = "Compact"
    case CheckInCompact = "Check-In Compact"
    
    static func allRawValues() -> [String] {
        return [
            LibraryLayout.CheckIn.rawValue,
            LibraryLayout.CheckInCompact.rawValue,
            LibraryLayout.Compact.rawValue
        ]
    }
}

class AnimeLibraryViewController: XLButtonBarPagerTabStripViewController {
    
    let SortTypeDefault = "Library.SortType."
    let LayoutTypeDefault = "Library.LayoutType."
    
    var allAnimeLists: [AnimeList] = [.Watching, .Planning, .OnHold, .Completed, .Dropped]
    var controllers: [AnimeListViewController] = []
    
    var currentConfiguration: Configuration {
        get {
            return configurations[Int(currentIndex)]
        }
        
        set (value) {
            configurations[Int(currentIndex)] = value
        }
    }
    var configurations: [Configuration] = []
    
    func sortTypeForList(list: AnimeList) -> SortType {
        let key = SortTypeDefault+list.rawValue
        if let sortType = NSUserDefaults.standardUserDefaults().objectForKey(key) as? String, let sortTypeEnum = SortType(rawValue: sortType) {
            return sortTypeEnum
        } else {
            return SortType.Title
        }
    }
    
    func setSortTypeForList(sort:SortType, list: AnimeList) {
        let key = SortTypeDefault+list.rawValue
        NSUserDefaults.standardUserDefaults().setObject(sort.rawValue, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func layoutTypeForList(list: AnimeList) -> LibraryLayout {
        let key = LayoutTypeDefault+list.rawValue
        if let layoutType = NSUserDefaults.standardUserDefaults().objectForKey(key) as? String, let layoutTypeEnum = LibraryLayout(rawValue: layoutType) {
            return layoutTypeEnum
        } else {
            switch list {
            case .Watching: fallthrough
            case .Planning: fallthrough
            case .OnHold:
                return LibraryLayout.CheckIn
            case .Completed: fallthrough
            case .Dropped:
                return LibraryLayout.Compact
            }
        }

    }
    
    func setLayoutTypeForList(layout:LibraryLayout, list: AnimeList) {
        let key = LayoutTypeDefault+list.rawValue
        NSUserDefaults.standardUserDefaults().setObject(layout.rawValue, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.isProgressiveIndicator = true
        self.buttonBarView.selectedBar.backgroundColor = UIColor.peterRiver()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateDataSource", name: ANAnimeKit.LibraryUpdatedNotification, object: nil)
     
        fetchAnimeList(false)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func updateDataSource() {
        fetchAnimeList(false)
    }
    
    func fetchAnimeList(isRefreshing: Bool) -> BFTask {
        return LibrarySyncController.fetchAnimeList(isRefreshing).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
            
            var animeList = task.result as! [Anime]
            var lists: [[Anime]] = [[],[],[],[],[]]
            
            for anime in animeList {
                let malList = MALList(rawValue: anime.progress!.status) ?? .Planning
                switch malList {
                case .Watching:
                    lists[0].append(anime)
                case .Planning:
                    lists[1].append(anime)
                case .OnHold:
                    lists[2].append(anime)
                case .Completed:
                    lists[3].append(anime)
                case .Dropped:
                    lists[4].append(anime)
                }
            }
            
            for index in 0...4 {
                self.controllers[index].animeList = lists[index]
            }
            
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
        
        // Initialize configurations
        for list in allAnimeLists {
            configurations.append(
                [
                    (FilterSection.View, layoutTypeForList(list).rawValue, LibraryLayout.allRawValues()),
                    (FilterSection.Sort, sortTypeForList(list).rawValue, [SortType.Title.rawValue, SortType.NextAiringEpisode.rawValue]),
                ]
            )
        }
        
        // Initialize controllers
        let storyboard = UIStoryboard(name: "Library", bundle: nil)
        
        var lists: [AnimeListViewController] = []
        
        for index in 0...4 {
            let controller = storyboard.instantiateViewControllerWithIdentifier("AnimeList") as! AnimeListViewController
            
            var animeList = allAnimeLists[index]
            
            controller.initWithList(animeList, configuration: configurations[index])
            controller.delegate = self
            
            lists.append(controller)
        }
        
        controllers = lists
        
        return lists
    }
}

extension AnimeLibraryViewController: FilterViewControllerDelegate {
    func finishedWith(#configuration: Configuration, selectedGenres: [String]) {

        let currentListIndex = Int(currentIndex)
        currentConfiguration = configuration
        controllers[currentListIndex].currentConfiguration = currentConfiguration
        
        if let value = currentConfiguration[0].value,
            let layoutType = LibraryLayout(rawValue: value) {
                setLayoutTypeForList(layoutType, list: allAnimeLists[currentListIndex])
        }
        
        if let value = currentConfiguration[1].value,
            let sortType = SortType(rawValue: value) {
                setSortTypeForList(sortType, list: allAnimeLists[currentListIndex])
        }
        
    }
}

extension AnimeLibraryViewController: AnimeListControllerDelegate {
    func controllerRequestRefresh() -> BFTask {
        return fetchAnimeList(true)
    }
}