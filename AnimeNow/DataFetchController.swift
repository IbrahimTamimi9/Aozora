//
//  DataFetchController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/27/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Parse
import Bolts

public protocol FetchControllerDelegate: class {
    func didFetchFor(#skip: Int)
}
public class FetchController {

    public weak var delegate: FetchControllerDelegate?
    
    var isFetching = true
    var canFetchMore = true
    var dataSourceCount = 0
    var page = 0
    var limit = 100
    
    var defaultIsFetching = true
    var defaultCanFetchMore = true
    var defaultDataSourceCount = 0
    var defaultPage = 0
    var defaultLimit = 100

    var tableView: UITableView?
    var collectionView: UICollectionView?
    var dataSource: [PFObject] = []
    var query: PFQuery!
    
    public init() {
        
    }
    
    public func configureWith(delegate: FetchControllerDelegate, query: PFQuery, collectionView: UICollectionView? = nil, tableView: UITableView? = nil, limit: Int = 100) {
        self.delegate = delegate
        self.tableView = tableView
        self.collectionView = collectionView
        self.query = query
        defaultLimit = limit
        resetToDefaults()
        fetchWith(skip: 0)
    }
    
    func resetToDefaults() {
        isFetching = defaultIsFetching
        canFetchMore = defaultCanFetchMore
        dataSourceCount = defaultDataSourceCount
        page = defaultPage
        limit = defaultLimit
        query.skip = 0
    }
    
    public func dataCount() -> Int {
        return dataSource.count
    }
    
    public func objectAtIndex(index: Int) -> PFObject {
        didDisplayItemAt(index: index)
        return dataSource[index]
    }
    
    public func didDisplayItemAt(#index: Int) {
        
        if isFetching || !canFetchMore {
            return
        }
        
        if Float(index) > Float(dataSourceCount) - Float(limit) * 0.2 {
            isFetching = true
            page += 1
            println("Fetching page \(page)")
            fetchWith(skip: page*limit)
        }
    }
    
    public func didFetch(newDataSourceCount: Int) {
        
        if !isFetching && newDataSourceCount == limit {
            resetToDefaults()
        }
        
        if isFetching {
            
            isFetching = false
            canFetchMore = newDataSourceCount == dataSourceCount + limit ? true : false
            dataSourceCount = newDataSourceCount
            
            println("Fetched page \(page)")
        }
    }
    
    func fetchWith(#skip: Int) -> BFTask {
        query.skip = skip
        return query.findObjectsInBackground().continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task: BFTask!) -> AnyObject! in
            
            if let result = task.result as? [PFObject] {
                
                if skip == 0 {
                    self.dataSource = result
                } else {
                    self.dataSource += result
                }
                self.didFetch(self.dataSource.count)
            }
            
            self.delegate?.didFetchFor(skip: skip)
            
            
            if let collectionView = self.collectionView {
                if skip == 0 {
                    // Reload data
                    collectionView.reloadData()
                    collectionView.animateFadeIn()
                    
                } else if let result = task.result as? [PFObject] {
                    // Insert rows
                    collectionView.performBatchUpdates({ () -> Void in
                        let endIndex = self.dataSource.count
                        let startIndex = endIndex - result.count
                        var indexPathsToInsert: [NSIndexPath] = []
                        for index in startIndex..<endIndex {
                            indexPathsToInsert.append(NSIndexPath(forRow: index, inSection: 0))
                        }
                        collectionView.insertItemsAtIndexPaths(indexPathsToInsert)
                        }, completion: nil)
                }
            } else if let tableView = self.tableView {
                if skip == 0 {
                    // Reload data
                    tableView.reloadData()
                    tableView.animateFadeIn()
                    
                } else if let result = task.result as? [PFObject] {
                    // Insert rows
                    let startIndex = self.dataSource.count - result.count
                    var range = NSRange()
                    range.location = startIndex
                    range.length = result.count

                    tableView.beginUpdates()
                    tableView.insertSections(NSIndexSet(indexesInRange: range), withRowAnimation: UITableViewRowAnimation.Automatic)
                    tableView.endUpdates()
                }
            }
            
            
            return nil
        })

        
    }
    
}
