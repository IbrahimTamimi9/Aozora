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

public protocol FetchControllerQueryDelegate: class {
    func queriesForSkip(#skip: Int) -> [PFQuery]
    func processResult(#result: [PFObject]) -> [PFObject]
}

public class FetchController {

    public weak var delegate: FetchControllerDelegate?
    public weak var queryDelegate: FetchControllerQueryDelegate?
    
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
    var query: PFQuery?
    
    var isFirstFetch = true
    
    public init() {
        
    }
    
    public func configureWith(delegate: FetchControllerDelegate, query: PFQuery? = nil, queryDelegate: FetchControllerQueryDelegate? = nil, collectionView: UICollectionView? = nil, tableView: UITableView? = nil, limit: Int = 100) {
        self.queryDelegate = queryDelegate
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
        query?.skip = 0
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
        
        var secondaryQuery: PFQuery? = nil
        if let queries = queryDelegate?.queriesForSkip(skip: skip) {
            self.query = queries.first
            if queries.count > 1 {
                secondaryQuery = queries[1]
            }
        } else if let query = query {
            query.skip = skip
        } else {
            return BFTask(result: nil)
        }
        
        var allData:[PFObject] = []
        var fetchTask = query!.findObjectsInBackground()
        
        if let secondaryQuery = secondaryQuery {
            fetchTask = fetchTask.continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
                allData += task.result as! [PFObject]
                return secondaryQuery.findObjectsInBackground()
            })
        }
            
        fetchTask = fetchTask.continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task: BFTask!) -> AnyObject! in
            
            if var result = task.result as? [PFObject] {
                allData += result
                
                if let processedResult = self.queryDelegate?.processResult(result: allData) {
                    allData = processedResult
                }
                
                if skip == 0 {
                    self.dataSource = allData
                } else {
                    self.dataSource += allData
                }
                self.didFetch(self.dataSource.count)
            }
            
            self.delegate?.didFetchFor(skip: skip)
            
            if let collectionView = self.collectionView {
                if skip == 0 {
                    // Reload data
                    collectionView.reloadData()
                    if self.isFirstFetch || collectionView.alpha == 0 {
                        self.isFirstFetch = false
                        collectionView.animateFadeIn()
                    }
                    
                } else if let result = task.result as? [PFObject] {
                    // Insert rows
                    collectionView.performBatchUpdates({ () -> Void in
                        let endIndex = self.dataSource.count
                        // TODO: Will crash here for posts
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
                    if self.isFirstFetch {
                        self.isFirstFetch = false
                        tableView.animateFadeIn()
                    }
                    
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
        }).continueWithBlock({ (task: BFTask!) -> AnyObject! in
            if let exception = task.exception {
                println(exception)
            }
            return nil
        })

        return fetchTask
    }
}
