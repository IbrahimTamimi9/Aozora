//
//  AnimeListViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/21/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANCommonKit
import ANAnimeKit
import ANParseKit
import XLPagerTabStrip
import RealmSwift

protocol AnimeListControllerDelegate: class {
    func controllerRequestRefresh() -> BFTask
}

class AnimeListViewController: UIViewController {
    
    weak var delegate: AnimeListControllerDelegate?
    
    var animator: ZFModalTransitionAnimator!
    var animeListType: AnimeList!
    var currentLayout: LibraryLayout = .CheckIn
    var currentSortType: SortType = .Title
    
    var currentConfiguration: Configuration! {
        didSet {
            
            for (filterSection, value, _) in currentConfiguration {
                if let value = value {
                    switch filterSection {
                    case .Sort:
                        let sortType = SortType(rawValue: value)!
                        if isViewLoaded() {
                            updateSortType(sortType)
                        } else {
                            currentSortType = sortType
                        }
                    case .View:
                        let layoutType = LibraryLayout(rawValue: value)!
                        if isViewLoaded() {
                            updateLayout(layoutType)
                        } else {
                            currentLayout = layoutType
                        }
                        
                    default: break
                    }
                }
            }
        }
    }
    var refreshControl = UIRefreshControl()
    
    var animeList: [Anime] = [] {
        didSet {
            if collectionView != nil {
                collectionView.reloadData()
                if animeListType == AnimeList.Watching {
                    collectionView.animateFadeIn()
                }
            }
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    func initWithList(animeList: AnimeList, configuration: Configuration) {
        self.animeListType = animeList
        self.currentConfiguration = configuration
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        LibraryAnimeCell.registerNibFor(collectionView: collectionView, style: .CheckInCompact, reuseIdentifier: "CheckInCompact")
        
        updateLayout(currentLayout)
        updateSortType(currentSortType)
        addRefreshControl()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshControl.endRefreshing()
        
    }
    
    func addRefreshControl() {
        refreshControl.tintColor = UIColor.lightGrayColor()
        refreshControl.addTarget(self, action: "refreshLibrary", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: collectionView.subviews.count - 1)
        collectionView.alwaysBounceVertical = true
    }
    
    func refreshLibrary() {
        
        delegate?.controllerRequestRefresh().continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task: BFTask!) -> AnyObject! in
            
            self.refreshControl.endRefreshing()
            
            if let error = task.error {
                println("\(error)")
            }
            return nil
        })
        
    }
    
    // MARK: - Sort and Layout
    
    func updateLayout(layout: LibraryLayout) {
        
        currentLayout = layout
        
        var size: CGSize?
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        switch currentLayout {
        case .CheckIn:
            size = CGSize(width: view.bounds.size.width, height: 132)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.minimumLineSpacing = 1
            layout.minimumInteritemSpacing = 1
        case .CheckInCompact:
            let margin: CGFloat = 4
            let columns: CGFloat = 2
            let totalSize: CGFloat = view.bounds.size.width - (margin * (columns + 1))
            let width = totalSize / columns
            size = CGSize(width: width, height: width/164*164)
            
            layout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
            layout.minimumLineSpacing = margin
            layout.minimumInteritemSpacing = margin
        case .Compact:
            let margin: CGFloat = 4
            let columns: CGFloat = 5
            let totalSize: CGFloat = view.bounds.size.width - (margin * (columns + 1))
            let width = totalSize / columns
            size = CGSize(width: width, height: width/83*116)
            
            layout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
            layout.minimumLineSpacing = margin
            layout.minimumInteritemSpacing = margin
        }
        layout.itemSize = size!
        
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }
    
    func updateSortType(sortType: SortType) {
        
        currentSortType = sortType
    
        switch self.currentSortType {
        case .Rating:
            animeList.sort({ $0.rank < $1.rank && $0.rank != 0 })
        case .Popularity:
            animeList.sort({ $0.popularityRank < $1.popularityRank })
        case .Title:
            animeList.sort({ $0.title < $1.title })
        case .NextAiringEpisode:
            animeList.sort({ (anime1: Anime, anime2: Anime) in
                
                let startDate1 = anime1.nextEpisodeDate ?? NSDate(timeIntervalSinceNow: 60*60*24*1000)
                let startDate2 = anime2.nextEpisodeDate ?? NSDate(timeIntervalSinceNow: 60*60*24*1000)
                return startDate1.compare(startDate2) == .OrderedAscending
            })
        case .Newest:
            animeList.sort({ (anime1: Anime, anime2: Anime) in
                
                let startDate1 = anime1.startDate ?? NSDate()
                let startDate2 = anime2.startDate ?? NSDate()
                return startDate1.compare(startDate2) == .OrderedDescending
            })
        case .Oldest:
            animeList.sort({ (anime1: Anime, anime2: Anime) in
                
                let startDate1 = anime1.startDate ?? NSDate()
                let startDate2 = anime2.startDate ?? NSDate()
                return startDate1.compare(startDate2) == .OrderedAscending
                
            })
        case .MyRating:
            animeList.sort({ (anime1: Anime, anime2: Anime) in
                
                let score1 = anime1.progress?.score ?? 0
                let score2 = anime2.progress?.score ?? 0
                return score1 > score2
            })
        case .NextEpisodeToWatch:
            animeList.sort({ (anime1: Anime, anime2: Anime) in
                
                let nextDate1 = anime1.nextEpisodeToWatchDate ?? NSDate(timeIntervalSinceNow: 60*60*24*365*100)
                let nextDate2 = anime2.nextEpisodeToWatchDate ?? NSDate(timeIntervalSinceNow: 60*60*24*365*100)
                return nextDate1.compare(nextDate2) == .OrderedAscending
            })
            break;
        default:
            break;
        }
        
        collectionView.reloadData()
    }
    
}


extension AnimeListViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return animeList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var identifier: String?
        switch currentLayout {
            
        case .CheckIn:
            identifier = "CheckIn"
            fallthrough
            
        case .CheckInCompact:
            if identifier == nil {
                identifier = "CheckInCompact"
            }
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier!, forIndexPath: indexPath) as! LibraryAnimeCell
            
            let anime = animeList[indexPath.row]
            cell.delegate = self
            cell.configureWithAnime(anime, showShortEta: true)
            cell.layoutIfNeeded()
            return cell
        
        case .Compact:
            identifier = "Compact"
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier!, forIndexPath: indexPath) as! BasicCollectionCell
            
            let anime = animeList[indexPath.row]
            cell.titleimageView.setImageFrom(urlString: anime.imageUrl, animated: false)
            cell.layoutIfNeeded()
            return cell
        }
    }
}



extension AnimeListViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let anime = animeList[indexPath.row]
        self.animator = presentAnimeModal(anime)
    }
}

extension AnimeListViewController: LibraryAnimeCellDelegate {
    func cellPressedWatched(cell: LibraryAnimeCell, anime: Anime) {
        if let progress = anime.progress,
            let indexPath = collectionView.indexPathForCell(cell) {

                if let list = MALList(rawValue: progress.status) where list == .Completed {
                    RateViewController.showRateDialogWith(self.tabBarController!, title: "You've finished\n\(anime.title!)!\ngive it a rating", initialRating: Float(progress.score)/2.0, anime: anime, delegate: self)
                }
                
                collectionView.reloadItemsAtIndexPaths([indexPath])
        }
    }
}

extension AnimeListViewController: RateViewControllerProtocol {
    func rateControllerDidFinishedWith(#anime: Anime, rating: Float) {
        RateViewController.updateAnime(anime, withRating: rating*2.0)
    }
}

extension AnimeListViewController: XLPagerTabStripChildItem {
    func titleForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> String! {
        return animeListType.rawValue
    }
    
    func colorForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> UIColor! {
        return UIColor.whiteColor()
    }
}
