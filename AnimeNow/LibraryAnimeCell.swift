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
    
    func configureWithAnime(
    anime: Anime,
    listType: AnimeList,
    canFadeImages: Bool? = true,
    showEtaAsAired: Bool? = false) {
        
        super.configureWithAnime(anime, canFadeImages: canFadeImages, showEtaAsAired: showEtaAsAired)
        
        self.anime = anime
        
        let progress = anime.progress!
        
        watchedButton.hidden = false
        let title = FontAwesome.Watched.rawValue + " Ep\((progress.episodes + 1))"
        watchedButton.setTitle(title, forState: UIControlState.Normal)
        
        userProgressLabel.text = "\(anime.type) · " + FontAwesome.Watched.rawValue + " \(progress.episodes)/\(anime.episodes)   " + FontAwesome.Ranking.rawValue + " \(progress.score)"
        
        episodeImageView.image = nil
        anime.episodeList(pin: true).continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task: BFTask!) -> AnyObject! in
            
            if let episodes = task.result as? [Episode] {
                if episodes.count > progress.episodes {
                    let episode = episodes[progress.episodes]
                    self.episodeImageView.setImageFrom(urlString: episode.screenshot ?? anime.fanart ?? "")
                } else {
                    
                }
            }
            return nil
        })
        
        switch listType {
        case .Planning: fallthrough
        case .Watching: fallthrough
        case .OnHold: break
        case .Completed: fallthrough
        case .Dropped:
            watchedButton.hidden = true
        }   
    }
}