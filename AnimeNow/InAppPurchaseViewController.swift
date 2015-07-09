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
        
        let purchasedPro = false
        
        if !purchasedPro {
            titleLabel.text = "Upgrade to Pro"
            descriptionLabel.text = "Browse all seasonal charts, unlock calendar view, discover more anime, remove all ads forever, and more importantly helps us take Aozora to the next level"
        } else {
            titleLabel.text = "Sweet, you're Pro"
            descriptionLabel.text = "Thanks for supporting Aozora! You're an exclusive Pro member is helping me create an even better app"
        }
        
        
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
