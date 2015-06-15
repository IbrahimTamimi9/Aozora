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
import Parse
import Bolts

class TBAViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentOrder = OrderBy.Popularity
        navigationBarTitle.text = "To Be Announced"
        fetchTBA()
    }
    
    func fetchTBA() {
        
        animateCollectionViewFadeOut()
        
        let query = Anime.query()!
        query.whereKeyExists("startDate")
        query.whereKey("status", equalTo: "not yet aired")
        query.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
            if let result = result as? [Anime] {
                
                var animeByType: [[Anime]] = [[],[],[],[],[],[],[]]
                                
                for anime in result {
                    var index = 0
                    switch anime.type {
                        case "TV": index = 0
                        case "Movie": index = 1
                        case "OVA": index = 2
                        case "ONA": index = 3
                        case "Special": index = 4
                        default: break;
                    }
                    animeByType[index].append(anime)
                }
                
                self.dataSource = animeByType
                self.order(by: self.currentOrder)
            }
            
            self.animateCollectionViewFadeIn()
        })

        
    }
    
}

extension TBAViewController: UICollectionViewDataSource {
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
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
    
}