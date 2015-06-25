//
//  AnimeCell.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/4/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANParseKit

class AnimeCell: UICollectionViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var etaLabel: UILabel?
    @IBOutlet weak var studioLabel: UILabel?
    @IBOutlet weak var sourceLabel: UILabel?
    @IBOutlet weak var genresLabel: UILabel?
    
    @IBOutlet weak var nextEpisodeNumberLabel: UILabel?
    @IBOutlet weak var etaTimeLabel: UILabel?
    
    func configureWithAnime(
        anime: Anime,
        canFadeImages: Bool? = true,
        showEtaAsAired: Bool? = false) {
    
        posterImageView?.setImageFrom(urlString: anime.imageUrl, animated: canFadeImages)
        titleLabel.text = anime.title
        genresLabel?.text = ", ".join(anime.genres)
        
        if let source = anime.source {
            sourceLabel?.text = "Source: \(source)"
        } else {
            sourceLabel?.text = ""
        }
        
        
        if let mainStudio = anime.studio.first {
            let studioString = mainStudio["studio_name"] as! String
            studioLabel?.text = "\(studioString)"
        } else {
            studioLabel?.text = ""
        }
        
        if var nextEpisode = anime.nextEpisode {
            
            if showEtaAsAired! {
                etaLabel?.textColor = UIColor.pumpkin()
                etaTimeLabel?.textColor = UIColor.pumpkin()
                etaLabel?.text = "Episode \(nextEpisode-1) - Aired"
                etaTimeLabel?.text = "Aired"
            } else {
                
                let (days, hours, minutes) = etaForDate(anime.nextEpisodeDate)
                let etaTime: String
                if days != 0 {
                    etaTime = "\(days)d \(hours)h \(minutes)m"
                    etaLabel?.textColor = UIColor.belizeHole()
                    etaTimeLabel?.textColor = UIColor.belizeHole()
                    etaLabel?.text = "Episode \(nextEpisode) - " + etaTime
                } else if hours != 0 {
                    etaTime = "\(hours)h \(minutes)m"
                    etaLabel?.textColor = UIColor.nephritis()
                    etaTimeLabel?.textColor = UIColor.nephritis()
                    etaLabel?.text = "Episode \(nextEpisode) - " + etaTime
                } else {
                    etaTime = "\(minutes)m"
                    etaLabel?.textColor = UIColor.pumpkin()
                    etaTimeLabel?.textColor = UIColor.pumpkin()
                    etaLabel?.text = "Episode \(nextEpisode) - \(minutes)m"
                }
                
                etaTimeLabel?.text = etaTime
            }
            
            nextEpisodeNumberLabel?.text = nextEpisode.description
            
        } else {
            etaLabel?.text = ""
        }
        
    }
    
    // Helper date functions
    func etaForDate(nextDate: NSDate) -> (days: Int, hours: Int, minutes: Int) {
        let now = NSDate()
        let cal = NSCalendar.currentCalendar()
        let unit: NSCalendarUnit = .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute
        let components = cal.components(unit, fromDate: now, toDate: nextDate, options: nil)
        
        return (components.day,components.hour, components.minute)
    }
    
}
