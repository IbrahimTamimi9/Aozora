//
//  PostUserCell.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/28/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import TTTAttributedLabel

public class CommentCell: PostCell {
    
    public enum CommentType {
        case Text
        case Image
        case Video
    }
    
    public override class func registerNibFor(#tableView: UITableView) {

        super.registerNibFor(tableView: tableView)
        let listNib = UINib(nibName: "CommentTextCell", bundle: ANCommonKit.bundle())
        tableView.registerNib(listNib, forCellReuseIdentifier: "CommentTextCell")

        let listNib2 = UINib(nibName: "CommentImageCell", bundle: ANCommonKit.bundle())
        tableView.registerNib(listNib2, forCellReuseIdentifier: "CommentImageCell")
    }
    
}