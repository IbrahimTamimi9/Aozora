//
//  PostUserCell.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/28/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import TTTAttributedLabel

public class CommentCell: UITableViewCell {
    
    @IBOutlet public weak var avatar: UIImageView!
    @IBOutlet public weak var textContent: TTTAttributedLabel!
    @IBOutlet public weak var date: UILabel!
    
    @IBOutlet public weak var imageContent: UIImageView?
    @IBOutlet public weak var playButton: UIButton?
    
    public enum CellType {
        case Text
        case Image
        case Video
    }
    
    public class func registerNibFor(#tableView: UITableView, type: CommentCell.CellType) {
        switch type {
        case .Text:
            let listNib = UINib(nibName: "CommentTextCell", bundle: ANCommonKit.bundle())
            tableView.registerNib(listNib, forCellReuseIdentifier: "CommentTextCell")
        case .Image:
            let listNib = UINib(nibName: "CommentImageCell", bundle: ANCommonKit.bundle())
            tableView.registerNib(listNib, forCellReuseIdentifier: "CommentImageCell")
        case .Video:
            let listNib = UINib(nibName: "", bundle: nil)
            tableView.registerNib(listNib, forCellReuseIdentifier: "")
        }
        
    }
}