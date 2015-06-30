//
//  TopicViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/16/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANCommonKit
import ANParseKit
import Bolts
import TTTAttributedLabel
import Parse

public class TopicViewController: UIViewController {
    
    var malScrapper: MALScrapper!
    var dataSource: [MALScrapper.Post] = [] {
        didSet {
            tableView.reloadData()
            
            if scrollToBottom {
                scrollToBottom = false
                UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                    self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.dataSource.count-1, inSection: 0), atScrollPosition: .Bottom, animated: false)
                    }, completion: nil)
            }
        }
    }
    
    var loadingView: LoaderView!
    var topic: MALScrapper.Topic!
    var scrollToBottom = false
    
    @IBOutlet weak var tableView: UITableView!
    
    func initWith(#topic: MALScrapper.Topic, scrapper: MALScrapper) {
        self.topic = topic
        self.malScrapper = scrapper
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = topic.title
        
        tableView.estimatedRowHeight = 40.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        loadingView = LoaderView(parentView: self.view)
        fetchPosts()
        
    }
    
    func fetchPosts() {
        
        loadingView.startAnimating()
        
        malScrapper.postsFor(topic: topic).continueWithBlock {
            (task: BFTask!) -> AnyObject! in
            
            self.tableView.animateFadeIn()
            self.loadingView.stopAnimating()
            if task.result != nil {
                self.dataSource = task.result as! [MALScrapper.Post]
            }
            
            return nil
        }
        
    }
    
    // MARK: - Segue
    
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == "PostReply" {
            let controller = segue.destinationViewController as! NewPostViewController
            controller.initWithTopic(topic, scrapper: malScrapper)
        }
    }
    
    // MARK: - Utility Functions
    
    func backgroundColorForLevel(level: Int) -> UIColor {
        return UIColor(white: CGFloat((97-level*6))/100.0, alpha: 1.0)
    }
    
    // MARK: - IBActions
    
    @IBAction func addCommentPressed(sender: AnyObject) {
        if PFUser.currentUserLoggedIn() {
            performSegueWithIdentifier("PostReply", sender: self)
        } else {
            let storyboard = UIStoryboard(name: "Login", bundle: ANAnimeKit.bundle())
            let loginController = storyboard.instantiateInitialViewController() as! LoginViewController
            presentViewController(loginController, animated: true, completion: nil)
        }
    }
    
}

extension TopicViewController: UITableViewDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.count
    }
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource[section].content.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        let content = dataSource[indexPath.section].content[indexPath.row]

        switch content.type {
        case .Text:
            let cell = tableView.dequeueReusableCellWithIdentifier("TextCell") as! BasicTableCell
            
            cell.attributedLabel.linkAttributes = [kCTForegroundColorAttributeName: UIColor.peterRiver()]
            cell.attributedLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
            cell.attributedLabel.delegate = self;
            cell.attributedLabel.setText(content.content, afterInheritingLabelAttributesAndConfiguringWithBlock: { (attributedString) -> NSMutableAttributedString! in
                
                return attributedString
            })
            for (url, text) in content.links {
                let range = (content.content as NSString).rangeOfString(text)
                cell.attributedLabel.addLinkToURL(url, withRange: range)
            }
            
            cell.contentView.backgroundColor = backgroundColorForLevel(content.level)
            cell.layoutIfNeeded()
            return cell
        case .Image:
            let cell = tableView.dequeueReusableCellWithIdentifier("ImageCell") as! BasicTableCell
            cell.titleimageView.setImageFrom(urlString: content.content, animated: true)
            cell.contentView.backgroundColor = backgroundColorForLevel(content.level)
            cell.layoutIfNeeded()
            return cell
        case .SpoilerButton:
            let spoilerButton = content as! MALScrapper.Post.SpoilerButton
            let cell = tableView.dequeueReusableCellWithIdentifier("SpoilerButtonCell") as! BasicTableCell
            cell.titleLabel.text = spoilerButton.contentIsHidden ? "Show Spoiler" : "Hide Spoiler"
            cell.titleLabel.backgroundColor = backgroundColorForLevel(content.level)
            cell.contentView.backgroundColor = backgroundColorForLevel(content.level-1)
            cell.layoutIfNeeded()
            return cell
        case .Video:
            break;
        }
        
        return UITableViewCell()

    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as! UserCell

        let post = dataSource[section]
        
        cell.avatar.setImageFrom(urlString: post.userAvatar)
        cell.username.text = post.user
        cell.date.text = post.date

        
        return cell.contentView
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("FooterCell") as! BasicTableCell
        return cell.contentView
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 61.0
    }
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15.0
    }
    
}

extension TopicViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let content = dataSource[indexPath.section].content[indexPath.row]
        
        if content.type == .SpoilerButton {
            // Show/hide
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! BasicTableCell
            let spoilerButton = content as! MALScrapper.Post.SpoilerButton
            spoilerButton.contentIsHidden = !spoilerButton.contentIsHidden
            
            if spoilerButton.contentIsHidden {
                dataSource[indexPath.section].content.removeRange(indexPath.row+1..<indexPath.row+1+spoilerButton.spoilerContent.count)
            } else {
                dataSource[indexPath.section].content.splice(spoilerButton.spoilerContent, atIndex: indexPath.row+1)
            }
            tableView.reloadData()
            
        }
    }
}


extension TopicViewController: TTTAttributedLabelDelegate {

    public func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        
        let (navController, webController) = ANCommonKit.webViewController()
        webController.initialUrl = url
        presentViewController(navController, animated: true, completion: nil)
    }
}

extension TopicViewController: NewPostViewControllerDelegate {
    public func didPost() {
        tableView.animateFadeOut()
        scrollToBottom = true
        fetchPosts()
    }
}