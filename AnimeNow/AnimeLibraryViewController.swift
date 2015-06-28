//
//  AnimeLibraryViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/21/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import XLPagerTabStrip

enum AnimeList: String {
    case Planning = "Planning"
    case Watching = "Watching"
    case Completed = "Completed"
    case OnHold = "On-Hold"
    case Dropped = "Dropped"
}

class AnimeLibraryViewController: XLButtonBarPagerTabStripViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isProgressiveIndicator = true
        self.buttonBarView.selectedBar.backgroundColor = UIColor.peterRiver()
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
    
    var currentConfiguration: Configuration =
    [
        (FilterSection.View, ViewType.Chart.rawValue, ViewType.allRawValues()),
        (FilterSection.Sort, SortBy.Rating.rawValue, [SortBy.Rating.rawValue, SortBy.Popularity.rawValue, SortBy.Title.rawValue, SortBy.NextAiringEpisode.rawValue,  SortBy.Newest.rawValue, SortBy.Oldest.rawValue]),
    ]
    
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
        
        let planning = storyboard.instantiateViewControllerWithIdentifier("AnimeList") as! AnimeListViewController
        let watching = storyboard.instantiateViewControllerWithIdentifier("AnimeList") as! AnimeListViewController
        let completed = storyboard.instantiateViewControllerWithIdentifier("AnimeList") as! AnimeListViewController
        let dropped = storyboard.instantiateViewControllerWithIdentifier("AnimeList") as! AnimeListViewController
        let onHold = storyboard.instantiateViewControllerWithIdentifier("AnimeList") as! AnimeListViewController
        
        planning.initWithList(.Planning)
        watching.initWithList(.Watching)
        completed.initWithList(.Completed)
        dropped.initWithList(.Dropped)
        onHold.initWithList(.OnHold)
        
        return [planning, watching, completed, dropped, onHold]
    }
}

extension AnimeLibraryViewController: FilterViewControllerDelegate {
    func finishedWith(#configuration: Configuration, selectedGenres: [String]) {
        currentConfiguration = configuration
        
        for (filterSection, value, _) in configuration {
            if let value = value {
                switch filterSection {
                case .Sort: break
                    //setOrder(by: SortBy(rawValue: value)!)
                case .View: break
                    //setLayout(type: ViewType(rawValue: value)!)
                default: break
                }
            }
        }
    }
}