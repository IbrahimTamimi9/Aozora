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
    
    static func allItems() -> [String] {
        return [
            ViewType.Chart.rawValue,
            ViewType.List.rawValue
        ]
    }
}

class ChartViewController: UIViewController {
    
    let FirstHeaderCellHeight: CGFloat = 88.0
    let HeaderCellHeight: CGFloat = 44.0
    
    var isFirstLoad = true
    var currentOrder: OrderBy = .Rating
    var currentViewType: ViewType = .Chart
    
    var dataSource: [Anime] = [] {
        didSet {
            filteredDataSource = dataSource
        }
    }
    
    var filteredDataSource: [Anime] = [] {
        didSet {
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.reloadData()
        }
    }
    
    // TODO: create loading view from code, generalize to be used on UICollectionViews
    @IBOutlet weak var loadingView: LoaderView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var orderTitleLabel: UILabel!
    @IBOutlet weak var orderButton: UIButton!
    
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var viewButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.hidesBarsOnTap = false
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: view.bounds.size.width, height: 132)
        
        loadingView.startAnimating()
        
        let currentChartQuery = SeasonalChart.query()!
        currentChartQuery.limit = 1
        currentChartQuery.orderByDescending("startDate")
        currentChartQuery.includeKey("tvAnime")
        currentChartQuery.findObjectsInBackground().continueWithBlock {
            (task: BFTask!) -> AnyObject! in
            if let result = task.result as? [SeasonalChart], let season = result.last {

                var tvAnimeList = season.tvAnime
                self.dataSource = tvAnimeList
                self.order(by: self.currentOrder)
                self.loadingView.stopAnimating()
            }
            
            return nil;
        }
    }
    
    // MARK: - Utility Functions
    
    func order(#by: OrderBy) {
        
        orderTitleLabel.text = by.rawValue
    
        switch by {
        case .Rating:
            dataSource.sort({ $0.membersScore > $1.membersScore})
        case .Popularity:
            dataSource.sort({ $0.membersCount > $1.membersCount})
        case .Title:
            dataSource.sort({ $0.title < $1.title})
        case .NextAiringEpisode:
            // TODO: implement
            dataSource.sort({ $0.membersScore > $1.membersScore})
        }
        
        
    }
    
    func viewType(viewType: ViewType) {
        
    }
    
    func showDropDownController(sender: UIView, dataSource: [String]) {
        let frameRelativeToViewController = sender.convertRect(sender.bounds, toView: view)
        
        let commonStoryboard = UIStoryboard(name: "Common", bundle: nil)
        let controller = commonStoryboard.instantiateViewControllerWithIdentifier("DropDownList") as! DropDownListViewController
        controller.delegate = self
        controller.setDataSource(sender, dataSource: dataSource, yPosition: CGRectGetMaxY(frameRelativeToViewController))
        controller.modalTransitionStyle = .CrossDissolve
        controller.modalPresentationStyle = .OverCurrentContext
        self.tabBarController?.presentViewController(controller, animated: true, completion: nil)
    }
    
    // MARK: - IBActions
    
    @IBAction func pressedChangeOrder(sender: UIButton) {
        showDropDownController(sender, dataSource:OrderBy.allItems())
    }

    @IBAction func pressedChangeView(sender: UIButton) {
        showDropDownController(sender, dataSource:ViewType.allItems())
    }
    
    
}

extension ChartViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == "" {
            filteredDataSource = dataSource
            return
        }
        
        func filterText(anime: Anime) -> Bool {
            let title = anime.title
            return (title.rangeOfString(searchBar.text) != nil)
        }
        
        filteredDataSource = dataSource.filter(filterText)
    }
}

extension ChartViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        println("4")
        return filteredDataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("animeCell", forIndexPath: indexPath) as! AnimeCell        
        println("5.0")
        let anime = filteredDataSource[indexPath.row]

        let imageUrl = NSURL(string: anime.imageUrl)
        cell.posterImageView.sd_setImageWithURL(imageUrl)
        cell.titleLabel.text = anime.title
        cell.genresLabel.text = ", ".join(anime.genres)
        
        cell.layoutIfNeeded()
        
        if isFirstLoad {
            cell.alpha = 0.0
            if indexPath.row == 3 {
                isFirstLoad = false
                var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    // your function here
                    self.animate()
                })
            }
        }
        println("5.1")
        return cell
    }
    
    func animate() {
        
        var visibleCells = collectionView.indexPathsForVisibleItems()
        
        for (index, element) in enumerate(visibleCells) {
            var indexPath = element as! NSIndexPath
            var cell = collectionView.cellForItemAtIndexPath(indexPath) as! AnimeCell
            var frame = cell.frame
            var newFrame = cell.frame
            newFrame.origin.y += CGFloat(indexPath.row+1)*20
            cell.frame = newFrame
            cell.alpha = 0.0
            UIView.animateWithDuration(0.40, delay: Double(indexPath.row)*0.05, options: .CurveEaseOut, animations: { () -> Void in
                cell.frame = frame
                cell.alpha = 1.0
                }, completion: nil)
        }
        
        
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableView: UICollectionReusableView!
        
        if kind == UICollectionElementKindSectionHeader {
            
            var headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! UICollectionReusableView
            reusableView = headerView;
        }
        
        return reusableView
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        let height = (section == 0) ? FirstHeaderCellHeight : HeaderCellHeight
        return CGSize(width: view.bounds.size.width, height: height)
    }

}

extension ChartViewController: DropDownListDelegate {
    func selectedAction(trigger: UIView, action: String) {
        if trigger.isEqual(orderButton) {
            if let orderEnum = OrderBy(rawValue: action) {
                order(by: orderEnum)
            }
        } else if trigger.isEqual(viewButton) {
            if let viewEnum = ViewType(rawValue: action) {
                viewType(viewEnum)
            }
        }
    }
}