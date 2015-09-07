//
//  ForumViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/21/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANCommonKit
import ANAnimeKit
import ANParseKit
import TTTAttributedLabel

class ForumsViewController: UIViewController {
    
    enum SelectedList: Int {
        case Recent = 0
        case New
        case Tag
    }
    
    var loadingView: LoaderView!
    var tagsDataSource: [ThreadTag] = []
    var dataSource: [Thread] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBarTitle: UILabel!
    
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
        
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "changeList")
        navigationBarTitle.addGestureRecognizer(tapGestureRecognizer)
        
        fetchThreadTags()
        cachePinnedPosts()
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
            navigationBarTitle.text = "Recent Threads"
            fetchThreads()
        case .New:
            navigationBarTitle.text = "New Threads"
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
            
            let dataSource = [["Recent Threads", "New Threads"], tagsTitles]
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
    
    func fetchThreads() {
        
        self.fetchController.resetToDefaults()
        self.fetchController.tableView?.reloadData()
        
        let query = Thread.query()!
        query.whereKey("replies", greaterThan: 0)
        query.whereKeyExists("episode")
        
        let query2 = Thread.query()!
        query2.whereKeyDoesNotExist("episode")
        
        let orQuery = PFQuery.orQueryWithSubqueries([query, query2])
        orQuery.whereKey("pinned", notEqualTo: true)
        orQuery.includeKey("tags")
        orQuery.includeKey("startedBy")
        
        switch selectedList {
        case .Recent:
            orQuery.orderByDescending("updatedAt")
        case .New:
            orQuery.orderByDescending("createdAt")
        default:
            break
        }
        
        fetchController.configureWith(self, query: orQuery, tableView: tableView, limit: 50)
    }
    
    func fetchTagThreads(tag: PFObject) {

        self.fetchController.resetToDefaults()
        self.fetchController.tableView?.reloadData()
        
        let query = Thread.query()!
        query.fromLocalDatastore()
        query.whereKey("tags", containedIn: [tag])
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if let pinnedData = result as? [Thread] {
                let query = Thread.query()!
                query.whereKey("tags", containedIn: [tag])
                query.whereKey("pinned", notEqualTo: true)
                query.includeKey("tags")
                query.includeKey("startedBy")
                query.orderByDescending("updatedAt")
                self.fetchController.configureWith(self, query: query, tableView: self.tableView, limit: 50, pinnedData: pinnedData)
            }
        }
    }
    
    func fetchThreadTags() {
        let query = ThreadTag.query()!
        query.orderByAscending("order")
        query.findCachedOrNetwork(AllThreadTagsPin, expirationDays: 1).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
            self.tagsDataSource = task.result as! [ThreadTag]
            return nil
        }
    }
    
    func cachePinnedPosts() {
        let query = Thread.query()!
        query.whereKey("pinned", equalTo: true)
        query.findCachedOrNetwork(PinnedThreadsPin, expirationDays: 1)
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
            cell.typeLabel.text = " "
        } else if thread.pinned {
            cell.typeLabel.text = " "
        } else {
            cell.typeLabel.text = ""
        }
        
        cell.title.text = title
        cell.information.text = "\(thread.replies) comments · \(thread.updatedAt!.timeAgo())"
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
        
        if InAppController.purchasedAnyPro() == nil {
            threadController.interstitialPresentationPolicy = .Automatic
        }
        
        navigationController?.pushViewController(threadController, animated: true)
    }
}

extension ForumsViewController: FetchControllerDelegate {
    func didFetchFor(#skip: Int) {
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
            let index = url.pathComponents?[1] as? String,
            let idx = index.toInt() {
                println(idx)
        }
    }
}

extension ForumsViewController: CommentViewControllerDelegate {
    func commentViewControllerDidFinishedPosting(post: PFObject) {
        prepareForList(selectedList)
    }
}