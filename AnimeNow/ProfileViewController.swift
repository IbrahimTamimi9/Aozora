//
//  ProfileViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/20/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Alamofire
import ANCommonKit

enum ProfileSection: String {
    case History = "History"
    case Profile = "Profile"
    case Friends = "Friends"
}

class ProfileViewController: XLButtonBarPagerTabStripViewController {

    var username: String?
    
    var history: UserHistoryViewController!
    var profile: UserProfileViewController!
    var friends: UserFriendsViewController!
    
    @IBOutlet weak var reminderBBI: UIBarButtonItem!
    @IBOutlet weak var settingsBBI: UIBarButtonItem!
    
    var loadingView: LoaderView!
    
    
    func initWithUsername(username: String) {
        self.username = username
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView = LoaderView(parentView: view)
        
        isProgressiveIndicator = true
        buttonBarView.selectedBar.backgroundColor = UIColor.peterRiver()
        title = username
        
        loadingView.startAnimating()
        
        userProfile(username!).continueWithBlock
        { (task: BFTask!) -> AnyObject! in
            
            self.loadingView.stopAnimating()
            
            if let result = task.result as? [String: AnyObject] {
                
                let details = result["details"] as! [String:AnyObject]
                let animeStatsData = result["anime_stats"] as! [String:Int]
                let mangaStatsData = result["manga_stats"] as! [String:Int]
                
                
                var profile = Profile()
                profile.username = self.username!
                profile.avatarURL = result["avatar_url"] as? String ?? ""
                profile.lastOnline = details["last_online"] as? String ?? ""
                profile.gender = details["gender"] as? String ?? ""
                profile.joinDate = details["join_date"] as? String ?? ""
                profile.accessRank = details["accessRank"] as? String ?? ""
                profile.animeListViews = details["anime_list_views"] as! Int
                profile.mangaListViews = details["manga_list_views"] as! Int
                profile.forumPosts = details["forum_posts"] as! Int
                
                var animeStats = profile.animeStats
                animeStats.timeDays = Double(animeStatsData["time_days"]!)
                animeStats.watching = animeStatsData["watching"]!
                animeStats.completed = animeStatsData["completed"]!
                animeStats.onHold = animeStatsData["on_hold"]!
                animeStats.dropped = animeStatsData["dropped"]!
                animeStats.planToWatch = animeStatsData["plan_to_watch"]!
                animeStats.totalEntries = animeStatsData["total_entries"]!
                
                
                var mangaStats = profile.mangaStats
                mangaStats.timeDays = Double(mangaStatsData["time_days"]!)
                mangaStats.reading = mangaStatsData["reading"]!
                mangaStats.completed = mangaStatsData["completed"]!
                mangaStats.onHold = mangaStatsData["on_hold"]!
                mangaStats.dropped = mangaStatsData["dropped"]!
                mangaStats.planToRead = mangaStatsData["plan_to_read"]!
                mangaStats.totalEntries = mangaStatsData["total_entries"]!
                
                
                self.profile.setUserProfile(profile)
            }
            
            return nil
        }
        
    }
    
    func userProfile(username: String) -> BFTask! {
        let completionSource = BFTaskCompletionSource()
        Alamofire.request(Atarashii.Router.profile(username: username)).validate().responseJSON { (req, res, JSON, error) -> Void in
            if error == nil {
                completionSource.setResult(JSON)
            } else {
                completionSource.setError(error)
            }
        }
        return completionSource.task
    }
    
    @IBAction func showRemindersPressed(sender: AnyObject) {
    }
    
    @IBAction func showSettingsPressed(sender: AnyObject) {
        let controller = UIStoryboard(name: "Settings", bundle: nil).instantiateInitialViewController() as! UIViewController
        presentViewController(controller, animated: true, completion: nil)
    }
    
    
    
    // MARK: - Classes
    
    class Profile {
        var username = ""
        var avatarURL = ""
        var lastOnline = ""
        var gender = ""
        var joinDate = ""
        var accessRank = ""
        var animeListViews = 0
        var mangaListViews = 0
        var forumPosts = 0
        var comments = 0
        var animeStats = AnimeStats()
        var mangaStats = MangaStats()
    }
    
    class AnimeStats {
        var timeDays: Double = 0.0
        var watching: Int = 0
        var completed: Int = 0
        var onHold: Int = 0
        var dropped: Int = 0
        var planToWatch: Int = 0
        var totalEntries: Int = 0
    }
    
    class MangaStats {
        var timeDays: Double = 0.0
        var reading: Int = 0
        var completed: Int = 0
        var onHold: Int = 0
        var dropped: Int = 0
        var planToRead: Int = 0
        var totalEntries: Int = 0
    }
    
}

extension String {
    func intValue() -> Int {
        return self.toInt() ?? 0
    }
    func doubleValue() -> Double {
        return (self as NSString).doubleValue
    }
}

extension ProfileViewController: XLPagerTabStripViewControllerDataSource {
    override func childViewControllersForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> [AnyObject]! {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        
        history = storyboard.instantiateViewControllerWithIdentifier("UserHistory") as! UserHistoryViewController
        profile = storyboard.instantiateViewControllerWithIdentifier("UserProfile") as! UserProfileViewController
        friends = storyboard.instantiateViewControllerWithIdentifier("UserFriends") as! UserFriendsViewController
        
        history.initWithProfileSection(.History, username: username!)
        profile.initWithProfileSection(.Profile, username: username!)
        friends.initWithProfileSection(.Friends, username: username!)
        
        return [profile, history, friends]
    }
}