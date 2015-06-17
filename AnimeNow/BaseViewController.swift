//
//  ChartViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/4/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANParseKit
import SDWebImage
import Alamofire
import ANAnimeKit
import ANCommonKit

enum OrderBy: String {
    case Rating = "Rating"
    case Popularity = "Popularity"
    case Title = "Title"
    case NextAiringEpisode = "Next Airing Episode"
    
    static func allItems() -> [String] {
        return [
            OrderBy.Rating.rawValue,
            OrderBy.Popularity.rawValue,
            OrderBy.Title.rawValue,
            OrderBy.NextAiringEpisode.rawValue
        ]
    }
}

enum ViewType: String {
    case Chart = "Chart"
    case List = "List"
    case Poster = "Poster"
    
    static func allItems() -> [String] {
        return [
            ViewType.Chart.rawValue,
            ViewType.List.rawValue,
            ViewType.Poster.rawValue
        ]
    }
}

class BaseViewController: UIViewController {
    
    let FirstHeaderCellHeight: CGFloat = 88.0
    let HeaderCellHeight: CGFloat = 44.0
    let angleDownIcon = NSString.fontAwesomeIconStringForIconIdentifier("icon-angle-down")
    
    var canFadeImages = true
    var showTableView = true
    var currentOrder: OrderBy = .Rating
    var currentViewType: ViewType = .Chart
    var timer: NSTimer!
    var animator: ZFModalTransitionAnimator!
    
    var dataSource: [[Anime]] = [] {
        didSet {
            filteredDataSource = dataSource
        }
    }
    
    var filteredDataSource: [[Anime]] = [] {
        didSet {
            canFadeImages = false
            self.collectionView.reloadData()
            canFadeImages = true
        }
    }

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var navigationBarTitle: UILabel!
    
    @IBOutlet weak var orderTitleLabel: UILabel!
    @IBOutlet weak var orderButton: UIButton!
    
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var viewButton: UIButton!
    
    var loadingView: LoaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.hidesBarsOnTap = false
        
        setViewType(currentViewType)
        
        collectionView.alpha = 0.0
        
        timer = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: "updateETACells", userInfo: nil, repeats: true)
        
        loadingView = LoaderView()
        loadingView.addToViewController(self)
        loadingView.startAnimating()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if loadingView.animating == false {
            loadingView.stopAnimating()
            collectionView.animateFadeIn()
        }
        
        setNeedsStatusBarAppearanceUpdate()
        view.setNeedsUpdateConstraints()
        view.layoutIfNeeded()
        navigationController?.navigationBar.setNeedsUpdateConstraints()
        navigationController?.navigationBar.layoutIfNeeded()
    }
    
    func getAnilistAccessToken() {
        let expirationDate = NSUserDefaults.standardUserDefaults().objectForKey("expiration_date") as? NSDate
        let accessToken = NSUserDefaults.standardUserDefaults().stringForKey("access_token")
        
        if accessToken == nil || expirationDate?.compare(NSDate()) == .OrderedAscending {
            Alamofire.request(AniList.Router.requestAccessToken())
                .validate()
                .responseJSON { (req, res, JSON, error) in
                    
                    if error == nil {
                        
                        let dictionary = (JSON as! NSDictionary)
                        println(dictionary["access_token"])
                        NSUserDefaults.standardUserDefaults().setObject(dictionary["access_token"], forKey: "access_token")
                        NSUserDefaults.standardUserDefaults().setObject(NSDate(timeIntervalSinceNow: dictionary["expires_in"] as! Double), forKey: "expiration_date")
                        NSUserDefaults.standardUserDefaults().synchronize()
                    }else {
                        println(error)
                    }
            }
        }
    }
    
    // MARK: - UI Functions
    
    func updateETACells() {
        canFadeImages = false
        let indexPaths = self.collectionView.indexPathsForVisibleItems()
        self.collectionView.reloadItemsAtIndexPaths(indexPaths)
        canFadeImages = true
    }
    
    // MARK: - Utility Functions
    
    func order(#by: OrderBy) {
        
        currentOrder = by
        orderTitleLabel.text = currentOrder.rawValue
        dataSource = dataSource.map() { (var animeArray) -> [Anime] in
            switch self.currentOrder {
            case .Rating:
                animeArray.sort({ $0.rank < $1.rank})
            case .Popularity:
                animeArray.sort({ $0.popularityRank < $1.popularityRank})
            case .Title:
                animeArray.sort({ $0.title < $1.title})
            case .NextAiringEpisode:
                animeArray.sort({ $0.nextEpisodeDate.compare($1.nextEpisodeDate) == .OrderedAscending })
            }
            return animeArray
        }
        
        // Filter
        searchBar(searchBar, textDidChange: searchBar.text)
    }
    
    func orderNextAiringEpisode(var animeArray: [Anime]) {
        animeArray.sort({ $0.nextEpisodeDate.compare($1.nextEpisodeDate) == .OrderedAscending })
    }
    
    func setViewType(viewType: ViewType) {
        
        currentViewType = viewType
        viewTitleLabel.text = currentViewType.rawValue
        var size: CGSize
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        switch currentViewType {
        case .Chart:
            size = CGSize(width: view.bounds.size.width, height: 132)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.minimumLineSpacing = 1
        case .Poster:
            size = CGSize(width: 100, height: 164)
            let inset: CGFloat = (view.bounds.size.width - (100*3))/4
            layout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
            layout.minimumLineSpacing = inset
        case .List:
            size = CGSize(width: view.bounds.size.width, height: 52)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.minimumLineSpacing = 1
        }
        
        layout.itemSize = size
        
        canFadeImages = false
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
        canFadeImages = true
    }
    
    func showDropDownController(sender: UIView, dataSource: [String], imageDataSource: [String]? = []) {
        let frameRelativeToViewController = sender.convertRect(sender.bounds, toView: view)
        
        let controller = ANCommonKit.dropDownListViewController()
        controller.delegate = self
        controller.setDataSource(sender, dataSource: dataSource, yPosition: CGRectGetMaxY(frameRelativeToViewController), imageDataSource: imageDataSource)
        controller.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        controller.modalPresentationStyle = .OverCurrentContext
        self.tabBarController?.presentViewController(controller, animated: true, completion: nil)
    }
    
    // Helper date functions
    func etaForDate(nextDate: NSDate) -> (days: Int, hours: Int, minutes: Int) {
        let now = NSDate()
        let cal = NSCalendar.currentCalendar()
        let unit: NSCalendarUnit = .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute
        let components = cal.components(unit, fromDate: now, toDate: nextDate, options: nil)
        
        return (components.day,components.hour, components.minute)
    }
    
    // MARK: - IBActions
    
    @IBAction func pressedChangeOrder(sender: UIButton) {
        showDropDownController(sender, dataSource:OrderBy.allItems())
    }
    
    @IBAction func pressedChangeView(sender: UIButton) {
        showDropDownController(sender, dataSource:ViewType.allItems())
    }
    
    
}

extension BaseViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == "" {
            filteredDataSource = dataSource
            return
        }
        
        filteredDataSource = dataSource.map { (var animeTypeArray) -> [Anime] in
            func filterText(anime: Anime) -> Bool {
                return (anime.title!.rangeOfString(searchBar.text) != nil) ||
                    (" ".join(anime.genres).rangeOfString(searchBar.text) != nil)
                
            }
            return animeTypeArray.filter(filterText)
        }
        
    }
}

extension BaseViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return filteredDataSource.count
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredDataSource[section].count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var reuseIdentifier: String = ""
            
        switch currentViewType {
        case .Chart:
            reuseIdentifier = "AnimeCell"
        case .List:
            reuseIdentifier = "AnimeListCell"
        case .Poster:
            reuseIdentifier = "AnimeCellPoster"
        }

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! AnimeCell
        
        let anime = filteredDataSource[indexPath.section][indexPath.row]
        
        cell.posterImageView?.setImageFrom(urlString: anime.imageUrl, animated: canFadeImages)
        cell.titleLabel.text = anime.title
        cell.genresLabel?.text = ", ".join(anime.genres)
        
        if let source = anime.source {
            cell.sourceLabel?.text = "Source: \(source)"
        } else {
            cell.sourceLabel?.text = ""
        }
        
        
        if let mainStudio = anime.studio.first {
            let studioString = mainStudio["studio_name"] as! String
            cell.studioLabel?.text = "\(studioString)"
        } else {
            cell.studioLabel?.text = ""
        }
        
        if var nextEpisode = anime.nextEpisode {
            let nextDate = anime.nextEpisodeDate
            
            let (days, hours, minutes) = etaForDate(nextDate)
            let etaTime: String
            if days != 0 {
                etaTime = "\(days)d \(hours)h \(minutes)m"
                cell.etaLabel?.textColor = UIColor.belizeHole()
                cell.etaTimeLabel?.textColor = UIColor.belizeHole()
                cell.etaLabel?.text = "Episode \(nextEpisode) - " + etaTime
            } else if hours != 0 {
                etaTime = "\(hours)h \(minutes)m"
                cell.etaLabel?.textColor = UIColor.nephritis()
                cell.etaTimeLabel?.textColor = UIColor.nephritis()
                cell.etaLabel?.text = "Episode \(nextEpisode) - " + etaTime
            } else {
                etaTime = "\(minutes)m"
                cell.etaLabel?.textColor = UIColor.pumpkin()
                cell.etaTimeLabel?.textColor = UIColor.pumpkin()
                cell.etaLabel?.text = "Episode \(nextEpisode) - \(minutes)m"
            }
            
            cell.etaTimeLabel?.text = etaTime
            cell.nextEpisodeNumberLabel?.text = nextEpisode.description
        
        } else {
            cell.etaLabel?.text = ""
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableView: UICollectionReusableView!
        
        if kind == UICollectionElementKindSectionHeader {
            
            var headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! BasicCollectionReusableView
            
            var title = ""
            switch indexPath.section {
            case 0: title = "TV"
            case 1: title = "Movie"
            case 2: title = "OVA"
            case 3: title = "ONA"
            case 4: title = "Special"
            default: break
            }
            
            headerView.titleLabel.text = title
            
            reusableView = headerView;
        }
        
        return reusableView
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if filteredDataSource[section].count == 0 {
            return CGSizeZero
        } else {
            let height = (section == 0) ? FirstHeaderCellHeight : HeaderCellHeight
            return CGSize(width: view.bounds.size.width, height: height)
        }
    }
    
}



extension BaseViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let tabBarController = ANAnimeKit.rootTabBarController()
        let anime = filteredDataSource[indexPath.section][indexPath.row]
        tabBarController.initWithAnime(anime)
        
        animator = ZFModalTransitionAnimator(modalViewController: tabBarController)
        animator.dragable = true
        animator.direction = ZFModalTransitonDirection.Bottom
         
        tabBarController.animator = animator
        tabBarController.transitioningDelegate = self.animator;
        tabBarController.modalPresentationStyle = UIModalPresentationStyle.Custom;
        
        presentViewController(tabBarController, animated: true, completion: nil)
    }
}

extension BaseViewController: DropDownListDelegate {
    func selectedAction(trigger: UIView, action: String) {
        if trigger.isEqual(orderButton) {
            if let orderEnum = OrderBy(rawValue: action) {
                order(by: orderEnum)
            }
        } else if trigger.isEqual(viewButton) {
            if let viewEnum = ViewType(rawValue: action) {
                setViewType(viewEnum)
            }
        }
    }
}