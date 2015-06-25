//
//  DiscoverViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/23/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANCommonKit
import ANParseKit

enum BrowseType: String {
    case TopAnime = "Top Anime"
    case TopAiring = "Top Airing"
    case TopUpcoming = "Top Upcoming"
    case TopTVSeries = "Top TV Series"
    case TopMovies = "Top Movies"
    case TopOVA = "Top OVA"
    case TopSpecials = "Top Specials"
    case JustAdded = "Just Added"
    case MostPopular = "Most Popular"
    
    
    static func allItems() -> [String] {
        return [
            BrowseType.TopAnime.rawValue,
            BrowseType.TopAiring.rawValue,
            BrowseType.TopUpcoming.rawValue,
            BrowseType.TopTVSeries.rawValue,
            BrowseType.TopMovies.rawValue,
            BrowseType.TopOVA.rawValue,
            BrowseType.TopSpecials.rawValue,
            BrowseType.JustAdded.rawValue,
            BrowseType.MostPopular.rawValue,
        ]
    }
}

class BrowseViewController: UIViewController {
    
    var currentBrowseType: BrowseType = .TopAnime
    var dataSource: [Anime] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var loadingView: LoaderView!
    
    @IBOutlet weak var navigationBarTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Remove duplicated code in BaseViewController..
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "changeSeasonalChart")
        navigationController?.navigationBar.addGestureRecognizer(tapGestureRecognizer)
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: view.bounds.size.width, height: 132)
        
        loadingView = LoaderView(viewController: self)
        
        fetchListType(currentBrowseType)
    }
    
    func fetchListType(type: BrowseType) {
        
        // Animate
        collectionView.animateFadeOut()
        loadingView.startAnimating()
        
        // Update model
        currentBrowseType = type
        
        // Update UI
        collectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
        navigationBarTitle.text! = currentBrowseType.rawValue + " "
        
        // Fetch
        let query = Anime.query()!
        
        switch currentBrowseType {
        case .TopAnime:
            query
            .orderByAscending("rank")
        case .TopAiring:
            query
            .orderByAscending("rank")
            .whereKey("status", equalTo: AnimeStatus.CurrentlyAiring.rawValue)
        case .TopUpcoming:
            query.orderByAscending("rank")
            .whereKey("status", equalTo: AnimeStatus.NotYetAired.rawValue)
        case .TopTVSeries:
            query.orderByAscending("rank")
            .whereKey("type", equalTo: AnimeType.TV.rawValue)
        case .TopMovies:
            query.orderByAscending("rank")
            .whereKey("type", equalTo: AnimeType.Movie.rawValue)
        case .TopOVA:
            query.orderByAscending("rank")
            .whereKey("type", equalTo: AnimeType.OVA.rawValue)
        case .TopSpecials:
            query.orderByAscending("rank")
            .whereKey("type", equalTo: AnimeType.Special.rawValue)
        case .JustAdded:
            query.orderByDescending("createdAt")
        case .MostPopular:
            query.orderByAscending("popularityRank")
        }
        
        
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if result != nil {
                self.dataSource = result as! [Anime]
            }
            self.loadingView.stopAnimating()
            self.collectionView.animateFadeIn()
        }
    }
    
    func changeSeasonalChart() {
        if let bar = navigationController?.navigationBar {
            showDropDownController(bar,
                dataSource: [BrowseType.allItems()])
        }
    }
    
    // TODO: Remove duplicated code in BaseViewController..
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
    
    @IBAction func presentSearchPressed(sender: AnyObject) {
        
        if let tabBar = tabBarController {
            let controller = UIStoryboard(name: "Browse", bundle: nil).instantiateViewControllerWithIdentifier("Search") as! SearchViewController
            controller.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            controller.modalPresentationStyle = .OverCurrentContext
            tabBar.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
}


extension BrowseViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AnimeCell", forIndexPath: indexPath) as! AnimeCell
        
        let anime = dataSource[indexPath.row]
        
        cell.configureWithAnime(anime)
        
        return cell
    }
}

extension BrowseViewController: UICollectionViewDelegate {
    
}
    
extension BrowseViewController: DropDownListDelegate {
    func selectedAction(trigger: UIView, action: String, indexPath: NSIndexPath) {
        let rawValue = BrowseType.allItems()[indexPath.row]
        fetchListType(BrowseType(rawValue: rawValue)!)
    }
}
