//
//  BasicTableCell.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/5/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import TTTAttributedLabel

public class BasicTableCell: UITableViewCell {
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var subtitleLabel: UILabel!
    @IBOutlet public weak var titleimageView: UIImageView!
    @IBOutlet public weak var attributedLabel: TTTAttributedLabel!
}
