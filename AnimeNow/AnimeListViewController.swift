//
//  AnimeListViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/21/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANCommonKit
import ANParseKit
import XLPagerTabStrip
import RealmSwift
import Parse

class AnimeListViewController: UIViewController {
    
    var animator: ZFModalTransitionAnimator!
    var animeListEnum: AnimeList!
    var animeList: [Anime] = [] {
        didSet {
            if collectionView != nil {
                collectionView.reloadData()
            }
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    func initWithList(animeList: AnimeList) {
        self.animeListEnum = animeList
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AnimeCell.registerNibFor(collectionView: collectionView, style: .Chart, reuseIdentifier: "AnimeCell")
        
    
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        var size = CGSize(width: view.bounds.size.width, height: 132)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 1
        layout.itemSize = size
        
        addRefreshControl()
    }
    
    func addRefreshControl() {
        var refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.lightGrayColor()
        refreshControl.addTarget(self, action: "refreshLibrary", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.addSubview(refreshControl)
        collectionView.alwaysBounceVertical = true
    }
    
    func refreshLibrary() {
        
    }
}


extension AnimeListViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return animeList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AnimeCell", forIndexPath: indexPath) as! AnimeCell
        
        let anime = animeList[indexPath.row]
        
        cell.configureWithAnime(anime)
        
        cell.layoutIfNeeded()
        return cell
    }
    
}



extension AnimeListViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let anime = animeList[indexPath.row]
        self.animator = presentAnimeModal(anime)
    }
}




extension AnimeListViewController: XLPagerTabStripChildItem {
    func titleForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> String! {
        return animeListEnum.rawValue
    }
    
    func colorForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> UIColor! {
        return UIColor.whiteColor()
    }
}
