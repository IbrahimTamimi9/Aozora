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