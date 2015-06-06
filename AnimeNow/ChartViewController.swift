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

class ChartViewController: UIViewController {
    
    let FirstHeaderCellHeight: CGFloat = 88.0
    let HeaderCellHeight: CGFloat = 44.0
    
    var isFirstLoad = true
    var dataSource: [PFObject] = [] {
        didSet {
            filteredDataSource = dataSource
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.reloadData()
        }
    }
    
    var filteredDataSource: [PFObject] = [] {
        didSet {
            
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.reloadData()
        }
    }
    
    // TODO: create loading view from code, generalize to be used on UICollectionViews
    @IBOutlet weak var loadingView: LoaderView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.hidesBarsOnTap = false
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: view.bounds.size.width, height: 132)
        
        loadingView.startAnimating()
        
        let currentChartQuery = PFQuery(className: ParseKit.SeasonalChart)
        currentChartQuery.limit = 1
        currentChartQuery.orderByDescending("startDate")
        currentChartQuery.includeKey("tvAnime")
        currentChartQuery.findObjectsInBackground().continueWithBlock {
            (task: BFTask!) -> AnyObject! in
            if let result = task.result.copy() as? [PFObject], let season = result.last {

                var tvAnimeArray = season["tvAnime"] as! NSArray
                var tvAnimeList = tvAnimeArray.mutableCopy() as! [PFObject];
                println("0")
                tvAnimeList.sort({
                    item1, item2 in
                    let score1 = item1["membersScore"] as! Double
                    let score2 = item2["membersScore"] as! Double
                    return score1 > score2
                })
                println("1")
                self.dataSource = tvAnimeList
                println("2")
                self.loadingView.stopAnimating()
            }
            
            return nil;
        }
    }
    
    @IBAction func pressedChangeOrder(sender: AnyObject) {
        let commonStoryboard = UIStoryboard(name: "Common", bundle: nil)
        let controller = commonStoryboard.instantiateViewControllerWithIdentifier("ActionList") as! ActionListViewController
        controller.setDataSource(["Rating","Popularity","Title","Next Airing Episode"], title: "Order")
        controller.modalTransitionStyle = .CrossDissolve
        controller.modalPresentationStyle = .OverCurrentContext
        self.tabBarController?.presentViewController(controller, animated: true, completion: nil)
    }

    @IBAction func pressedChangeView(sender: AnyObject) {
        
    }
}

extension ChartViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == "" {
            filteredDataSource = dataSource
            return
        }
        
        func filterText(anime: PFObject) -> Bool {
            let title = anime["title"] as! String
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

        let imageUrl = NSURL(string: (anime["imageUrl"] as! String) )
        cell.posterImageView.sd_setImageWithURL(imageUrl)
        cell.titleLabel.text = anime["title"] as? String
        cell.genresLabel.text = ", ".join(anime["genres"] as! [String])
        
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

extension ChartViewController: UICollectionViewDelegate {
  
}