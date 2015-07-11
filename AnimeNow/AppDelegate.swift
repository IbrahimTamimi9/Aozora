//
//  AppDelegate.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 4/29/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANParseKit
import ANAnimeKit
import ANCommonKit
import XCDYouTubeKit
import JTSImageViewController
import iRate
import FBSDKShareKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    override class func initialize() -> Void {
        iRate.sharedInstance().promptForNewVersionIfUserRated = true
        iRate.sharedInstance().daysUntilPrompt = 5.0
        iRate.sharedInstance().verboseLogging = false
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Initialization
        registerParse()
        // Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
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
        
        // Push notifications
        let userNotificationTypes = (UIUserNotificationType.Alert |  UIUserNotificationType.Badge |  UIUserNotificationType.Sound);
        
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        // Ads
        if InAppController.purchasedAnyPro() == nil {
            UIViewController.prepareInterstitialAds()
        }
        
        // Appearance
        customizeAppearance()
    
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        var currentUser = PFUser.currentUser()
        
        if currentUser != nil {
            WorkflowController.presentRootTabBar(animated: false)
            
        } else {
            WorkflowController.presentOnboardingController(true)
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
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
    
    func registerParse() {
        // Register subclasses
        AnimeDetail.registerSubclass()
        AnimeCast.registerSubclass()
        AnimeCharacter.registerSubclass()
        AnimeRelation.registerSubclass()
        AnimeReview.registerSubclass()
        Anime.registerSubclass()
        SeasonalChart.registerSubclass()
        Episode.registerSubclass()
        
        // TODO: Implement this
        Parse.enableLocalDatastore()
        
        // Initialize Parse.
        Parse.setApplicationId("X95vv1iNbXWqoEClbK5XzGvjuydWKQk2Ti2n8OPn",
            clientKey: "vvsbzUBBgnPKCoYQlltREy5S0gSIgMfBp34aDrkc")
        
        // AnimeTrakr Keys temp
        //        Parse.setApplicationId("nLCbHmeklHp6gBly9KHZOZNSMBTyuvknAubwHGAQ",
        //            clientKey: "yVixWhPhTM9yGmjtfm1isbC7Ekxq29eNLTzu6KzM")
        


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
        }else {
            return Int(UIInterfaceOrientationMask.Portrait.rawValue);
        }
    }
    
}



extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
