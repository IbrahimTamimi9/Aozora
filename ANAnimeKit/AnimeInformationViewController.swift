//
//  AnimeInformationViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/9/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import Shimmer
import ANCommonKit

enum AnimeSection: Int {
    case Synopsis = 0
    case Relations
    case Information
    case Characters
    case Reviews
    case ExternalLinks
    
    static var allSections: [AnimeSection] = [.Synopsis,.Relations,.Information,.Characters,.Reviews,.ExternalLinks]
}

public class AnimeInformationViewController: UIViewController {
    
    var canHideStatusBar = true
    @IBOutlet public weak var tableView: UITableView!
    @IBOutlet weak var shimeringView: FBShimmeringView!
    @IBOutlet weak var animeTitle: UILabel!
    @IBOutlet weak var openInAnimeTrakr: UILabel!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    @IBOutlet weak var shimeringViewTopConstraint: NSLayoutConstraint!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        //shimeringView.contentView = animeTitle
        //shimeringView.shimmering = true
        
        openInAnimeTrakr.layer.borderColor = UIColor.belizeHole().CGColor
        openInAnimeTrakr.layer.borderWidth = 2.0
        openInAnimeTrakr.layer.cornerRadius = 2.0
        openInAnimeTrakr.layer.backgroundColor = UIColor.peterRiver().CGColor
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80.0
        
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
        canHideStatusBar = true
    }

    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        canHideStatusBar = false
    }

}

extension AnimeInformationViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
        var newOffset = 194-scrollView.contentOffset.y
        var shimmerOffset = newOffset-44
        shimeringViewTopConstraint.constant = (shimmerOffset > 20) ? shimmerOffset : 20
    
        if shimmerOffset > 20 {
            if canHideStatusBar {
                UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
            }
        } else {
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        }
    
        topViewHeight.constant = newOffset
    }
}

extension AnimeInformationViewController: UITableViewDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return AnimeSection.allSections.count;
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        switch AnimeSection(rawValue: section)! {
            case .Synopsis: numberOfRows = 1
            case .Relations: numberOfRows = 1
            case .Information: numberOfRows = 1
            case .Characters: numberOfRows = 1
            case .Reviews: numberOfRows = 1
            case .ExternalLinks: numberOfRows = 1
        }
        
        return numberOfRows
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch AnimeSection(rawValue: indexPath.section)! {
        case .Synopsis:
            let cell = tableView.dequeueReusableCellWithIdentifier("SynopsisCell") as! BasicTableCell
            return cell
        case .Relations:
            let cell = tableView.dequeueReusableCellWithIdentifier("SynopsisCell") as! BasicTableCell
            return cell
        case .Information:
            let cell = tableView.dequeueReusableCellWithIdentifier("SynopsisCell") as! BasicTableCell
            return cell
        case .Characters:
            let cell = tableView.dequeueReusableCellWithIdentifier("SynopsisCell") as! BasicTableCell
            return cell
        case .Reviews:
            let cell = tableView.dequeueReusableCellWithIdentifier("SynopsisCell") as! BasicTableCell
            return cell
        case .ExternalLinks:
            let cell = tableView.dequeueReusableCellWithIdentifier("SynopsisCell") as! BasicTableCell
            return cell
        default:
            break;
        }
        
        return UITableViewCell()
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! BasicTableCell
        var title = ""
        
        switch AnimeSection(rawValue: section)! {
        case .Synopsis: title = "Synopsis"
        case .Relations: title = "Relations"
        case .Information: title = "Information"
        case .Characters: title = "Characters"
        case .Reviews: title = "Reviews"
        case .ExternalLinks: title = "External Links"
        }
        
        cell.titleLabel.text = title
        return cell
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    
    
}

extension AnimeInformationViewController: UITableViewDelegate {
    
}