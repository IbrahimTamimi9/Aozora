//
//  LibraryAnimeCell.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/2/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import ANParseKit
import ANAnimeKit
import ANCommonKit
import Bolts

protocol LibraryAnimeCellDelegate: class {
    func cellPressedWatched(cell: LibraryAnimeCell, anime: Anime)
    func cellPressedEpisodeThread(cell: LibraryAnimeCell, anime: Anime, episode: Episode)
}
class LibraryAnimeCell: AnimeCell {
    
    weak var delegate: LibraryAnimeCellDelegate?
    var anime: Anime?
    weak var episode: Episode?
    var currentCancellationToken: NSOperation?
    
    @IBOutlet weak var userProgressLabel: UILabel!
    @IBOutlet weak var watchedButton: UIButton!
    @IBOutlet weak var episodeImageView: UIImageView!
    
    @IBAction func watchedPressed(sender: AnyObject) {
        
        if let anime = anime, let progress = anime.progress {
            
            progress.watchedEpisodes += 1
            progress.updatedEpisodes(anime.episodes)
            progress.saveEventually()
            LibrarySyncController.updateAnime(progress: progress)
        }
        
        delegate?.cellPressedWatched(self, anime:anime!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "pressedEpisodeImageView:")
        gestureRecognizer.numberOfTouchesRequired = 1
        gestureRecognizer.numberOfTapsRequired = 1
        episodeImageView.addGestureRecognizer(gestureRecognizer)
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
            let title = FontAwesome.Watched.rawValue + " Ep\((progress.watchedEpisodes + 1))"
            watchedButton.setTitle(title, forState: UIControlState.Normal)
            
            userProgressLabel.text = "\(anime.type) · " + FontAwesome.Watched.rawValue + " \(progress.watchedEpisodes)/\(anime.episodes)   " + FontAwesome.Ranking.rawValue + " \(progress.score)"
            
            if progress.myAnimeListList() != .Completed {
                setEpisodeImageView(anime, tag: .InLibrary, nextEpisode: progress.watchedEpisodes)
            } else {
                episodeImageView.setImageFrom(urlString: anime.fanart ?? anime.imageUrl ?? "")
            }
            
            
            if progress.myAnimeListList() == .Completed || progress.myAnimeListList() == .Dropped || (progress.watchedEpisodes == anime.episodes && anime.episodes != 0) {
                watchedButton.hidden = true
            }
        }
    }
    
    func setEpisodeImageView(anime: Anime, tag: Anime.PinName, nextEpisode: Int?) {
        
        if let cancelToken = currentCancellationToken {
            cancelToken.cancel()
        }
        
        let newCancelationToken = NSOperation()
        currentCancellationToken = newCancelationToken
        
        episodeImageView.image = nil
        episode = nil
        anime.episodeList(pin: true, tag: tag).continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task: BFTask!) -> AnyObject! in
            
            if newCancelationToken.cancelled {
                return nil
            }
            
            if let episodes = task.result as? [Episode],
                let nextEpisode = nextEpisode where episodes.count > nextEpisode {
                
                let episode = episodes[nextEpisode]
                self.episode = episode
                self.episodeImageView.setImageFrom(urlString: episode.imageURLString())
                
            } else {
                self.episodeImageView.setImageFrom(urlString: anime.fanart ?? anime.imageUrl ?? "")
            }
            return nil
        })
    }
    
    // MARK: - IBActions
    
    func pressedEpisodeImageView(sender: AnyObject) {
        if let episode = episode {
            delegate?.cellPressedEpisodeThread(self, anime: episode.anime, episode: episode)
        }
    }

}