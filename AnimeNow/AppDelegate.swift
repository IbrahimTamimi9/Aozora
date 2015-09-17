//
//  AppDelegate.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 4/29/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANParseKit
import ANCommonKit
import XCDYouTubeKit
import JTSImageViewController
import iRate
import FBSDKShareKit
import Fabric
import Crashlytics
import ParseFacebookUtilsV4
import SDWebImage

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    override class func initialize() -> Void {
        iRate.sharedInstance().promptForNewVersionIfUserRated = true
        iRate.sharedInstance().daysUntilPrompt = 2.0
        iRate.sharedInstance().verboseLogging = false
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Fabric.with([Crashlytics()])
        initializeParse()
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        if let userInfo = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject] {
            handleIncomingNotification(userInfo, completionHandler: nil)
        }
        trackPushOpen(application, didFinishLaunchingWithOptions:launchOptions)
        registerForPushNotifications(application)
        prepareForAds()
        customizeAppearance()
    
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        var currentUser = PFUser.currentUser()
        if currentUser != nil {
            WorkflowController.presentRootTabBar(animated: false)
        } else {
            WorkflowController.presentOnboardingController(true)
        }
        
        LibrarySyncController.sharedInstance.syncParseInformation()
        
        SDImageCache.sharedImageCache().maxCacheSize = 1024 * 1024 * 250
        return true
    }
    
    func application(application: UIApplication,
        didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
        fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        handleIncomingNotification(userInfo, completionHandler: completionHandler)
    }
    
    func handleIncomingNotification(userInfo: [NSObject: AnyObject], completionHandler: ((UIBackgroundFetchResult) -> Void)? ) {
        // Extract the notification data
        if let objectClass = userInfo["targetClass"] as? String,
            let objectId = userInfo["targetID"] as? String {
                
                NSNotificationCenter.defaultCenter().postNotificationName("newNotification", object: nil)
                
                let state = UIApplication.sharedApplication().applicationState;
                if state == UIApplicationState.Background || state == UIApplicationState.Inactive
                {
                    NotificationsController.handleNotification(objectClass, objectId: objectId)
                } else {
                    // Not from background
                }
                
                if let completionHandler = completionHandler {
                    completionHandler(UIBackgroundFetchResult.NewData)
                }
                
        } else {
            if let completionHandler = completionHandler {
                completionHandler(UIBackgroundFetchResult.Failed)
            }
        }
    }
    
    func trackPushOpen(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        // Tracking push opens when application is not running nor in background
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced
            // in iOS 7). In that case, we skip tracking here to avoid double
            // counting the app-open.
            let oldPushHandlerOnly = !self.respondsToSelector(Selector("application:didReceiveRemoteNotification:fetchCompletionHandler:"))
            let noPushPayload: AnyObject? = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey]
            if oldPushHandlerOnly || noPushPayload != nil {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
    }
    
    func registerForPushNotifications(application: UIApplication) {
        // Push notifications
        let userNotificationTypes = (UIUserNotificationType.Alert |  UIUserNotificationType.Badge |  UIUserNotificationType.Sound);
        
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }
    
    func prepareForAds() {
        // Ads
        if InAppController.purchasedAnyPro() == nil {
            UIViewController.prepareInterstitialAds()
        }
    }

//    func addEnglishTitles() {
//        let query = Anime.query()!
//        query.includeKey("details")
//        query.selectKeys(["details"])
//        
//        AnimeService.findAllObjectsWith(query: query).continueWithBlock { (task: BFTask!) -> AnyObject! in
//            
//            var sequence = BFTask(result: nil);
//            var result = task.result as! [Anime]
//        
//            for anime in result {
//                sequence = sequence.continueWithBlock {
//                    (task: BFTask!) -> AnyObject! in
//
//                    if let englishTitle = anime.details.englishTitles.first {
//                        anime.titleEnglish = englishTitle
//                    }
//                    return anime.saveInBackground()
//                    
//                }.continueWithBlock {
//                (task: BFTask!) -> AnyObject! in
//                    if (task.exception != nil) {
//                        println(task.exception)
//                    }
//                    return nil
//                }
//            }
//            return sequence
//        }
//    }
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if let user = User.currentUser() {
            // TODO: leave this for a while until everyone who purchased get their badge then remove and keep InAppController one only
            if InAppController.purchasedProPlus() != nil {
                user.addUniqueObject("PRO+", forKey: "badges")
            } else if InAppController.purchasedPro() != nil {
                user.addUniqueObject("PRO", forKey: "badges")
            }
            
            user.active = false
            user.activeEnd = NSDate()
            user.saveInBackground()
        }
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if let user = User.currentUser() {
            user.active = true
            user.activeStart = NSDate()
            user.saveInBackgroundWithBlock({ (success, error) -> Void in
                // Checking for invalid sessions
                if let error = error where error.code == 209 {
                    WorkflowController.logoutUser().continueWithExecutor( BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task: BFTask!) -> AnyObject! in
                        
                        if let error = task.error {
                            println("failed loggin out: \(error)")
                        } else {
                            println("logout succeeded")
                        }
                        WorkflowController.presentOnboardingController(true)
                        return nil
                    })
                }
            })
        }
        
        ReminderController.updateScheduledLocalNotifications()
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Store the deviceToken in the current Installation and save it to Parse
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            println("Push notifications are not supported in the iOS Simulator.")
        } else {
            println("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(
        application: UIApplication,
        didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == .Inactive  {
            // The application was just brought from the background to the foreground,
            // so we consider the app as having been "opened by a push notification."
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }
    
    func application(
    application: UIApplication,
    openURL url: NSURL,
    sourceApplication: String?,
    annotation: AnyObject?) -> Bool {
            
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    // MARK: - Internal functions
    
    func initializeParse() {
        AnimeDetail.registerSubclass()
        AnimeCast.registerSubclass()
        AnimeCharacter.registerSubclass()
        AnimeRelation.registerSubclass()
        AnimeReview.registerSubclass()
        Anime.registerSubclass()
        SeasonalChart.registerSubclass()
        Episode.registerSubclass()
        UserDetails.registerSubclass()
        User.registerSubclass()
        TimelinePost.registerSubclass()
        Thread.registerSubclass()
        Post.registerSubclass()
        AnimeProgress.registerSubclass()
        ThreadTag.registerSubclass()
        Notification.registerSubclass()
        
        Parse.enableLocalDatastore()
        
        Parse.setApplicationId("X95vv1iNbXWqoEClbK5XzGvjuydWKQk2Ti2n8OPn",
            clientKey: "vvsbzUBBgnPKCoYQlltREy5S0gSIgMfBp34aDrkc")
    }
    
    func customizeAppearance() {
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().barTintColor = UIColor.darkBlue()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        UITabBar.appearance().tintColor = UIColor.peterRiver()
        
        UITextField.appearance().textColor = UIColor.whiteColor()
    }
    
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> Int {
        
        let topViewController = UIApplication.topViewController()
        
        if let controller = topViewController as? JTSImageViewController where !controller.isBeingDismissed() {
            return Int(UIInterfaceOrientationMask.All.rawValue);
        } else if let controller = topViewController as? XCDYouTubeVideoPlayerViewController where !controller.isBeingDismissed() {
            return Int(UIInterfaceOrientationMask.All.rawValue);
        } else if let controller = topViewController as? ImageViewController where !controller.isBeingDismissed() {
            return Int(UIInterfaceOrientationMask.All.rawValue);
        } else {
            return Int(UIInterfaceOrientationMask.Portrait.rawValue);
        }
    }
    
}


