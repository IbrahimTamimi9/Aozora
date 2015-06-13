//
//  AnimeCell.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/4/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit

class AnimeCell: UICollectionViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var etaLabel: UILabel?
    @IBOutlet weak var studioLabel: UILabel?
    @IBOutlet weak var sourceLabel: UILabel?
    @IBOutlet weak var genresLabel: UILabel?
    
    @IBOutlet weak var nextEpisodeNumberLabel: UILabel?
    @IBOutlet weak var etaTimeLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.frame = bounds
        contentView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
    }
    
}
