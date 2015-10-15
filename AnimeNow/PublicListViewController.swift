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
import ANCommonKit

class PublicListViewController: UIViewController {
    
    let FirstHeaderCellHeight: CGFloat = 88.0
    let HeaderCellHeight: CGFloat = 44.0
    
    var canFadeImages = true
    var showTableView = true

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
    
    var loadingView: LoaderView!
    var userProfile: User!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var navigationBarTitle: UILabel!
    @IBOutlet weak var filterBar: UIView!
    
    func initWithUser(user: User) {
        userProfile = user
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let listNib = UINib(nibName: "LibraryAnimeCellList", bundle: nil)
        collectionView.registerNib(listNib, forCellWithReuseIdentifier: "LibraryAnimeCellList")
        
        collectionView.alpha = 0.0
        
        loadingView = LoaderView(parentView: view)
        
        title = "\(userProfile.aozoraUsername) Library"
        
        fetchUserLibrary()
        updateLayout()
    }
    
    deinit {
        for typeList in dataSource {
            for anime in typeList {
                anime.publicProgress = nil
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if loadingView.animating == false {
            loadingView.stopAnimating()
            collectionView.animateFadeIn()
        }
    }
    
    func fetchUserLibrary() {
        
        let query = AnimeProgress.query()!
        query.limit = 1000
        query.includeKey("anime")
        query.whereKey("user", equalTo: userProfile)
        query.findObjectsInBackground()
            .continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task: BFTask!) -> AnyObject! in
        
            if var result = task.result as? [AnimeProgress] {
                
                result.sortInPlace({ (anime1: AnimeProgress, anime2: AnimeProgress) -> Bool in
                    if anime1.list == anime2.list {
                        return anime1.anime.title! < anime2.anime.title
                    } else {
                        return anime1.list > anime2.list
                    }
                })
                
                var animeList: [Anime] = []
                for animeProgress in result {
                    let anime = animeProgress.anime
                    anime.publicProgress = animeProgress
                    animeList.append(anime)
                }
                
                let tvAnime = animeList.filter({$0.type == "TV"})
                let tv = tvAnime.filter({$0.duration == 0 || $0.duration > 15})
                let tvShort = tvAnime.filter({$0.duration > 0 && $0.duration <= 15})
                let movieAnime = animeList.filter({$0.type == "Movie"})
                let ovaAnime = animeList.filter({$0.type == "OVA"})
                let onaAnime = animeList.filter({$0.type == "ONA"})
                let specialAnime = animeList.filter({$0.type == "Special"})
                
                self.dataSource = [tv, tvShort, movieAnime, ovaAnime, onaAnime, specialAnime]

            }
            
            self.loadingView.stopAnimating()
            self.collectionView.animateFadeIn()
            return nil
        })
    }
    
    // MARK: - Utility Functions
    func updateLayout() {
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        let size = CGSize(width: view.bounds.size.width, height: 52)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 1
        
        layout.itemSize = size
        
        canFadeImages = false
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
        canFadeImages = true
    }
    
    @IBAction func dismissViewControllerPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension PublicListViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {

        return filteredDataSource.count
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return filteredDataSource[section].count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LibraryAnimeCellList", forIndexPath: indexPath) as! AnimeCell
        let anime = filteredDataSource[indexPath.section][indexPath.row]
        cell.configureWithAnime(anime, canFadeImages: canFadeImages, showEtaAsAired: false, publicAnime: true)
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableView: UICollectionReusableView!
        
        if kind == UICollectionElementKindSectionHeader {
            
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! BasicCollectionReusableView
    
                var title = ""
                switch indexPath.section {
                case 0: title = "TV"
                case 1: title = "TV Short"
                case 2: title = "Movie"
                case 3: title = "OVA"
                case 4: title = "ONA"
                case 5: title = "Special"
                default: break
                }
                
                headerView.titleLabel.text = title
            
            
            reusableView = headerView;
        }
        
        return reusableView
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let height = (section == 0) ? FirstHeaderCellHeight : HeaderCellHeight
        return CGSize(width: view.bounds.size.width, height: height)
    }
    
}

extension PublicListViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        view.endEditing(true)
        
        let anime = filteredDataSource[indexPath.section][indexPath.row]
        animator = presentAnimeModal(anime)
    }
}


extension PublicListViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == "" {
            filteredDataSource = dataSource
            return
        }
        
        filteredDataSource = dataSource.map { (var animeTypeArray) -> [Anime] in
            func filterText(anime: Anime) -> Bool {
                return (anime.title!.rangeOfString(searchBar.text!) != nil) ||
                    (anime.genres.joinWithSeparator(" ").rangeOfString(searchBar.text!) != nil)
                
            }
            return animeTypeArray.filter(filterText)
        }
        
    }
}
