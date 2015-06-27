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
import Bolts

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var loadingView: LoaderView!
    var animator: ZFModalTransitionAnimator!
    
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
        
        searchBar.becomeFirstResponder()
    }
    
    func fetchAnimeWithQuery(text: String, cancellationToken: NSOperation) {
    
        currentCancellationToken = cancellationToken
        
        loadingView.startAnimating()
        collectionView.animateFadeOut()
        
        let query = Anime.query()!
        query.limit = 10
        query.whereKey("title", matchesRegex: text, modifiers: "i")
        query.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
            if !cancellationToken.cancelled && result != nil {
                println("fetched query \(text)")
                self.dataSource = result as! [Anime]
            }
            self.loadingView.stopAnimating()
            self.collectionView.animateFadeIn()
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
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension SearchViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
}