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
        loadingView = LoaderView(viewController: self)
        
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
            
        cell.titleLabel.attributedText = attributedString
        let screenshot = episode.screenshot != nil ? episode.screenshot! : anime.fanart ?? ""
        cell.screenshotImageView.setImageFrom(urlString: screenshot)
        
        return cell
    }
}

extension EpisodesViewController: UICollectionViewDelegate {
    
}