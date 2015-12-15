//
//  PostLinkCell.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 12/15/15.
//  Copyright © 2015 AnyTap. All rights reserved.
//

import UIKit
import TTTAttributedLabel

public class LinkCell: PostCell {
    
    @IBOutlet weak var linkTitleLabel: UILabel!
    @IBOutlet weak var linkContentLabel: UILabel!
    @IBOutlet weak var linkUrlLabel: UILabel!
    
    public override class func registerNibFor(tableView tableView: UITableView) {
        
        super.registerNibFor(tableView: tableView)
        
        let listNib = UINib(nibName: "LinkCell", bundle: ANCommonKit.bundle())
        tableView.registerNib(listNib, forCellReuseIdentifier: "LinkCell")
    }
}

