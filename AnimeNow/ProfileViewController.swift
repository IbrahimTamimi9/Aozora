//
//  ProfileViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/20/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation


class ProfileViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        segmentedControl.setDividerImage(UIImage(), forLeftSegmentState: UIControlState.Selected, rightSegmentState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
        segmentedControl.setDividerImage(UIImage(), forLeftSegmentState: UIControlState.Normal, rightSegmentState: UIControlState.Selected, barMetrics: UIBarMetrics.Default)
        
        segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.whiteColor()], forState: UIControlState.Selected)
        segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.lightGrayColor()], forState: UIControlState.Normal)
        
        segmentedControl.setBackgroundImage(UIImage(), forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
        segmentedControl.setBackgroundImage(UIImage(named: "segmented-background-selected"), forState: UIControlState.Selected, barMetrics: UIBarMetrics.Default)


        
    }
}