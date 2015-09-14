//
//  NotificationsController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 9/9/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import ANParseKit

class NotificationsController {
    
    class func handleNotification(objectClass: String, objectId:String) {
        
        switch objectClass {
        case "_User":
            let targetUser = User.objectWithoutDataWithObjectId(objectId)
            targetUser.fetchInBackgroundWithBlock({ (user, error) -> Void in
                if let user = user as? User {
                    let (navController, profileController) = ANAnimeKit.profileViewController()
                    profileController.initWithUser(user)
                    if let topVC = UIApplication.topViewController() {
                        topVC.presentViewController(navController, animated: true, completion: nil)
                    }
                }
            })
        case "TimelinePost":
            let query = TimelinePost.query()!
            query.whereKey("objectId", equalTo: objectId)
            query.includeKey("userTimeline")
            query.limit = 1
            query.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
                if let error = error {
                    
                } else {
                    let targetTimelinePost = result?.last as! TimelinePost
                    let (navVC, profileController) = ANAnimeKit.notificationThreadViewController()
                    profileController.initWithPost(targetTimelinePost)
                    if let topVC = UIApplication.topViewController() {
                        topVC.presentViewController(navVC, animated: true, completion: nil)
                    }
                }
            })
            
            
        case "Post":
            let query = Post.query()!
            query.whereKey("objectId", equalTo: objectId)
            query.includeKey("thread")
            query.includeKey("thread.tags")
            query.includeKey("thread.anime")
            query.includeKey("thread.episode")
            query.limit = 1
            query.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
                if let error = error {
                    
                } else {
                    let targetPost = result?.last as! Post
                    let (navVC, profileController) = ANAnimeKit.notificationThreadViewController()
                    profileController.initWithPost(targetPost)
                    if let topVC = UIApplication.topViewController() {
                        topVC.presentViewController(navVC, animated: true, completion: nil)
                    }
                }
            })
            
            
        default:
            break
        }
        
    }
}