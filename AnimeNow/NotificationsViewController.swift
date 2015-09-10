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
        fetchController.configureWith(self, query: query, tableView: tableView, limit: 50)
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
            cell.titleimageView.setImageWithPFFile(notification.triggeredBy.last!.avatarThumb!)
        } else {
            cell.titleimageView.setImageWithPFFile(notification.lastTriggeredBy.avatarThumb!)
        }
        

        if notification.owner == User.currentUser() {
            cell.titleLabel.text =  notification.messageOwner
        } else if notification.lastTriggeredBy == User.currentUser() {
            cell.titleLabel.text =  notification.previousMessage
        } else {
            cell.titleLabel.text =  notification.message
        }
        
        if contains(notification.readBy, User.currentUser()!) {
            cell.contentView.backgroundColor = UIColor.backgroundWhite()
        } else {
            cell.contentView.backgroundColor = UIColor.backgroundDarker()
        }
        
        cell.subtitleLabel.text = notification.createdAt!.timeAgo()
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

extension NotificationsViewController: FetchControllerDelegate {
    func didFetchFor(#skip: Int) {
        
    }
}

extension NotificationsViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
}