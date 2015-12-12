//
//  NotificationsController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 9/9/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import ANParseKit
import CRToast

class NotificationsController {
    
    class func handleNotification(notificationId: String, objectClass: String, objectId: String) {
        
        let notification = Notification(withoutDataWithObjectId: notificationId)
        notification.addUniqueObject(User.currentUser()!, forKey: "readBy")
        notification.saveInBackground()
        
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
                if let _ = error {
                    
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
                if let _ = error {
                    
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
    
    class func showToast(notificationId: String, objectClass: String, objectId: String, message: String) {
        var tapped = false
        
        let responder = CRToastInteractionResponder(interactionType: CRToastInteractionType.TapOnce, automaticallyDismiss: true) { (interaction: CRToastInteractionType) -> Void in
            handleNotification(notificationId, objectClass: objectClass, objectId: objectId)
            tapped = true
        }
        
        // Create toast
        let options = [
            kCRToastInteractionRespondersKey: [responder],
            //kCRToastNotificationTypeKey: CRToastType.NavigationBar.rawValue,
            kCRToastTimeIntervalKey: 2.0,
            kCRToastTextKey : message,
            kCRToastBackgroundColorKey : UIColor.peterRiver(),
            kCRToastAnimationInTypeKey : CRToastAnimationType.Spring.rawValue,
            kCRToastAnimationOutTypeKey : CRToastAnimationType.Spring.rawValue,
            kCRToastAnimationInDirectionKey : CRToastAnimationDirection.Top.rawValue,
            kCRToastAnimationOutDirectionKey : CRToastAnimationDirection.Top.rawValue
            ] as [String: AnyObject]
        
        CRToastManager.showNotificationWithOptions(options) { () -> Void in
            if !tapped {
                NSNotificationCenter.defaultCenter().postNotificationName("newNotification", object: nil)
            }
        }
    }
    
}