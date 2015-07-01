//
//  DataFetchController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/27/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation

public protocol DataFetchControllerDelegate: class {
    func fetchFor(#page: Int, skip: Int)
}
public class DataFetchController {

    public weak var delegate: DataFetchControllerDelegate?
    
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
    
    public init() {
        
    }
    
    public func configureWith(delegate: DataFetchControllerDelegate, page: Int = 0, limit: Int = 100) {
        self.delegate = delegate
        defaultPage = page
        defaultLimit = limit
        resetToDefaults()
    }
    
    func resetToDefaults() {
        isFetching = defaultIsFetching
        canFetchMore = defaultCanFetchMore
        dataSourceCount = defaultDataSourceCount
        page = defaultPage
        limit = defaultLimit
    }
    
    public func didDisplayItemAt(#index: Int) {
        
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
    
}
