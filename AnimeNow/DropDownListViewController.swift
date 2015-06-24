//
//  DropDownListViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/6/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit

public protocol DropDownListDelegate: class {
    func selectedAction(sender: UIView, action: String, indexPath: NSIndexPath)
}

public class DropDownListViewController: UIViewController {
    
    let CellHeight: Int = 44
    
    @IBOutlet weak var clipTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    public weak var delegate: DropDownListDelegate?
    var dataSource = [[String]]()
    var imageDataSource = [[String]]()
    var yPosition: CGFloat = 0
    var showTableView = true
    var trigger: UIView!
    
    public func setDataSource(trigger: UIView, dataSource: [[String]], yPosition: CGFloat, imageDataSource: [[String]]? = [[]]) {
        self.trigger = trigger
        self.dataSource = dataSource
        self.yPosition = yPosition
        self.imageDataSource = imageDataSource!
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        var tableHeight: CGFloat = 0
        
        for array in dataSource {
            tableHeight += CGFloat(array.count*CellHeight) + 22
        }
        
        tableHeight -= 22
        
        self.tableTopSpaceConstraint.constant = -tableHeight
        self.tableHeightConstraint.constant = tableHeight
        
        self.clipTopSpaceConstraint.constant = yPosition
        
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if showTableView {
            showTableView = false
            
            UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut | UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                
                self.tableTopSpaceConstraint.constant = 0
                self.view.layoutIfNeeded()
                
                }) { (finished) -> Void in
                    
            }
        }
    }
    
    @IBAction func dismissPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension DropDownListViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return !touch.view.isDescendantOfView(tableView)
    }
}

extension DropDownListViewController: UITableViewDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = (imageDataSource.count != 0) ? "OptionCell2" : "OptionCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! BasicTableCell
        var title = dataSource[indexPath.section][indexPath.row]
        cell.titleLabel.text = title
        if imageDataSource.count != 0 {
            cell.titleimageView.image = UIImage(named: imageDataSource[indexPath.section][indexPath.row])
        }
        
        return cell
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 22
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var cell = tableView.dequeueReusableCellWithIdentifier("SectionCell") as! BasicTableCell
        return cell.contentView
    }
}

extension DropDownListViewController: UITableViewDelegate {
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let action = dataSource[indexPath.section][indexPath.row]
        delegate?.selectedAction(trigger, action: action, indexPath: indexPath)
        dismissPressed(self)
    }
}
