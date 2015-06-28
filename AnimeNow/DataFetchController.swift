//
//  DataFetchController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/27/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation

protocol DataFetchControllerDelegate: class {
    func fetchFor(#page: Int, skip: Int)
}
class DataFetchController {

    weak var delegate: DataFetchControllerDelegate?
    
    var isFetching = true
    var canFetchMore = true
    var dataSourceCount = 0
    var page = 0
    var limit = 100
    
    func configureWith(delegate: DataFetchControllerDelegate, dataSourceCount: Int = 0, page: Int = 0, limit: Int = 100) {
        self.delegate = delegate
        self.dataSourceCount = dataSourceCount
        self.page = page
        self.limit = limit
    }
    
    func resetToDefaults() {
        isFetching = true
        canFetchMore = true
        dataSourceCount = 0
        page = 0
        limit = 100
    }
    
    func didDisplayItemAt(#index: Int) {
        
        if isFetching || !canFetchMore {
            return
        }
        
        if Float(index) > Float(dataSourceCount) - Float(limit) * 0.2 {
            isFetching = true
            page += 1
            println("Fetching page \(page)")
            delegate?.fetchFor(page: page, skip: page*limit)
        }
    }
    
    func didFetch(newDataSourceCount: Int) {
        
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
    
}
