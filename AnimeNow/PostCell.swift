//
//  PostCell.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/28/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import TTTAttributedLabel

public class PostCell: UITableViewCell {
    
    @IBOutlet weak public var avatar: UIImageView!
    @IBOutlet weak public var username: UILabel!
    @IBOutlet weak public var date: UILabel!
    
    @IBOutlet weak public var imageContent: UIImageView?
    @IBOutlet weak public var textContent: TTTAttributedLabel!
    
    @IBOutlet weak public var replyButton: UIButton!
    @IBOutlet weak public var playButton: UIButton?
    
    public enum CellType {
        case Text
        case Image
        case Image2
        case Image3
        case Image4
        case Image5
        case Video
    }
    
    public class func registerNibFor(#tableView: UITableView, type: PostCell.CellType) {
        switch type {
        case .Text:
            let listNib = UINib(nibName: "PostTextCell", bundle: ANCommonKit.bundle())
            tableView.registerNib(listNib, forCellReuseIdentifier: "PostTextCell")
        case .Image:
            let listNib = UINib(nibName: "PostImageCell", bundle: ANCommonKit.bundle())
            tableView.registerNib(listNib, forCellReuseIdentifier: "PostImageCell")
        case .Image2:
            let listNib = UINib(nibName: "", bundle: nil)
            tableView.registerNib(listNib, forCellReuseIdentifier: "")
        case .Image3:
            let listNib = UINib(nibName: "", bundle: nil)
            tableView.registerNib(listNib, forCellReuseIdentifier: "")
        case .Image4:
            let listNib = UINib(nibName: "", bundle: nil)
            tableView.registerNib(listNib, forCellReuseIdentifier: "")
        case .Image5:
            let listNib = UINib(nibName: "", bundle: nil)
            tableView.registerNib(listNib, forCellReuseIdentifier: "")
        case .Video:
            let listNib = UINib(nibName: "", bundle: nil)
            tableView.registerNib(listNib, forCellReuseIdentifier: "")
        }
        
    }
    
    // MARK: - Functions
    
    // MARK: - IBActions
    
    @IBAction func replyPressed(sender: AnyObject) {
    }
}
