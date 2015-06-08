//
//  DropDownListViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/6/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit

protocol DropDownListDelegate: class {
    func selectedAction(sender: UIView, action: String)
}

class DropDownListViewController: UIViewController {
    
    let CellHeight: Int = 44
    
    @IBOutlet weak var clipTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: DropDownListDelegate?
    var dataSource = [String]()
    var imageDataSource = [String]()
    var yPosition: CGFloat = 0
    var showTableView = true
    var trigger: UIView!
    
    func setDataSource(trigger: UIView, dataSource: [String], yPosition: CGFloat, imageDataSource: [String]? = []) {
        self.trigger = trigger
        self.dataSource = dataSource
        self.yPosition = yPosition
        self.imageDataSource = imageDataSource!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableHeight = CGFloat(dataSource.count*CellHeight)
        self.tableTopSpaceConstraint.constant = -tableHeight
        self.tableHeightConstraint.constant = tableHeight
        
        self.clipTopSpaceConstraint.constant = yPosition
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if showTableView {
            showTableView = false
            
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.85, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                
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
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return !touch.view.isDescendantOfView(tableView)
    }
}

extension DropDownListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = (imageDataSource.count != 0) ? "OptionCell2" : "OptionCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! BasicTableCell
        var title = dataSource[indexPath.row]
        cell.titleLabel.text = title
        if imageDataSource.count != 0 {
            cell.titleimageView.image = UIImage(named: imageDataSource[indexPath.row])
        }
        
        return cell
    }
}

extension DropDownListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let action = dataSource[indexPath.row]
        delegate?.selectedAction(trigger, action: action)
        dismissPressed(self)
    }
}
