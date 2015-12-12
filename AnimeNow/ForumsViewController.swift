//
//  ForumViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/21/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANCommonKit
import ANParseKit
import TTTAttributedLabel

class ForumsViewController: UIViewController {
    
    enum SelectedList: Int {
        case Recent = 0
        case New
        case Tag
    }
    
    let recentActivityString = "Recent Activity"
    let newThreadsString = "New Threads"
    
    var loadingView: LoaderView!
    var tagsDataSource: [ThreadTag] = []
    var dataSource: [Thread] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBarTitle: UILabel!
    @IBOutlet weak var createThreadButton: UIButton!
    
    var fetchController = FetchController()
    var refreshControl = UIRefreshControl()
    var selectedList: SelectedList = .Recent
    var selectedTag: PFObject?
    var timer: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 150.0
        tableView.rowHeight = UITableViewAutomaticDimension

        loadingView = LoaderView(parentView: view)
        loadingView.startAnimating()
        
        addRefreshControl(refreshControl, action:"refetchThreads", forTableView: tableView)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: "reloadTableView", userInfo: nil, repeats: true)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "changeList")
        navigationBarTitle.addGestureRecognizer(tapGestureRecognizer)
        
        fetchThreadTags()
        prepareForList(selectedList)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if loadingView.animating == false {
            loadingView.stopAnimating()
            tableView.animateFadeIn()
        }
    }
    
    // MARK: - NavigationBar Options
    
    func prepareForList(selectedList: SelectedList) {
        self.selectedList = selectedList
        
        switch selectedList {
        case .Recent:
            navigationBarTitle.text = recentActivityString
            fetchThreads()
        case .New:
            navigationBarTitle.text = newThreadsString
            fetchThreads()
        case .Tag:
            if let tag = selectedTag {
                if let anime = tag as? Anime {
                    navigationBarTitle.text = anime.title!
                } else if let tag = tag as? ThreadTag {
                    navigationBarTitle.text = tag.name
                }
                fetchTagThreads(tag)
            }
        }
        
        navigationBarTitle.text! += " " + FontAwesome.AngleDown.rawValue
    }
    
    func changeList() {
        if let sender = navigationController?.navigationBar,
        let viewController = tabBarController where view.window != nil {
            var tagsTitles: [String] = []
            
            for tag in tagsDataSource {
                tagsTitles.append(" #"+tag.name)
            }
            
            let dataSource = [[recentActivityString, newThreadsString], tagsTitles]
            DropDownListViewController.showDropDownListWith(
                sender: sender,
                viewController: viewController,
                delegate: self,
                dataSource: dataSource)
        }
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
    // MARK: - Fetching
    
    func refetchThreads() {
        prepareForList(selectedList)
    }
    
    var startDate: NSDate?
    
    func fetchThreads() {
        
        startDate = NSDate()
        
        let pinnedQuery = Thread.query()!
        pinnedQuery.whereKey("pinType", equalTo: "global")
        pinnedQuery.includeKey("tags")
        pinnedQuery.includeKey("lastPostedBy")
        pinnedQuery.includeKey("startedBy")
        pinnedQuery.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if let pinnedData = result as? [Thread] {
                let query = Thread.query()!
                query.whereKey("replies", greaterThan: 0)
                query.whereKeyExists("episode")
                
                let query2 = Thread.query()!
                query2.whereKeyDoesNotExist("episode")
                
                let orQuery = PFQuery.orQueryWithSubqueries([query, query2])
                orQuery.whereKeyDoesNotExist("pinType")
                orQuery.includeKey("tags")
                orQuery.includeKey("startedBy")
                orQuery.includeKey("lastPostedBy")
                
                let introductions = ThreadTag(withoutDataWithObjectId: "loJp4QyahU")
                let aozoraOfficial = ThreadTag(withoutDataWithObjectId: "zXotNtfVg1")
                let news = ThreadTag(withoutDataWithObjectId: "H3dDEdJyqu")
                let anime = ThreadTag(withoutDataWithObjectId: "6Yv0cRDTfc")
                let manga = ThreadTag(withoutDataWithObjectId: "D9mO8EBXdV")
                let releaseDiscussion = ThreadTag(withoutDataWithObjectId: "RJsWGXGsBQ")
                let recommendations = ThreadTag(withoutDataWithObjectId: "EfFWzzrhOa")
                let visualNovels = ThreadTag(withoutDataWithObjectId: "EwnE6nP7RJ")
                let lightNovels = ThreadTag(withoutDataWithObjectId: "KaXJ4jurky")
                let forumGames = ThreadTag(withoutDataWithObjectId: "M4rpxLDwai")
                let music = ThreadTag(withoutDataWithObjectId: "TYToNcM2zm")
                let offtopic = ThreadTag(withoutDataWithObjectId: "DGXMVEcSrd")
                let fanFiction = ThreadTag(withoutDataWithObjectId: "cHlPtcRMW2")
                orQuery.whereKey("tags", containedIn: [introductions, aozoraOfficial, news, anime, manga, releaseDiscussion, recommendations, visualNovels, lightNovels, forumGames, music, offtopic, fanFiction])
                
                switch self.selectedList {
                case .Recent:
                    orQuery.orderByDescending("updatedAt")
                case .New:
                    orQuery.orderByDescending("createdAt")
                default:
                    break
                }
                
                self.fetchController.configureWith(self, query: orQuery, tableView: self.tableView, limit: 50, pinnedData: pinnedData)
            }
        }
    }
    
    func fetchTagThreads(tag: PFObject) {
        
        let query = Thread.query()!
        query.whereKey("pinType", equalTo: "tag")
        query.whereKey("tags", containedIn: [tag])
        query.includeKey("tags")
        query.includeKey("lastPostedBy")
        query.includeKey("startedBy")
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if let pinnedData = result as? [Thread] {
                let query = Thread.query()!
                
                // Remove episodes without comments from #Release Discussion tag
                let releaseDiscussionObjectId = "RJsWGXGsBQ"
                if tag.objectId! == releaseDiscussionObjectId {
                    query.whereKey("replies", greaterThan: 0)
                    query.whereKeyExists("episode")
                }
                
                query.whereKey("tags", containedIn: [tag])
                query.whereKeyDoesNotExist("pinType")
                query.includeKey("tags")
                query.includeKey("lastPostedBy")
                query.includeKey("startedBy")
                query.orderByDescending("updatedAt")
                self.fetchController.configureWith(self, query: query, tableView: self.tableView, limit: 50, pinnedData: pinnedData)
            }
        }
    }
    
    func fetchThreadTags() {
        let query = ThreadTag.query()!
        query.orderByAscending("order")
        query.findObjectsInBackground().continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
            self.tagsDataSource = task.result as! [ThreadTag]
            return nil
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func createThread(sender: AnyObject) {
        
        if User.currentUserLoggedIn() {
            let comment = ANParseKit.newThreadViewController()
            comment.initWith(threadType: ThreadType.Custom, delegate: self)
            presentViewController(comment, animated: true, completion: nil)
        } else {
            presentBasicAlertWithTitle("Login first", message: "Select 'Me' tab to login", style: .Alert)
        }
    }
    
    @IBAction func searchForums(sender: AnyObject) {
        
        if let tabBar = tabBarController {
            let (navigation, controller) = ANAnimeKit.searchViewController()
            controller.initWithSearchScope(SearchViewController.SearchScope.Forum)
            tabBar.presentViewController(navigation, animated: true, completion: nil)
        }
    }
    
}

extension ForumsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return fetchController.dataCount()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TopicCell") as! TopicCell
        
        let thread = fetchController.objectAtIndex(indexPath.row) as! Thread
        let title = thread.title
        
        if let _ = thread.episode {
            cell.typeLabel.text = " "
        } else if let _ = thread.pinType {
            cell.typeLabel.text = " "
        } else if thread.locked {
            cell.typeLabel.text = " "
        } else {
            cell.typeLabel.text = ""
        }
        
        cell.title.text = title
        let lastPostedByUsername = thread.lastPostedBy?.aozoraUsername ?? ""
        cell.information.text = "\(thread.replies) comments · \(thread.updatedAt!.timeAgo()) · \(lastPostedByUsername)"
        cell.tagsLabel.updateTags(thread.tags, delegate: self, addLinks: false)
        cell.layoutIfNeeded()
        return cell
    }
}

extension ForumsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let thread = fetchController.objectAtIndex(indexPath.row) as! Thread
        
        let threadController = ANAnimeKit.customThreadViewController()
        
        if let episode = thread.episode, let anime = thread.anime {
            threadController.initWithEpisode(episode, anime: anime)
        } else {
            threadController.initWithThread(thread)
        }
        
        if InAppController.hasAnyPro() == nil {
            threadController.interstitialPresentationPolicy = .Automatic
        }
        
        navigationController?.pushViewController(threadController, animated: true)
    }
}

extension ForumsViewController: FetchControllerDelegate {
    func didFetchFor(skip skip: Int) {
        
        if let startDate = startDate {
            print("Load forums = \(NSDate().timeIntervalSinceDate(startDate))s")
            self.startDate = nil
        }
        
        refreshControl.endRefreshing()
        loadingView.stopAnimating()
    }
}

extension ForumsViewController: DropDownListDelegate {
    func selectedAction(trigger: UIView, action: String, indexPath: NSIndexPath) {
        
        if trigger.isEqual(navigationController?.navigationBar) {
            switch (indexPath.row, indexPath.section) {
            case (0, 0):
                prepareForList(.Recent)
            case (1, 0):
                prepareForList(.New)
            case (_, 1):
                selectedTag = tagsDataSource[indexPath.row]
                prepareForList(.Tag)
            default: break
            }
        }
    }
    
    func dropDownDidDismissed(selectedAction: Bool) {
    }
}

extension ForumsViewController: TTTAttributedLabelDelegate {
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        
        if let host = url.host where host == "tag",
            let index = url.pathComponents?[1],
            let idx = Int(index) {
                print(idx)
        }
    }
}

extension ForumsViewController: CommentViewControllerDelegate {
    func commentViewControllerDidFinishedPosting(post: PFObject, parentPost: PFObject?, edited: Bool) {
        prepareForList(selectedList)
    }
}