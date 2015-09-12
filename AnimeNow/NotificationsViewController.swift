//
//  NotificationViewController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 9/7/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import ANCommonKit
import ANParseKit

class NotificationsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var fetchController = FetchController()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchNotifications()
        title = "Notifications"
        tableView.estimatedRowHeight = 112.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    deinit {
        fetchController.tableView = nil
    }
    
    func fetchNotifications() {
        let query = Notification.query()!
        query.includeKey("lastTriggeredBy")
        query.includeKey("triggeredBy")
        query.includeKey("subscribers")
        query.includeKey("owner")
        query.includeKey("readBy")
        query.whereKey("subscribers", containedIn: [User.currentUser()!])
        query.orderByDescending("updatedAt")
        fetchController.configureWith(self, query: query, queryDelegate:self, tableView: tableView, limit: 50)
    }
    
    @IBAction func dismissViewController(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension NotificationsViewController: UITableViewDataSource {
   
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchController.dataCount()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let notification = fetchController.objectAtIndex(indexPath.row) as! Notification
        
        let cell = tableView.dequeueReusableCellWithIdentifier("NotificationCell") as! BasicTableCell
        

        if notification.lastTriggeredBy == User.currentUser() {
            var selectedUser = notification.lastTriggeredBy
            for user in notification.triggeredBy {
                if user != User.currentUser() {
                    selectedUser = user
                    break
                }
            }
            cell.titleimageView.setImageWithPFFile(selectedUser.avatarThumb!)
        } else {
            cell.titleimageView.setImageWithPFFile(notification.lastTriggeredBy.avatarThumb!)
        }
        

        if notification.owner == User.currentUser() {
            cell.titleLabel.text = notification.messageOwner
        } else if notification.lastTriggeredBy == User.currentUser() {
            cell.titleLabel.text = notification.previousMessage ?? notification.message
        } else {
            cell.titleLabel.text = notification.message
        }
        
        if contains(notification.readBy, User.currentUser()!) {
            cell.contentView.backgroundColor = UIColor.backgroundWhite()
        } else {
            cell.contentView.backgroundColor = UIColor.backgroundDarker()
        }
        
        cell.subtitleLabel.text = notification.updatedAt!.timeAgo()
        cell.layoutIfNeeded()
        return cell
    }
}

extension NotificationsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Open
        let notification = fetchController.objectAtIndex(indexPath.row) as! Notification
        
        if !contains(notification.readBy, User.currentUser()!) {
            notification.addUniqueObject(User.currentUser()!, forKey: "readBy")
            notification.saveEventually()
            tableView.reloadData()
        }
        
        NotificationsController.handleNotification(notification.targetClass, objectId: notification.targetID)
    }
}

extension NotificationsViewController: FetchControllerQueryDelegate {
    func queriesForSkip(#skip: Int) -> [PFQuery]? {
        return nil
    }
    func processResult(#result: [PFObject]) -> [PFObject] {
        let filtered = result.filter({ (object: PFObject) -> Bool in
            let notification = object as! Notification
            return notification.triggeredBy.count > 1 || (notification.triggeredBy.count == 1 && notification.triggeredBy.last != User.currentUser()!)
        })
        return filtered
    }
}

extension NotificationsViewController: FetchControllerDelegate {
    func didFetchFor(#skip: Int) {
        
    }
}

extension NotificationsViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
}