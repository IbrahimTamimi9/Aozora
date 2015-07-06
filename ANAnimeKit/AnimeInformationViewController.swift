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
import XCDYouTubeKit
import RealmSwift

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
    let HeaderViewHeight: CGFloat = 274
    let TopBarHeight: CGFloat = 44
    let StatusBarHeight: CGFloat = 22
    
    var canHideStatusBar = true
    var subAnimator: ZFModalTransitionAnimator!
    var playerController: XCDYouTubeVideoPlayerViewController?
    
    @IBOutlet weak var listButton: UIButton!
    
    override var anime: Anime! {
        didSet {
            if anime.details.isDataAvailable() && isViewLoaded() {
                
                if let progress = anime.progress {
                    updateListButtonTitle(progress.status)
                } else {
                    updateListButtonTitle("Add to list ")
                }
                
                animeTitle.text = anime.title
                let episodes = (anime.episodes != 0) ? anime.episodes.description : "?"
                let duration = (anime.duration != 0) ? anime.duration.description : "?"
                let year = (anime.year != 0) ? anime.year.description : "?"
                tagsLabel.text = "\(anime.type) · \(ANAnimeKit.shortClassification(anime.details.classification)) · \(episodes) eps · \(duration) min · \(year)"
                
                if let status = AnimeStatus(rawValue: anime.status) {
                    switch status {
                    case .CurrentlyAiring:
                        etaLabel.text = "Airing    "
                        etaLabel.backgroundColor = UIColor(red: 155/255.0, green: 225/255.0, blue: 130/255.0, alpha: 1.0)
                    case .FinishedAiring:
                        etaLabel.text = "Aired    "
                        etaLabel.backgroundColor = UIColor(red: 225/255.0, green: 157/255.0, blue: 112/255.0, alpha: 1.0)
                    case .NotYetAired:
                        etaLabel.text = "Not Aired    "
                        etaLabel.backgroundColor = UIColor(red: 225/255.0, green: 215/255.0, blue: 124/255.0, alpha: 1.0)
                    }
                }
                
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
                
                if let youtubeID = anime.details.youtubeID where count(youtubeID) > 0 {
                    trailerButton.hidden = false
                    trailerButton.layer.borderWidth = 1.0;
                    trailerButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.5).CGColor;
                } else {
                    trailerButton.hidden = true
                }
            
                tableView.dataSource = self
                tableView.delegate = self
                tableView.reloadData()
            }
        }
    }
    
    var loadingView: LoaderView!
    
    @IBOutlet weak var trailerButton: UIButton!
    @IBOutlet weak var shimeringView: FBShimmeringView!
    @IBOutlet weak var separatorView: UIView!
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
        
        loadingView = LoaderView(parentView: self.view)
        
        ranksView.hidden = true
        fetchCurrentAnime()
        
        // Video notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerPlaybackDidFinish:", name: MPMoviePlayerPlaybackDidFinishNotification, object: nil)
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
    
    // MARK: - IBActions
    
    @IBAction func showFanart(sender: AnyObject) {
        
        var imageString = ""
        
        if let fanartUrl = anime.fanart where count(fanartUrl) != 0 {
            imageString = fanartUrl
        } else {
            imageString = anime.imageUrl
        }
        
        let imageURL = NSURL(string: imageString)
        presentImageViewController(fanartImageView, imageUrl: imageURL)
    }
    
    @IBAction func showPoster(sender: AnyObject) {
        
        let imageURL = NSURL(string: anime.imageUrl)
        presentImageViewController(posterImageView, imageUrl: imageURL!)
    }
   
    
    @IBAction func dismissViewController(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func playTrailerPressed(sender: AnyObject) {
        
        if let trailerURL = anime.details.youtubeID {
            playerController = XCDYouTubeVideoPlayerViewController(videoIdentifier: trailerURL)
            presentMoviePlayerViewControllerAnimated(playerController)
        }
    }
    
    @IBAction func addToListPressed(sender: AnyObject) {
        
        var progress = anime.progress
        
        var title: String = ""
        if progress == nil {
            title = "Add to list"
        } else {
            title = "Move to list"
        }
        
        var alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alert.addAction(UIAlertAction(title: "Watching", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction!) -> Void in
            self.updateProgressWithList(.Watching)
        }))
        alert.addAction(UIAlertAction(title: "Planning", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction!) -> Void in
            self.updateProgressWithList(.Planning)
        }))
        alert.addAction(UIAlertAction(title: "On-Hold", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction!) -> Void in
            self.updateProgressWithList(.OnHold)
        }))
        alert.addAction(UIAlertAction(title: "Completed", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction!) -> Void in
            self.updateProgressWithList(.Completed)
        }))
        alert.addAction(UIAlertAction(title: "Dropped", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction!) -> Void in
            self.updateProgressWithList(.Dropped)
        }))
        
        if let progress = progress {
            alert.addAction(UIAlertAction(title: "Remove from Library", style: UIAlertActionStyle.Destructive, handler: { (alertAction: UIAlertAction!) -> Void in
                
                self.anime.unpin()
                LibrarySyncController.deleteAnime(progress)
                let realm = Realm()
                realm.write {
                    realm.delete(progress)
                }
                
                NSNotificationCenter.defaultCenter().postNotificationName(ANAnimeKit.LibraryUpdatedNotification, object: nil)
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateProgressWithList(list: MALList) {
        
        let realm = Realm()
        
        if let progress = anime.progress {
            realm.write({ () -> Void in
                progress.status = list.rawValue
            })
            
            LibrarySyncController.updateAnime(progress)
            updateListButtonTitle(progress.status)
            
        } else {
            
            // Save
            var animeProgress = AnimeProgress()
            animeProgress.animeID = anime.myAnimeListID
            animeProgress.status = list.rawValue
            animeProgress.episodes = 0
            animeProgress.score = 0
            
            realm.write({ () -> Void in
                realm.add(animeProgress, update: true)
            })
            
            anime.pinWithName(Anime.PinName.InLibrary.rawValue)
            anime.progress = animeProgress
            
            LibrarySyncController.addAnime(animeProgress)
            
            updateListButtonTitle(animeProgress.status)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(ANAnimeKit.LibraryUpdatedNotification, object: nil)
    }
    
    func updateListButtonTitle(string: String) {
        
        if string == "plan to watch" {
            listButton.setTitle("Planning " + FontAwesome.AngleDown.rawValue, forState: .Normal)
        } else {
            listButton.setTitle(string.capitalizedString + " " + FontAwesome.AngleDown.rawValue, forState: .Normal)
        }
        
    }
    
    @IBAction func moreOptionsPressed(sender: AnyObject) {
        
        var progress = anime.progress
 
        var alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "Rate anime", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction!) -> Void in
            
        }))
        alert.addAction(UIAlertAction(title: "Enable reminders", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction!) -> Void in

        }))
        alert.addAction(UIAlertAction(title: "Share", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction!) -> Void in

        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    // MARK: - Helper Functions
    
    func hideStatusBar() -> Bool {
        var offset = HeaderViewHeight - self.scrollView().contentOffset.y - TopBarHeight
        if offset > StatusBarHeight {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Notifications
    
    func moviePlayerPlaybackDidFinish(notification: NSNotification) {
        playerController = nil;
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
            cell.linkLabel.text = link.site.rawValue
            switch link.site {
            case .Crunchyroll:
                cell.linkLabel.backgroundColor = UIColor.crunchyroll()
            case .OfficialSite:
                cell.linkLabel.backgroundColor = UIColor.officialSite()
            case .Daisuki:
                cell.linkLabel.backgroundColor = UIColor.daisuki()
            case .Funimation:
                cell.linkLabel.backgroundColor = UIColor.funimation()
            case .MyAnimeList:
                cell.linkLabel.backgroundColor = UIColor.myAnimeList()
            case .Hummingbird:
                cell.linkLabel.backgroundColor = UIColor.hummingbird()
            case .Anilist:
                cell.linkLabel.backgroundColor = UIColor.anilist()
            case .Other:
                cell.linkLabel.backgroundColor = UIColor.other()
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
        case .Relations:
            title = "Relations"
        case .Information:
            title = "Information"
        case .ExternalLinks:
            title = "External Links"
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

