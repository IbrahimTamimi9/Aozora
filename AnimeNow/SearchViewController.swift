//
//  SearchViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/25/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANParseKit
import ANCommonKit
import ANAnimeKit
import Bolts

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var loadingView: LoaderView!
    var animator: ZFModalTransitionAnimator!
    var searchLibrary = false
    var dataSource: [Anime] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    var currentCancellationToken: NSOperation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let chartNib = UINib(nibName: "AnimeCell", bundle: nil)
        collectionView.registerNib(chartNib, forCellWithReuseIdentifier: "AnimeCell")
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: view.bounds.size.width, height: 132)
        
        loadingView = LoaderView(parentView: self.view)
        
        searchBar.placeholder = searchLibrary ? "Search your library" : "Search all anime"
        searchBar.becomeFirstResponder()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateETACells", name: ANAnimeKit.LibraryUpdatedNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func updateETACells() {
        let indexPaths = collectionView.indexPathsForVisibleItems()
        collectionView.reloadItemsAtIndexPaths(indexPaths)
    }
    
    func fetchAnimeWithQuery(text: String, cancellationToken: NSOperation) {
    
        currentCancellationToken = cancellationToken
        
        if !searchLibrary {
            loadingView.startAnimating()
            collectionView.animateFadeOut()
        }
        
        let query = PFQuery(className: "Anime")
        query.limit = 20
        query.whereKey("title", matchesRegex: text, modifiers: "i")
        if searchLibrary {
            query.fromPinWithName(Anime.PinName.InLibrary.rawValue)
        }
        
        query.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
            if let anime = result as? [Anime] where !cancellationToken.cancelled && result != nil {
                
                LibrarySyncController.matchAnimeWithProgress(anime)
                self.dataSource = anime
            }
            
            if !self.searchLibrary {
                self.loadingView.stopAnimating()
                self.collectionView.animateFadeIn()
            }
        })
    
    }
    
}

extension SearchViewController: UICollectionViewDataSource {
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

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let anime = dataSource[indexPath.row]
        self.animator = presentAnimeModal(anime)
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let cancelToken = currentCancellationToken {
            cancelToken.cancel()
        }
        
        fetchAnimeWithQuery(searchBar.text, cancellationToken: NSOperation())
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        fetchAnimeWithQuery(searchBar.text, cancellationToken: NSOperation())
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension SearchViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
}