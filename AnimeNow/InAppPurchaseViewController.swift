//
//  InAppPurchaseViewController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/7/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit

class InAppPurchaseViewController: UITableViewController {
    
    @IBOutlet weak var profileAvatar: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var proButton: UIButton!
    @IBOutlet weak var proPlusButton: UIButton!
    
    @IBOutlet weak var chartsButton: UIButton!
    @IBOutlet weak var browseButton: UIButton!
    @IBOutlet weak var removeAdsButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Aozora Pro"
        
    }
    
    @IBAction func buyProPressed(sender: AnyObject) {
    }
    
    @IBAction func buyProPlusPressed(sender: AnyObject) {
    }
    
    @IBAction func buySeasonalChartsPressed(sender: AnyObject) {
    }

    @IBAction func buyBrowsePressed(sender: AnyObject) {
    }
    
    @IBAction func buyRemoveAdsPressed(sender: AnyObject) {
    }
}
