//
//  AnimeListViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/21/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class AnimeListViewController: UIViewController {
    
    var animeList: AnimeList!
    
    func initWithList(animeList: AnimeList) {
        self.animeList = animeList
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}



extension AnimeListViewController: XLPagerTabStripChildItem {
    func titleForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> String! {
        return animeList.rawValue
    }
    
    func colorForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> UIColor! {
        return UIColor.whiteColor()
    }
}
