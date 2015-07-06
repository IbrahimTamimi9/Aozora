//
//  EpisodeViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/24/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANCommonKit
import ANParseKit
import Bolts
import RealmSwift

extension EpisodesViewController: StatusBarVisibilityProtocol {
    func shouldHideStatusBar() -> Bool {
        return false
    }
    func updateCanHideStatusBar(canHide: Bool) {
    }
}

class EpisodesViewController: AnimeBaseViewController {
    
    var canFadeImages = true
    var laidOutSubviews = false
    var dataSource: [Episode] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var loadingView: LoaderView!
    
    let numberAttributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(16), NSForegroundColorAttributeName: UIColor.whiteColor()]
    let titleAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(16)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView = LoaderView(parentView: self.view)
        
        fetchEpisodes()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !laidOutSubviews {
            laidOutSubviews = true
            
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            var size = CGSize(width: view.bounds.size.width-20, height: 195)
            layout.itemSize = size
            layout.invalidateLayout()
        }
        
    }
    
    func fetchEpisodes() {
        
        loadingView.startAnimating()
        
        if let progress = anime.progress {
            
            anime.episodeList(pin: true, tag: Anime.PinName.InLibrary).continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task: BFTask!) -> AnyObject! in
            
                self.dataSource = task.result as! [Episode]
                self.collectionView.animateFadeIn()
                self.loadingView.stopAnimating()

                return nil
            })

        } else {
            println("Episode list from network..")
            Episode.query()!
                .whereKey("anime", equalTo: anime)
                .orderByAscending("number")
                .findObjectsInBackgroundWithBlock({ (episodes, error) -> Void in
                    
                    self.collectionView.animateFadeIn()
                    self.loadingView.stopAnimating()
                    if error == nil {
                        self.dataSource = episodes as! [Episode]
                    }
                    
                })
        }
        
    }
    
}


extension EpisodesViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EpisodeCell", forIndexPath: indexPath) as! EpisodeCell
        
        let episode = dataSource[indexPath.row]
        
        let episodeNumber = NSAttributedString(string: "Ep \(episode.number) · ", attributes: numberAttributes)
        let episodeTitle = NSAttributedString(string: episode.title, attributes: titleAttributes)

        let attributedString = NSMutableAttributedString()
        attributedString.appendAttributedString(episodeNumber)
        attributedString.appendAttributedString(episodeTitle)
        
        cell.delegate = self
        cell.titleLabel.attributedText = attributedString
        let screenshot = episode.screenshot != nil ? episode.screenshot! : anime.fanart ?? ""
        cell.screenshotImageView.setImageFrom(urlString: screenshot, animated: canFadeImages)
        
        cell.firstAiredLabel.text = episode.firstAired.mediumDate()
        
        if let progress = anime.progress {
            if progress.episodes < indexPath.row + 1 {
                cell.watchedButton.backgroundColor = UIColor.clearColor()
                cell.watchedButton.setImage(UIImage(named: "icon-check"), forState: .Normal)
            } else {
                cell.watchedButton.backgroundColor = UIColor.textBlue()
                cell.watchedButton.setImage(UIImage(named: "icon-check-selected"), forState: .Normal)
            }
        } else {
            cell.watchedButton.hidden = true
        }
        
        return cell
    }
}

extension EpisodesViewController: UICollectionViewDelegate {
    
}

extension EpisodesViewController: EpisodeCellDelegate {
    func episodeCellWatchedPressed(cell: EpisodeCell) {
        if let indexPath = collectionView.indexPathForCell(cell),
        var progress = anime.progress {
            Realm().write({ () -> Void in
                let nextEpisode = indexPath.row + 1
                if progress.episodes == nextEpisode {
                    progress.episodes = nextEpisode - 1
                } else {
                    progress.episodes = nextEpisode
                }
                
                progress.updatedEpisodes(self.anime.episodes)
            })
            LibrarySyncController.updateAnime(progress)
            
            NSNotificationCenter.defaultCenter().postNotificationName(ANAnimeKit.LibraryUpdatedNotification, object: nil)
            
            canFadeImages = false
            let indexPaths = collectionView.indexPathsForVisibleItems()
            collectionView.reloadItemsAtIndexPaths(indexPaths)
            canFadeImages = true
        }
        
    }
    func episodeCellMorePressed(cell: EpisodeCell) {
        let indexPath = collectionView.indexPathForCell(cell)
    }
}