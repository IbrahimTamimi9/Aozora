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
    case ExternalLinks
    
    static var allSections: [AnimeSection] = [.Synopsis,.Relations,.Information,.ExternalLinks]
}



extension AnimeInformationViewController: StatusBarVisibilityProtocol {
    func shouldHideStatusBar() -> Bool {
        return hideStatusBar()
    }
    func updateCanHideStatusBar(canHide: Bool) {
        canHideStatusBar = canHide
    }
}

public class AnimeInformationViewController: AnimeBaseViewController {
    
    let HeaderCellHeight: CGFloat = 39
    let HeaderViewHeight: CGFloat = 194
    let TopBarHeight: CGFloat = 44
    let StatusBarHeight: CGFloat = 22
    
    var canHideStatusBar = true
    var subAnimator: ZFModalTransitionAnimator!
    override var anime: Anime! {
        didSet {
            if anime.details.isDataAvailable() && isViewLoaded() {
                animeTitle.text = anime.title
                let episodes = (anime.episodes != 0) ? anime.episodes.description : "?"
                let duration = (anime.duration != 0) ? anime.duration.description : "?"
                let year = (anime.year != 0) ? anime.year.description : "?"
                tagsLabel.text = "\(anime.type) · \(ANAnimeKit.shortClassification(anime.details.classification)) · \(episodes) eps · \(duration) min · \(year)"
                etaLabel.text = anime.status.capitalizedString
                ratingLabel.text = String(format:"%.2f", anime.membersScore)
                membersCountLabel.text = String(anime.membersCount)
                scoreRankLabel.text = "#\(anime.rank)"
                popularityRankLabel.text = "#\(anime.popularityRank)"
                
                posterImageView.setImageFrom(urlString: anime.imageUrl)
                
                if let fanartUrl = anime.fanart where count(fanartUrl) != 0 {
                    fanartImageView.setImageFrom(urlString: fanartUrl)
                } else {
                    fanartImageView.setImageFrom(urlString: anime.imageUrl)
                }
            
                tableView.dataSource = self
                tableView.delegate = self
                tableView.reloadData()
            }
        }
    }
    
    var loadingView: LoaderView!
    
    @IBOutlet weak var shimeringView: FBShimmeringView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var openInAnimeTrakr: UIButton!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    @IBOutlet weak var shimeringViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var ranksView: UIView!
    
    @IBOutlet weak var animeTitle: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var membersCountLabel: UILabel!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var scoreRankLabel: UILabel!
    @IBOutlet weak var popularityRankLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var fanartImageView: UIImageView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        shimeringView.contentView = animeTitle
        shimeringView.shimmering = true
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        loadingView = LoaderView(viewController: self)
        
        ranksView.hidden = true
        fetchCurrentAnime()
        
        openInAnimeTrakr.hidden = anime.traktID != 0 ? false : true
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        canHideStatusBar = true
        self.scrollViewDidScroll(tableView)
    }
    
    func fetchCurrentAnime() {
        loadingView.startAnimating()
        let query = Anime.queryWith(objectID: anime.objectId!)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            self.loadingView.stopAnimating()
            self.ranksView.hidden = false
            self.anime = objects?.first as! Anime
        }
    }
    
    @IBAction func openInAnimeTrakr(sender: AnyObject) {
        
        if let url = NSURL(scheme: "animetrakr", host: nil, path: "/identifier/\(anime.myAnimeListID)") {
            
            let animeTrakrInstalled = UIApplication.sharedApplication().canOpenURL(url)
            
            if animeTrakrInstalled {
                UIApplication.sharedApplication().openURL(url)
            } else {
                let appstoreURL = NSURL(string: "https://userpub.itunes.apple.com/WebObjects/MZUserPublishing.woa/wa/addUserReview?type=Purple+Software&id=590452826&mt=8&o=i")!
                UIApplication.sharedApplication().openURL(appstoreURL)
            }
        }
    }
    
    @IBAction func dismissViewController(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func hideStatusBar() -> Bool {
        var offset = HeaderViewHeight - self.scrollView().contentOffset.y - TopBarHeight
        if offset > StatusBarHeight {
            return true
        } else {
            return false
        }
    }

}

extension AnimeInformationViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
        var newOffset = HeaderViewHeight-scrollView.contentOffset.y
        var topBarOffset = newOffset - TopBarHeight
        shimeringViewTopConstraint.constant = (topBarOffset > StatusBarHeight) ? topBarOffset : StatusBarHeight
    
        if topBarOffset > StatusBarHeight {
            if canHideStatusBar {
                UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
                separatorView.hidden = true
                closeButton.hidden = true
            }
        } else {
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
            separatorView.hidden = false
            closeButton.hidden = false
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
            case .ExternalLinks: numberOfRows = anime.externalLinks.count
        }
        
        return numberOfRows
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch AnimeSection(rawValue: indexPath.section)! {
        case .Synopsis:
            let cell = tableView.dequeueReusableCellWithIdentifier("SynopsisCell") as! SynopsisCell
            if let synopsis = anime.details.synopsis, let data = synopsis.dataUsingEncoding(NSUnicodeStringEncoding) {
                let font = UIFont.systemFontOfSize(15)
            
                if let attributedString = NSMutableAttributedString(
                    data: data,
                    options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType],
                    documentAttributes: nil
                    , error: nil) {
                    attributedString.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, attributedString.length))
                    cell.synopsisLabel.attributedText = attributedString
                } else {
                    cell.synopsisLabel.text = ""
                }
                
            } else {
                cell.synopsisLabel.text = ""
            }
            
            cell.layoutIfNeeded()
            return cell
        case .Relations:
            let cell = tableView.dequeueReusableCellWithIdentifier("InformationCell") as! InformationCell
            let relation = anime.relations.relationAtIndex(indexPath.row)
            cell.titleLabel.text = relation.relationType.rawValue
            cell.detailLabel.text = relation.title
            cell.layoutIfNeeded()
            return cell
        case .Information:
            let cell = tableView.dequeueReusableCellWithIdentifier("InformationCell") as! InformationCell
        
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Type"
                cell.detailLabel.text = anime.type
            case 1:
                cell.titleLabel.text = "Episodes"
                cell.detailLabel.text = (anime.episodes != 0) ? anime.episodes.description : "?"
            case 2:
                cell.titleLabel.text = "Status"
                cell.detailLabel.text = anime.status.capitalizedString
            case 3:
                cell.titleLabel.text = "Aired"
                let startDate = anime.startDate != nil && anime.startDate?.compare(NSDate(timeIntervalSince1970: 0)) != NSComparisonResult.OrderedAscending ? anime.startDate!.mediumDate() : "?"
                let endDate = anime.endDate != nil && anime.endDate?.compare(NSDate(timeIntervalSince1970: 0)) != NSComparisonResult.OrderedAscending ? anime.endDate!.mediumDate() : "?"
                cell.detailLabel.text = "\(startDate) - \(endDate)"
            case 4:
                cell.titleLabel.text = "Producers"
                cell.detailLabel.text = ", ".join(anime.producers)
            case 5:
                cell.titleLabel.text = "Genres"
                cell.detailLabel.text = ", ".join(anime.genres)
            case 6:
                cell.titleLabel.text = "Duration"
                let duration = (anime.duration != 0) ? anime.duration.description : "?"
                cell.detailLabel.text = "\(duration) min"
            case 7:
                cell.titleLabel.text = "Classification"
                cell.detailLabel.text = anime.details.classification
            case 8:
                cell.titleLabel.text = "English Titles"
                cell.detailLabel.text = anime.details.englishTitles.count != 0 ? "\n".join(anime.details.englishTitles) : "-"
            case 9:
                cell.titleLabel.text = "Japanese Titles"
                cell.detailLabel.text = anime.details.japaneseTitles.count != 0 ? "\n".join(anime.details.japaneseTitles) : "-"
            case 10:
                cell.titleLabel.text = "Synonyms"
                cell.detailLabel.text = anime.details.synonyms.count != 0 ? "\n".join(anime.details.synonyms) : "-"
            default:
                break
            }
            cell.layoutIfNeeded()
            return cell
        
        case .ExternalLinks:
            let cell = tableView.dequeueReusableCellWithIdentifier("LinkCell") as! LinkCell
            
            let link = anime.linkAtIndex(indexPath.row)
            cell.linkButton.setTitle(link.site.rawValue, forState: UIControlState.Normal)
            switch link.site {
            case .Crunchyroll:
                cell.linkButton.backgroundColor = UIColor.crunchyroll()
            case .OfficialSite:
                cell.linkButton.backgroundColor = UIColor.officialSite()
            case .Daisuki:
                cell.linkButton.backgroundColor = UIColor.daisuki()
            case .Funimation:
                cell.linkButton.backgroundColor = UIColor.funimation()
            case .MyAnimeList:
                cell.linkButton.backgroundColor = UIColor.myAnimeList()
            case .Hummingbird:
                cell.linkButton.backgroundColor = UIColor.hummingbird()
            case .Anilist:
                cell.linkButton.backgroundColor = UIColor.anilist()
            case .Other:
                cell.linkButton.backgroundColor = UIColor.other()
            }
            return cell

        }
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
        var title = ""
        
        switch AnimeSection(rawValue: section)! {
        case .Synopsis:
            title = "Synopsis"
            cell.allButton.hidden = true
        case .Relations:
            title = "Relations"
            cell.allButton.hidden = true
        case .Information:
            title = "Information"
            cell.allButton.hidden = true
        case .ExternalLinks:
            title = "External Links"
            cell.allButton.hidden = true
        }
        
        cell.titleLabel.text = title
        return cell.contentView
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, numberOfRowsInSection: section) > 0 ? HeaderCellHeight : 0
    }

}

extension AnimeInformationViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = AnimeSection(rawValue: indexPath.section)!
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch section {
            
        case .Synopsis:
            let synopsisCell = tableView.cellForRowAtIndexPath(indexPath) as! SynopsisCell
            synopsisCell.synopsisLabel.numberOfLines = (synopsisCell.synopsisLabel.numberOfLines == 8) ? 0 : 8
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                tableView.beginUpdates()
                tableView.endUpdates()
            })
            
        case .Relations:
            
            let relation = anime.relations.relationAtIndex(indexPath.row)
            // TODO: Parse is fetching again inside presenting AnimeInformationVC
            let query = Anime.queryWith(malID: relation.animeID)
            query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                let anime = objects?.first as! Anime
                
                let tabBarController = ANAnimeKit.rootTabBarController()
                tabBarController.initWithAnime(anime)
                
                self.subAnimator = ZFModalTransitionAnimator(modalViewController: tabBarController)
                self.subAnimator.dragable = true
                self.subAnimator.direction = ZFModalTransitonDirection.Bottom
                
                tabBarController.animator = self.subAnimator
                tabBarController.transitioningDelegate = self.subAnimator;
                tabBarController.modalPresentationStyle = UIModalPresentationStyle.Custom;
                
                self.presentViewController(tabBarController, animated: true, completion: nil)
                
            }

        case .Information:break
        case .ExternalLinks:
            let link = anime.linkAtIndex(indexPath.row)
            
            let (navController, webController) = ANCommonKit.webViewController()
            webController.initialUrl = NSURL(string: link.url)
            presentViewController(navController, animated: true, completion: nil)
        default: break
        }

    }
}

