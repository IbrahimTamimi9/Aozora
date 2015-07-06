//
//  EpisodeCell.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/24/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit

protocol EpisodeCellDelegate: class {
    func episodeCellWatchedPressed(cell: EpisodeCell)
    func episodeCellMorePressed(cell: EpisodeCell)
}

class EpisodeCell: UICollectionViewCell {
    
    weak var delegate: EpisodeCellDelegate?
    
    @IBOutlet weak var screenshotImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var firstAiredLabel: UILabel!
    
    @IBOutlet weak var watchedButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBAction func morePressed(sender: AnyObject) {
        delegate?.episodeCellMorePressed(self)
    }
    
    @IBAction func watchedPressed(sender: AnyObject) {
        delegate?.episodeCellWatchedPressed(self)
    }
}
