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
        loadingView = LoaderView(parentView: view)
        
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
        let pin = anime.progress != nil
        anime.episodeList(pin: pin, tag: Anime.PinName.InLibrary).continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task: BFTask!) -> AnyObject! in
        
            self.dataSource = task.result as! [Episode]
            self.collectionView.animateFadeIn()
            self.loadingView.stopAnimating()

            return nil
        })
    }
    
    // MARK: - IBActions
    
    @IBAction func goToPressed(sender: UIBarButtonItem) {
        
        let dataSource = [["First Episode", "Next Episode", "Last Episode"]]
        
        DropDownListViewController.showDropDownListWith(sender: navigationController!.navigationBar, viewController: self, delegate: self, dataSource: dataSource)
        
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
        let episodeTitle = NSAttributedString(string: episode.title ?? "", attributes: titleAttributes)

        let attributedString = NSMutableAttributedString()
        attributedString.appendAttributedString(episodeNumber)
        attributedString.appendAttributedString(episodeTitle)
        
        cell.delegate = self
        cell.titleLabel.attributedText = attributedString
        cell.screenshotImageView.setImageFrom(urlString: episode.imageURLString(), animated: canFadeImages)
        
        cell.firstAiredLabel.text = episode.firstAired?.mediumDate() ?? ""
        
        if let progress = anime.progress {
            if progress.watchedEpisodes < indexPath.row + 1 {
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let episode = dataSource[indexPath.row]
        let episodeThreadController = ANParseKit.episodeThreadViewController()
        episodeThreadController.initWithEpisode(episode, anime: anime, postType:.Episode)
        if InAppController.purchasedAnyPro() == nil {
            episodeThreadController.interstitialPresentationPolicy = .Automatic
        }
        
        if let tabBar = tabBarController as? CustomTabBarController {
            tabBar.disableDragDismiss()
        }
        
        navigationController?.pushViewController(episodeThreadController, animated: true)
    }
}

extension EpisodesViewController: EpisodeCellDelegate {
    func episodeCellWatchedPressed(cell: EpisodeCell) {
        if let indexPath = collectionView.indexPathForCell(cell),
        var progress = anime.progress {
            
            let nextEpisode = indexPath.row + 1
            if progress.watchedEpisodes == nextEpisode {
                progress.watchedEpisodes = nextEpisode - 1
            } else {
                progress.watchedEpisodes = nextEpisode
            }
            
            progress.updatedEpisodes(anime.episodes)
            progress.saveEventually()
            LibrarySyncController.updateAnime(progress)
            
            NSNotificationCenter.defaultCenter().postNotificationName(ANAnimeKit.LibraryUpdatedNotification, object: nil)
            
            canFadeImages = false
            let indexPaths = collectionView.indexPathsForVisibleItems()
            collectionView.reloadItemsAtIndexPaths(indexPaths)
            canFadeImages = true
        }
        
    }
    func episodeCellMorePressed(cell: EpisodeCell) {
        let indexPath = collectionView.indexPathForCell(cell)!
        let episode = dataSource[indexPath.row]
        var textToShare = ""
            
        if anime.episodes == indexPath.row + 1 {
            textToShare = "Finished watching \(anime.title!) via #Aozora"
        } else {
            textToShare = "Just watched \(anime.title!) ep \(episode.number) via #Aozora"
        }
        
        var objectsToShare: [AnyObject] = [textToShare]
        if let image = cell.screenshotImageView.image {
            objectsToShare.append( image )
        }
        
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypeAddToReadingList,UIActivityTypePrint];
        self.presentViewController(activityVC, animated: true, completion: nil)
    
    }
}

extension EpisodesViewController: DropDownListDelegate {
    func selectedAction(trigger: UIView, action: String, indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            // Go to top
            self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
        case 1:
            // Go to next episode
            if let nextEpisode = anime.nextEpisode where nextEpisode > 0 {
                self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: nextEpisode - 1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: true)
            }
        case 2:
            // Go to bottom
            self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: dataSource.count - 1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Bottom, animated: true)
        default:
            break;
        }
    }
    
    func dropDownDidDismissed(selectedAction: Bool) {
        
    }
}