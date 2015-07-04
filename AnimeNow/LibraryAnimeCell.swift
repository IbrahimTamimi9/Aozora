//
//  LibraryAnimeCell.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/2/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import ANParseKit
import ANCommonKit
import Bolts

protocol LibraryAnimeCellDelegate: class {
    func cellPressedWatched(cell: LibraryAnimeCell, anime: Anime)
}
class LibraryAnimeCell: AnimeCell {
    
    weak var delegate: LibraryAnimeCellDelegate?
    var anime: Anime?
    
    @IBOutlet weak var userProgressLabel: UILabel!
    @IBOutlet weak var watchedButton: UIButton!
    @IBOutlet weak var episodeImageView: UIImageView!
    
    @IBAction func watchedPressed(sender: AnyObject) {
        delegate?.cellPressedWatched(self, anime:anime!)
    }
    
    override class func registerNibFor(#collectionView: UICollectionView, style: CellStyle, reuseIdentifier: String) {
        switch style {
        case .CheckInCompact:
            let chartNib = UINib(nibName: "CheckInCompact", bundle: nil)
            collectionView.registerNib(chartNib, forCellWithReuseIdentifier: reuseIdentifier)
        default:
            super.registerNibFor(collectionView: collectionView, style: style, reuseIdentifier: reuseIdentifier)
        }
        
    }
    
    override func configureWithAnime(
    anime: Anime,
    canFadeImages: Bool = true,
    showEtaAsAired: Bool = false,
    showShortEta: Bool = false) {
        
        super.configureWithAnime(anime, canFadeImages: canFadeImages, showEtaAsAired: showEtaAsAired, showShortEta: showShortEta)
        
        self.anime = anime
        
        if let progress = anime.progress {
            
            watchedButton.hidden = false
            let title = FontAwesome.Watched.rawValue + " Ep\((progress.episodes + 1))"
            watchedButton.setTitle(title, forState: UIControlState.Normal)
            
            userProgressLabel.text = "\(anime.type) · " + FontAwesome.Watched.rawValue + " \(progress.episodes)/\(anime.episodes)   " + FontAwesome.Ranking.rawValue + " \(progress.score)"
            
            setEpisodeImageView(anime, tag: .InLibrary, nextEpisode: progress.episodes)
            
            if let status = MALList(rawValue: progress.status) where status == .Completed || status == .Dropped {
                watchedButton.hidden = true
            }
        }
    }
    
    func setEpisodeImageView(anime: Anime, tag: Anime.PinName, nextEpisode: Int?) {
        episodeImageView.image = nil
        anime.episodeList(pin: true, tag: tag).continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task: BFTask!) -> AnyObject! in
            
            if let episodes = task.result as? [Episode],
                let nextEpisode = nextEpisode where episodes.count > nextEpisode {
                
                let episode = episodes[nextEpisode]
                self.episodeImageView.setImageFrom(urlString: episode.screenshot ?? anime.fanart ?? anime.imageUrl ?? "")
                
            } else {
                self.episodeImageView.setImageFrom(urlString: anime.fanart ?? anime.imageUrl ?? "")
            }
            return nil
        })
    }

}