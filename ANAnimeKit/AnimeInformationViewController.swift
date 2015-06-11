//
//  AnimeInformationViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/9/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import Shimmer
import ANCommonKit
import ANParseKit
import FontAwesome_iOS

enum AnimeSection: Int {
    case Synopsis = 0
    case Relations
    case Information
    case Characters
    case Reviews
    case ExternalLinks
    
    static var allSections: [AnimeSection] = [.Synopsis,.Relations,.Information,.Characters,.Reviews,.ExternalLinks]
}

public class AnimeInformationViewController: UIViewController {
    
    var canHideStatusBar = true
    var anime: Anime! {
        didSet {
            if anime.details.isDataAvailable() {
                animeTitle.text = anime.title
                tagsLabel.text = "\(anime.type) · \(ANAnimeKit.shortClassification(anime.details.classification)) · \(anime.episodes) eps · \(anime.duration) min · \(anime.year)"
                etaLabel.text = anime.status.capitalizedString
                ratingLabel.text = String(format:"%.2f", anime.membersScore)
                membersCountLabel.text = String(anime.membersCount)
                scoreRankLabel.text = "#\(anime.rank)"
                popularityRankLabel.text = "#\(anime.popularityRank)"
                
                posterImageView.setImageWithAnimationFrom(urlString: anime.imageUrl)
                
                if let fanartUrl = anime.fanart where count(fanartUrl) != 0 {
                    fanartImageView.setImageWithAnimationFrom(urlString: fanartUrl)
                } else {
                    fanartImageView.setImageWithAnimationFrom(urlString: anime.imageUrl)
                }
            
                tableView.dataSource = self
                tableView.delegate = self
                tableView.reloadData()    
            }
        }
    }
    
    @IBOutlet public weak var tableView: UITableView!
    @IBOutlet weak var shimeringView: FBShimmeringView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var openInAnimeTrakr: UILabel!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    @IBOutlet weak var shimeringViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var etaLabel: UILabel!
    
    @IBOutlet weak var animeTitle: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var membersCountLabel: UILabel!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var scoreRankLabel: UILabel!
    @IBOutlet weak var popularityRankLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var fanartImageView: UIImageView!
    
    public func initWithAnime(anime: Anime) {
        self.anime = anime
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        shimeringView.contentView = animeTitle
        shimeringView.shimmering = true
        
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        fetchCurrentAnime()
        
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
        canHideStatusBar = true
    }

    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        canHideStatusBar = false
    }
    
    func fetchCurrentAnime() {
        let query = Anime.query()!
        query.limit = 1
        query.whereKey("objectId", equalTo: anime.objectId!)
        query.includeKey("details")
        query.includeKey("cast")
        query.includeKey("characters")
        //query.includeKey("forum")
        query.includeKey("reviews")
        query.includeKey("relations")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            self.anime = objects?.first as! Anime
        }
    }

}

extension AnimeInformationViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
        var newOffset = 194-scrollView.contentOffset.y
        var shimmerOffset = newOffset-44
        shimeringViewTopConstraint.constant = (shimmerOffset > 20) ? shimmerOffset : 20
    
        if shimmerOffset > 20 {
            if canHideStatusBar {
                UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
                separatorView.hidden = true
            }
        } else {
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
            separatorView.hidden = false
        }
    
        topViewHeight.constant = newOffset
    }
}

extension AnimeInformationViewController: UITableViewDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if anime.isDataAvailable() {
            return AnimeSection.allSections.count;
        } else {
            return 0
        }
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows = 0
        switch AnimeSection(rawValue: section)! {
            case .Synopsis: numberOfRows = 1
            case .Relations: numberOfRows = anime.relations.totalRelations
            case .Information: numberOfRows = 11
            case .Characters: numberOfRows = 1
            case .Reviews: numberOfRows = 5
            case .ExternalLinks: numberOfRows = 2
        }
        
        return numberOfRows
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch AnimeSection(rawValue: indexPath.section)! {
        case .Synopsis:
            let cell = tableView.dequeueReusableCellWithIdentifier("SynopsisCell") as! SynopsisCell
            cell.synopsisLabel.text = anime.details.synopsis
            return cell
        case .Relations:
            let cell = tableView.dequeueReusableCellWithIdentifier("InformationCell") as! InformationCell
            let relation = anime.relations.relationAtIndex(indexPath.row)
            cell.titleLabel.text = relation.relationType.rawValue
            cell.detailLabel.text = relation.title
            return cell
        case .Information:
            let cell = tableView.dequeueReusableCellWithIdentifier("InformationCell") as! InformationCell
        
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Type"
                cell.detailLabel.text = anime.type
            case 1:
                cell.titleLabel.text = "Episodes"
                cell.detailLabel.text = anime.episodes.description
            case 2:
                cell.titleLabel.text = "Status"
                cell.detailLabel.text = anime.status.capitalizedString
            case 3:
                cell.titleLabel.text = "Aired"
                cell.detailLabel.text = "\(anime.startDate.mediumDate()) - \(anime.endDate.mediumDate())"
            case 4:
                cell.titleLabel.text = "Producers"
                cell.detailLabel.text = ", ".join(anime.producers)
            case 5:
                cell.titleLabel.text = "Genres"
                cell.detailLabel.text = ", ".join(anime.genres)
            case 6:
                cell.titleLabel.text = "Duration"
                cell.detailLabel.text = "\(anime.duration) min"
            case 7:
                cell.titleLabel.text = "Classification"
                cell.detailLabel.text = anime.details.classification
            case 8:
                cell.titleLabel.text = anime.details.englishTitles.count != 0 ? "English Title" : ""
                cell.detailLabel.text = "\n".join(anime.details.englishTitles)
            case 9:
                cell.titleLabel.text = "Japanese Title"
                cell.detailLabel.text = "\n".join(anime.details.japaneseTitles)
            case 10:
                cell.titleLabel.text = "Synonym"
                cell.detailLabel.text = "\n".join(anime.details.synonyms)
            default:
                break
            }
            return cell
        case .Characters:
            let cell = tableView.dequeueReusableCellWithIdentifier("SynopsisCell") as! SynopsisCell
            return cell
        case .Reviews:
            let cell = tableView.dequeueReusableCellWithIdentifier("ReviewCell") as! ReviewCell
            return cell
        case .ExternalLinks:
            let cell = tableView.dequeueReusableCellWithIdentifier("LinkCell") as! LinkCell
            return cell
        default:
            break;
        }
        
        return UITableViewCell()
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
        var title = ""
        
        switch AnimeSection(rawValue: section)! {
        case .Synopsis:
            title = "Synopsis"
            cell.allButton.hidden = false
            cell.allButton.setTitle("Read All ", forState: .Normal)
        case .Relations:
            title = "Relations"
            cell.allButton.hidden = true
        case .Information:
            title = "Information"
            cell.allButton.hidden = true
        case .Characters:
            title = "Characters"
            cell.allButton.hidden = false
            cell.allButton.setTitle("See All ", forState: .Normal)
        case .Reviews:
            title = "Reviews"
            cell.allButton.hidden = false
            cell.allButton.setTitle("Read All ", forState: .Normal)
        case .ExternalLinks:
            title = "External Links"
            cell.allButton.hidden = true
        }
        
        cell.titleLabel.text = title
        return cell
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 39.0
    }

}

extension AnimeInformationViewController: UITableViewDelegate {
    
}

