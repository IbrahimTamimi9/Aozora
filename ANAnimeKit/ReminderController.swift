    //
//  ReminderController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/24/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import ANParseKit
import ANCommonKit
import Bolts
import RealmSwift

public class ReminderController {
    public class func scheduleReminderForAnime(anime: Anime) -> Bool {
        
        if let nextEpisode = anime.nextEpisode {
            
            let notificationDate = anime.nextEpisodeDate
            
            var message: String = ""
            if nextEpisode == 1 {
                message = "\(anime.title!) first episode airing today!"
            } else {
                message = "\(anime.title!) ep \(nextEpisode) airing today"
            }
            
            let infoDictionary = ["objectID": anime.myAnimeListID]
            
            var localNotification = UILocalNotification()
            localNotification.fireDate = notificationDate
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            localNotification.alertBody = message
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.userInfo = infoDictionary as [NSObject : AnyObject]
            
            // This is to prevent it to expire
            localNotification.repeatInterval = NSCalendarUnit.CalendarUnitYear
            
            println("Scheduled notification: '" + message + "' for date \(notificationDate)")
            
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            
            return true
        } else {
            return false
        }
    }
    
    public class func disableReminderForAnime(anime: Anime) {
        
        if let notificationToDelete = ReminderController.scheduledReminderFor(anime) {
            UIApplication.sharedApplication().cancelLocalNotification(notificationToDelete)
        }
    }
    
    public class func scheduledReminderFor(anime: Anime) -> UILocalNotification? {
        let scheduledNotifications = UIApplication.sharedApplication().scheduledLocalNotifications as! [UILocalNotification]
        
        let matchingNotifications = scheduledNotifications.filter({ (notification: UILocalNotification) -> Bool in
            let objectID = notification.userInfo as! [String: AnyObject]
            return objectID["objectID"] as! Int == anime.myAnimeListID
        })
        
        return matchingNotifications.last
    }
    
    public class func updateScheduledLocalNotifications() {
        // Update titles, fire dates and disable notifications
        let scheduledNotifications = UIApplication.sharedApplication().scheduledLocalNotifications as! [UILocalNotification]
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        var idList: [Int] = []
        
        for notification in scheduledNotifications {
            let objectID = notification.userInfo as! [String: AnyObject]
            let myAnimelistID = objectID["objectID"] as! Int
            
            idList.append(myAnimelistID)
        }
        
        LibrarySyncController.fetchAnime(idList)
            .continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task: BFTask!) -> AnyObject! in
            
            if let animeList = task.result as? [Anime] {
                
                LibrarySyncController.matchAnimeWithProgress(animeList)
                
                for anime in animeList {
                    if let progress = anime.progress, let list = MALList(rawValue: progress.status) where list != .Dropped {
                        self.scheduleReminderForAnime(anime)
                    }
                }
            }
            
            return nil
        })
    }
    
}