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


enum SelectedList: Int {
    case SeasonalChart = 0
    case AllSeasons
    case Calendar
    case TBA
}

class BaseViewController: UIViewController {
    
    let FirstHeaderCellHeight: CGFloat = 88.0
    let HeaderCellHeight: CGFloat = 44.0
    
    var canFadeImages = true
    var showTableView = true
    
    var currentConfiguration: Configuration =
    [
        (FilterSection.View, ViewType.Chart.rawValue, ViewType.allRawValues()),
        (FilterSection.Sort, SortBy.Rating.rawValue, [SortBy.Rating.rawValue, SortBy.Popularity.rawValue, SortBy.Title.rawValue, SortBy.NextAiringEpisode.rawValue])
    ]
    
    var orders: [SortBy] = [.Rating,.None,.NextAiringEpisode,.Popularity]
    var viewTypes: [ViewType] = [.Chart,.SeasonalChart,.Poster,.Chart]
    var selectedList: SelectedList = .SeasonalChart {
        didSet {
            filterBar.hidden = selectedList == .AllSeasons
        }
    }
    
    var currentOrder: SortBy {
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
    @IBOutlet weak var filterBar: UIView!
    
    var loadingView: LoaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AnimeCell.registerNibFor(collectionView: collectionView, style: .Chart, reuseIdentifier: "AnimeCell")
        AnimeCell.registerNibFor(collectionView: collectionView, style: .Poster, reuseIdentifier: "AnimeCellPoster")
        AnimeCell.registerNibFor(collectionView: collectionView, style: .List, reuseIdentifier: "AnimeCellList")
        
//        navigationController?.hidesBarsOnSwipe = true
//        navigationController?.hidesBarsOnTap = false
        
        collectionView.alpha = 0.0
        
        timer = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: "updateETACells", userInfo: nil, repeats: true)
        
        loadingView = LoaderView(parentView: self.view)        
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
    
    func order(#by: SortBy) {
        
        currentOrder = by
        
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
            default:
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

    
    
    // MARK: - IBActions
    @IBAction func showFilterPressed(sender: AnyObject) {
        
        if let tabBar = tabBarController {
            let controller = UIStoryboard(name: "Browse", bundle: nil).instantiateViewControllerWithIdentifier("Filter") as! FilterViewController
            
            controller.delegate = self
            controller.initWith(configuration: currentConfiguration)
            controller.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
            controller.modalPresentationStyle = .OverCurrentContext
            tabBar.presentViewController(controller, animated: true, completion: nil)
        }
        
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
            reuseIdentifier = "AnimeCellList"
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
            let anime = filteredDataSource[indexPath.section][indexPath.row]
            self.animator = presentAnimeModal(anime)
        }
        
    }
}

extension BaseViewController: FilterViewControllerDelegate {
    func finishedWith(#configuration: Configuration, selectedGenres: [String]) {
        currentConfiguration = configuration
        
        for (filterSection, value, _) in configuration {
            if let value = value {
                switch filterSection {
                case .Sort:
                    order(by: SortBy(rawValue: value)!)
                case .View:
                    setViewType(ViewType(rawValue: value)!)
                default: break
                }
            }
        }
    }
}