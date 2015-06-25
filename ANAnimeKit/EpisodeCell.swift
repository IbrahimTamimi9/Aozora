//
//  EpisodeCell.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/24/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit

class EpisodeCell: UICollectionViewCell {
    
    @IBOutlet weak var screenshotImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var firstAiredLabel: UILabel!
    
    @IBOutlet weak var watchedButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBAction func morePressed(sender: AnyObject) {
        
    }
    
    @IBAction func watchedPressed(sender: AnyObject) {
        
    }
}
