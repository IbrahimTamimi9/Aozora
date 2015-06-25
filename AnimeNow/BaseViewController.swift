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
    case None = "None"
    
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
    case SeasonalChart = "SeasonalChart"
    
    static func allItems() -> [String] {
        return [
            ViewType.Chart.rawValue,
            ViewType.List.rawValue,
            ViewType.Poster.rawValue
        ]
    }
}

enum SelectedList: Int {
    case SeasonalChart = 0
    case AllSeasons
    case Calendar
    case TBA
}

class BaseViewController: UIViewController {
    
    let FirstHeaderCellHeight: CGFloat = 88.0
    let HeaderCellHeight: CGFloat = 44.0
    let angleDownIcon = NSString.fontAwesomeIconStringForIconIdentifier("icon-angle-down")
    
    var canFadeImages = true
    var showTableView = true
    
    var orders: [OrderBy] = [.Rating,.None,.NextAiringEpisode,.Popularity]
    var viewTypes: [ViewType] = [.Chart,.SeasonalChart,.Poster,.Chart]
    var selectedList: SelectedList = .SeasonalChart {
        didSet {
            filterBar.hidden = selectedList == .AllSeasons
        }
    }
    
    var currentOrder: OrderBy {
        get {
            return orders[selectedList.rawValue]
        }
        set (order) {
            orders[selectedList.rawValue] = order
        }
    }
    
    var currentViewType: ViewType {
        get {
            return viewTypes[selectedList.rawValue]
        }
        set (viewType) {
            viewTypes[selectedList.rawValue] = viewType
        }
    }
    
    var weekdayStrings: [String] = []
    
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
    
    var chartsDataSource: [SeasonalChart] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var navigationBarTitle: UILabel!
    
    @IBOutlet weak var orderTitleLabel: UILabel!
    @IBOutlet weak var orderButton: UIButton!
    
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var viewButton: UIButton!
    
    @IBOutlet weak var filterBar: UIView!
    
    var loadingView: LoaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.hidesBarsOnTap = false
        
        collectionView.alpha = 0.0
        
        timer = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: "updateETACells", userInfo: nil, repeats: true)
        
        loadingView = LoaderView(viewController: self)
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
        
        let today = NSDate()
        var index = 0
        
        dataSource = dataSource.map() { (var animeArray) -> [Anime] in
            switch self.currentOrder {
            case .Rating:
                animeArray.sort({ $0.rank < $1.rank})
            case .Popularity:
                animeArray.sort({ $0.popularityRank < $1.popularityRank})
            case .Title:
                animeArray.sort({ $0.title < $1.title})
            case .NextAiringEpisode:
                
                if self.selectedList == SelectedList.Calendar {
                    if index == 0 {
                        animeArray.sort({ (anime1: Anime, anime2: Anime) in
                            let anime1IsToday = anime1.nextEpisodeDate.timeIntervalSinceDate(today) < 60*60*24
                            let anime2IsToday = anime2.nextEpisodeDate.timeIntervalSinceDate(today) < 60*60*24
                            if anime1IsToday && anime2IsToday {
                                return anime1.nextEpisodeDate.compare(anime2.nextEpisodeDate) == .OrderedAscending
                            } else if !anime1IsToday && !anime2IsToday {
                                return anime1.nextEpisodeDate.compare(anime2.nextEpisodeDate) == .OrderedDescending
                            } else if anime1IsToday && !anime2IsToday {
                                return false
                            } else {
                                return true
                            }
                            
                        })
                    } else {
                        animeArray.sort({ $0.nextEpisodeDate.compare($1.nextEpisodeDate) == .OrderedAscending })
                    }
                
                    index += 1
                } else {
                    animeArray.sort({ $0.nextEpisodeDate.compare($1.nextEpisodeDate) == .OrderedAscending })
                }
            case .None:
                break;
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
        case .SeasonalChart:
            size = CGSize(width: view.bounds.size.width, height: 36)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.minimumLineSpacing = 1
        }
        
        layout.itemSize = size
        
        canFadeImages = false
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
        canFadeImages = true
    }
    
    func showDropDownController(sender: UIView, dataSource: [[String]], imageDataSource: [[String]]? = []) {
        let frameRelativeToViewController = sender.convertRect(sender.bounds, toView: view)
        
        let controller = ANCommonKit.dropDownListViewController()
        controller.delegate = self
        controller.setDataSource(sender, dataSource: dataSource, yPosition: CGRectGetMaxY(frameRelativeToViewController), imageDataSource: imageDataSource)
        controller.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        controller.modalPresentationStyle = .OverCurrentContext
        self.tabBarController?.presentViewController(controller, animated: false, completion: nil)
    }
    
    
    // MARK: - IBActions
    
    @IBAction func pressedChangeOrder(sender: UIButton) {
        showDropDownController(sender, dataSource: [OrderBy.allItems()])
    }
    
    @IBAction func pressedChangeView(sender: UIButton) {
        showDropDownController(sender, dataSource: [ViewType.allItems()])
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
        if selectedList == SelectedList.AllSeasons {
            return 1
        } else {
            return filteredDataSource.count
        }
        
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selectedList == SelectedList.AllSeasons {
            return chartsDataSource.count
        } else {
            return filteredDataSource[section].count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if selectedList == SelectedList.AllSeasons {
            let reuseIdentifier = "SeasonCell";
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! BasicCollectionCell
            
            let seasonalChart = chartsDataSource[indexPath.row]
            cell.titleLabel.text = seasonalChart.title
            cell.layoutIfNeeded()
            return cell
        }
        
        var reuseIdentifier: String = ""
            
        switch currentViewType {
        case .Chart:
            reuseIdentifier = "AnimeCell"
        case .List:
            reuseIdentifier = "AnimeListCell"
        case .Poster:
            reuseIdentifier = "AnimeCellPoster"
        case .SeasonalChart: break
        }

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! AnimeCell
        
        let anime = filteredDataSource[indexPath.section][indexPath.row]
        
        let nextDate = anime.nextEpisodeDate
        let showEtaAsAired =
            selectedList == SelectedList.Calendar &&
            indexPath.section == 0 &&
            nextDate.timeIntervalSinceNow > 60*60*24
        
        cell.configureWithAnime(anime, canFadeImages: canFadeImages, showEtaAsAired: showEtaAsAired)
        
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableView: UICollectionReusableView!
        
        if kind == UICollectionElementKindSectionHeader {
            
            var headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! BasicCollectionReusableView
            
            if selectedList == SelectedList.Calendar {
                headerView.titleLabel.text = weekdayStrings[indexPath.section]
            } else {
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
            }
            
            
            reusableView = headerView;
        }
        
        return reusableView
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if filteredDataSource[section].count == 0
            || selectedList == SelectedList.AllSeasons {
            return CGSizeZero
        } else {
            let height = (section == 0) ? FirstHeaderCellHeight : HeaderCellHeight
            return CGSize(width: view.bounds.size.width, height: height)
        }
    }
    
}



extension BaseViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if selectedList != SelectedList.AllSeasons {
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
}

extension BaseViewController: DropDownListDelegate {
    func selectedAction(trigger: UIView, action: String, indexPath: NSIndexPath) {
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