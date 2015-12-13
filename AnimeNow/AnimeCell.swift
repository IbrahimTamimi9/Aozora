//
//  AnimeCell.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/4/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANCommonKit
import ANParseKit

class AnimeCell: UICollectionViewCell {
    
    static let id = "AnimeCell"
    @IBOutlet weak var posterImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var etaLabel: UILabel?
    @IBOutlet weak var informationLabel: UILabel?
    @IBOutlet weak var ratingLabel: UILabel?
    @IBOutlet weak var genresLabel: UILabel?
    @IBOutlet weak var inLibraryView: UIView?
    
    // Poster only
    @IBOutlet weak var nextEpisodeNumberLabel: UILabel?
    @IBOutlet weak var etaTimeLabel: UILabel?
    @IBOutlet weak var posterEpisodeTitleLabel: UILabel?
    @IBOutlet weak var posterDimView: UIView?
    
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
    
    class func registerNibFor(collectionView collectionView: UICollectionView) {
        let chartNib = UINib(nibName: AnimeCell.id, bundle: nil)
        collectionView.registerNib(chartNib, forCellWithReuseIdentifier: AnimeCell.id)
    }
    
    func configureWithAnime(
        anime: Anime,
        canFadeImages: Bool = true,
        showEtaAsAired: Bool = false,
        showShortEta: Bool = false,
        publicAnime: Bool = false) {

        posterImageView?.setImageFrom(urlString: anime.imageUrl, animated: canFadeImages)
        titleLabel?.text = anime.title
        genresLabel?.text = anime.genres.joinWithSeparator(", ")
        
        updateInformationLabel(anime, informationLabel: informationLabel)
        
        ratingLabel?.text = FontAwesome.Ranking.rawValue + String(format: " %.2f    ", anime.membersScore) + FontAwesome.Members.rawValue + " " + numberFormatter.stringFromNumber(anime.membersCount)!
    
        if let nextEpisode = anime.nextEpisode {
            
            if showEtaAsAired {
                etaLabel?.textColor = UIColor.pumpkin()
                etaTimeLabel?.textColor = UIColor.pumpkin()
                if showShortEta {
                    etaLabel?.text = "Ep\(nextEpisode-1) Aired"
                } else {
                    etaLabel?.text = "Episode \(nextEpisode-1) - Aired"
                }
                
                etaTimeLabel?.text = "Ep\(nextEpisode-1) Aired"
            } else {
                
                let (days, hours, minutes) = etaForDate(anime.nextEpisodeDate!)
                let etaTime: String
                let shortEtaTime: String
                if days != 0 {
                    etaTime = "\(days)d \(hours)h \(minutes)m"
                    shortEtaTime = "\(days)d"
                    etaLabel?.textColor = UIColor.belizeHole()
                    etaTimeLabel?.textColor = UIColor.belizeHole()
                } else if hours != 0 {
                    etaTime = "\(hours)h \(minutes)m"
                    shortEtaTime = "\(hours)h"
                    etaLabel?.textColor = UIColor.nephritis()
                    etaTimeLabel?.textColor = UIColor.nephritis()
                    
                } else {
                    etaTime = "\(minutes)m"
                    shortEtaTime = etaTime
                    etaLabel?.textColor = UIColor.pumpkin()
                    etaTimeLabel?.textColor = UIColor.pumpkin()
                }
                
                if showShortEta {
                    etaLabel?.text = "Ep\(nextEpisode) - " + shortEtaTime
                } else {
                    etaLabel?.text = "Episode \(nextEpisode) - " + etaTime
                }
                
                
                etaTimeLabel?.text = etaTime
            }
            
            nextEpisodeNumberLabel?.text = nextEpisode.description
            posterEpisodeTitleLabel?.text = "Episode"
            posterDimView?.hidden = false
            
        } else {
            etaLabel?.text = ""
            nextEpisodeNumberLabel?.text = ""
            posterEpisodeTitleLabel?.text = ""
            posterDimView?.hidden = true
            
            if let status = AnimeStatus(rawValue: anime.status) where status == AnimeStatus.FinishedAiring {
                etaTimeLabel?.textColor = UIColor.belizeHole()
                etaTimeLabel?.text = "Aired"
            } else {
                etaTimeLabel?.textColor = UIColor.planning()
                etaTimeLabel?.text = "Not aired"
            }
        }
        
        if let progress = publicAnime ? anime.publicProgress : anime.progress {
            
            inLibraryView?.hidden = false
            switch progress.myAnimeListList() {
            case .Planning:
                inLibraryView?.backgroundColor = UIColor.planning()
            case .Watching:
                inLibraryView?.backgroundColor = UIColor.watching()
            case .Completed:
                inLibraryView?.backgroundColor = UIColor.completed()
            case .OnHold:
                inLibraryView?.backgroundColor = UIColor.onHold()
            case .Dropped:
                inLibraryView?.backgroundColor = UIColor.dropped()
            }
            
        } else {
            inLibraryView?.hidden = true
        }
        
    }
    
    func updateInformationLabel(anime: Anime, informationLabel: UILabel?) {
        var information = "\(anime.type) · "
        
        if let mainStudio = anime.studio.first {
            let studioString = mainStudio["studio_name"] as! String
            information += studioString
        } else {
            information += "?"
        }
        
        if let source = anime.source where source.characters.count != 0 {
            information += " · " + source
        }
        
        informationLabel?.text = information
    }
    
    // Helper date functions
    func etaForDate(nextDate: NSDate) -> (days: Int, hours: Int, minutes: Int) {
        let now = NSDate()
        let cal = NSCalendar.currentCalendar()
        let unit: NSCalendarUnit = [.Day, .Hour, .Minute]
        let components = cal.components(unit, fromDate: now, toDate: nextDate, options: [])
        
        return (components.day,components.hour, components.minute)
    }
    
}

// MARK: - Layout
extension AnimeCell {
    class func updateLayoutItemSizeWithLayout(layout: UICollectionViewFlowLayout, viewSize: CGSize) {
        let lineSpacing: CGFloat = 1
        let columns: CGFloat = UIDevice.isLandscape() ? 3 : 2
        let cellHeight: CGFloat = 132
        var cellWidth: CGFloat = 0
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = CGFloat(lineSpacing)
        
        if UIDevice.isPad() {
            cellWidth = viewSize.width / columns - columns * lineSpacing
        } else {
            cellWidth = viewSize.width
        }
        
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
    }
}
