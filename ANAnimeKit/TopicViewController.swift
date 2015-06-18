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

public class TopicViewController: UIViewController {
    
    var malScrapper: MALScrapper!
    var dataSource: [MALScrapper.Post] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var loadingView: LoaderView!
    var topic: MALScrapper.Topic!
    
    @IBOutlet weak var tableView: UITableView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = topic.title
        
        tableView.estimatedRowHeight = 40.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        loadingView = LoaderView()
        loadingView.addToViewController(self)
        loadingView.startAnimating()
        
        malScrapper = MALScrapper(viewController: self)
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
            
            cell.contentView.backgroundColor = UIColor(white: CGFloat((97-content.level*6))/100.0, alpha: 1.0)
            cell.layoutIfNeeded()
            return cell
        case .Image:
            let cell = tableView.dequeueReusableCellWithIdentifier("ImageCell") as! BasicTableCell
            cell.titleimageView.setImageFrom(urlString: content.content, animated: true)
            cell.contentView.backgroundColor = UIColor(white: CGFloat((97-content.level*6))/100.0, alpha: 1.0)
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
        
    }
}


extension TopicViewController: TTTAttributedLabelDelegate {

    public func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        
        let (navController, webController) = ANCommonKit.webViewController()
        webController.initialUrl = url
        presentViewController(navController, animated: true, completion: nil)
    }
}