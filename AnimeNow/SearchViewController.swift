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
    
    enum SearchScope: Int {
        case AllAnime = 0
        case MyLibrary
        case Users
    }
    
    var loadingView: LoaderView!
    var animator: ZFModalTransitionAnimator!
    var dataSource: [PFObject] = [] {
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
        
        loadingView = LoaderView(parentView: view)
        
        searchBar.placeholder = "Enter your search"
        searchBar.becomeFirstResponder()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateETACells", name: LibraryUpdatedNotification, object: nil)
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
        
        if searchBar.selectedScopeButtonIndex != SearchScope.MyLibrary.rawValue {
            loadingView.startAnimating()
            collectionView.animateFadeOut()
        }
        
        var query: PFQuery!
        
        if searchBar.selectedScopeButtonIndex != SearchScope.Users.rawValue {
            let query1 = Anime.query()!
            query1.whereKey("title", matchesRegex: text, modifiers: "i")

            let query2 = Anime.query()!
            query2.whereKey("titleEnglish", matchesRegex: text, modifiers: "i")
            
            let orQuery = PFQuery.orQueryWithSubqueries([query1, query2])
            orQuery.limit = 40
            orQuery.orderByAscending("popularityRank")
            if searchBar.selectedScopeButtonIndex == SearchScope.MyLibrary.rawValue {
                orQuery.fromLocalDatastore()
            }
            query = orQuery
        } else {
            query = User.query()!
            query.limit = 40
            query.whereKey("aozoraUsername", matchesRegex: text, modifiers: "i")
            query.orderByAscending("aozoraUsername")
        }
        
        query.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
            if let anime = result as? [Anime] where !cancellationToken.cancelled && result != nil {
                
                LibrarySyncController.matchAnimeWithProgress(anime)
                .continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task: BFTask!) -> AnyObject! in
                    if self.searchBar.selectedScopeButtonIndex == SearchScope.MyLibrary.rawValue {
                        let animeWithProgress = anime.filter({ $0.progress != nil })
                        self.dataSource = animeWithProgress
                    } else {
                        self.dataSource = anime
                    }
                    
                    return nil
                })
            } else if let users = result as? [User] where !cancellationToken.cancelled && result != nil {
                self.dataSource = users
            }
            
            if self.searchBar.selectedScopeButtonIndex != SearchScope.MyLibrary.rawValue {
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
        
        let object = dataSource[indexPath.row]
        if let anime = object as? Anime {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AnimeCell", forIndexPath: indexPath) as! AnimeCell
            cell.configureWithAnime(anime)
            return cell
            
        } else if let profile = object as? User {

            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UserCell", forIndexPath: indexPath) as! BasicCollectionCell
            if let avatarFile = profile.avatarThumb {
                cell.titleimageView.setImageWithPFFile(avatarFile)
            }
            cell.titleLabel.text = profile.aozoraUsername
            cell.layoutIfNeeded()
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let object = dataSource[indexPath.row]
        if let anime = object as? Anime {
            self.animator = presentAnimeModal(anime)
        } else if let user = object as? User {
            let (navController, profileController) = ANParseKit.profileViewController()
            profileController.initWithUser(user)
            presentViewController(navController, animated: true, completion: nil)
        }
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let object = dataSource[indexPath.row]
        if let anime = object as? Anime {
            return CGSize(width: view.bounds.size.width, height: 132)
        } else if let user = object as? User {
            return CGSize(width: view.bounds.size.width, height: 44)
        }
        return CGSizeZero
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let cancelToken = currentCancellationToken {
            cancelToken.cancel()
        }
        
        fetchAnimeWithQuery(searchBar.text, cancellationToken: NSOperation())
        view.endEditing(true)
        searchBar.enableCancelButton()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.selectedScopeButtonIndex == SearchScope.MyLibrary.rawValue {
            fetchAnimeWithQuery(searchBar.text, cancellationToken: NSOperation())
        }
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