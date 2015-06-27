//
//  AnimeCell.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/4/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANParseKit
import ANCommonKit

class AnimeCell: UICollectionViewCell {
    
    enum CellStyle {
        case Chart
        case Poster
        case List
    }
    
    @IBOutlet weak var posterImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var etaLabel: UILabel?
    @IBOutlet weak var informationLabel: UILabel?
    @IBOutlet weak var ratingLabel: UILabel?
    @IBOutlet weak var genresLabel: UILabel?
    
    @IBOutlet weak var nextEpisodeNumberLabel: UILabel?
    @IBOutlet weak var etaTimeLabel: UILabel?
    
    var numberFormatter: NSNumberFormatter {
        struct Static {
            static let instance : NSNumberFormatter = {
                let formatter = NSNumberFormatter()
                formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
                formatter.maximumFractionDigits = 0
                return formatter
                }()
        }
        return Static.instance
    }
    
    class func registerNibFor(#collectionView: UICollectionView, style: CellStyle, reuseIdentifier: String) {
        switch style {
        case .Chart:
            let chartNib = UINib(nibName: "AnimeCell", bundle: nil)
            collectionView.registerNib(chartNib, forCellWithReuseIdentifier: reuseIdentifier)
        case .Poster:
            let posterNib = UINib(nibName: "AnimeCellPoster", bundle: nil)
            collectionView.registerNib(posterNib, forCellWithReuseIdentifier: reuseIdentifier)
        case .List:
            let listNib = UINib(nibName: "AnimeCellList", bundle: nil)
            collectionView.registerNib(listNib, forCellWithReuseIdentifier: reuseIdentifier)
        }
        
    }
    
    func configureWithAnime(
    anime: Anime,
    canFadeImages: Bool? = true,
    showEtaAsAired: Bool? = false) {

        posterImageView?.setImageFrom(urlString: anime.imageUrl, animated: canFadeImages)
        titleLabel.text = anime.title
        genresLabel?.text = ", ".join(anime.genres)
        
        var information = "\(anime.type) · "
            
        if let mainStudio = anime.studio.first {
            let studioString = mainStudio["studio_name"] as! String
            information += studioString
        } else {
            information += "?"
        }
            
        if let source = anime.source where count(source) != 0 {
            information += " · " + source
        }
        
        informationLabel?.text = information
        
        ratingLabel?.text = FontAwesome.Ranking.rawValue + String(format: " %.2f    ", anime.membersScore) + FontAwesome.Members.rawValue + " " + numberFormatter.stringFromNumber(anime.membersCount)!
    
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
