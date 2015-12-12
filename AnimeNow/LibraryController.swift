//
//  LibraryController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 12/6/15.
//  Copyright © 2015 AnyTap. All rights reserved.
//

import Foundation
import Bolts

public protocol LibraryControllerDelegate: class {
    func libraryControllerFinishedFetchingLibrary(library: [Anime])
}

public class LibraryController {
    
    public static let LastSyncDateDefaultsKey = "LibrarySync.LastSyncDate"

    public static let sharedInstance = LibraryController()
    
    public var library: [Anime]?
    public var progress: [AnimeProgress]?
    public var currentlySyncing = false
    public weak var delegate: LibraryControllerDelegate?
    
    public func fetchAnimeList(isRefreshing: Bool) -> BFTask {
        
        currentlySyncing = true
        
        let shouldSyncData = NSUserDefaults.shouldPerformAction(LibraryController.LastSyncDateDefaultsKey, expirationDays: 1)
        
        var fetchTask: BFTask!
        
        if isRefreshing || shouldSyncData {
            fetchTask = LibrarySyncController.refreshAozoraLibrary()
        } else {
            fetchTask = LibrarySyncController.fetchAozoraLibrary()
        }
        
        fetchTask.continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task: BFTask) -> BFTask in
            
            if let result = task.result as? [Anime] {
                self.library = result
                self.progress = result
                    .filter({return $0.progress != nil})
                    .map({return $0.progress!})
                self.delegate?.libraryControllerFinishedFetchingLibrary(result)
                NSUserDefaults.completedAction(LibraryController.LastSyncDateDefaultsKey)
            }
            self.currentlySyncing = false
            
            return task
        })
        
        return fetchTask
    }
}