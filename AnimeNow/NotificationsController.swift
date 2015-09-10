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
            let targetTimelinePost = TimelinePost(withoutDataWithObjectId: objectId)
            let profileController = ANAnimeKit.notificationThreadViewController()
            profileController.initWithPost(targetTimelinePost)
            if let topVC = UIApplication.topViewController() {
                topVC.presentViewController(profileController, animated: true, completion: nil)
            }
        case "Post":
            let targetPost = Post(withoutDataWithObjectId: objectId)
            let profileController = ANAnimeKit.notificationThreadViewController()
            profileController.initWithPost(targetPost)
            if let topVC = UIApplication.topViewController() {
                topVC.presentViewController(profileController, animated: true, completion: nil)
            }
        default:
            break
        }
        
    }
}