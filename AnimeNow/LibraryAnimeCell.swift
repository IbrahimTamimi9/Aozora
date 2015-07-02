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
protocol LibraryAnimeCellDelegate: class {
    func cellPressedWatched(cell: LibraryAnimeCell, anime: Anime)
}
class LibraryAnimeCell: AnimeCell {
    
    weak var delegate: LibraryAnimeCellDelegate?
    var anime: Anime?
    
    @IBOutlet weak var userProgressLabel: UILabel!
    @IBOutlet weak var watchedButton: UIButton!
    
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
        
        userProgressLabel.hidden = false
        watchedButton.hidden = false
        let title = FontAwesome.Watched.rawValue + " Ep\((progress.episodes + 1))"
        watchedButton.setTitle(title, forState: UIControlState.Normal)
        
        userProgressLabel.text = FontAwesome.Watched.rawValue + " \(progress.episodes)/\(anime.episodes)   " + FontAwesome.Ranking.rawValue + " \(progress.score)"
        
        switch listType {
        case .Planning:
            userProgressLabel.hidden = true
            fallthrough
        case .Watching: fallthrough
        case .OnHold:
            break
        case .Completed: fallthrough
        case .Dropped:
            watchedButton.hidden = true
        }   
    }
}