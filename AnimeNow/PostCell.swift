//
//  PostCell.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/28/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import TTTAttributedLabel

public protocol PostCellDelegate: class {
    func postCellSelectedImage(postCell: PostCell)
    func postCellSelectedUserProfile(postCell: PostCell)
    func postCellSelectedComment(postCell: PostCell)
}

public class PostCell: UITableViewCell {
    
    @IBOutlet weak public var avatar: UIImageView!
    @IBOutlet weak public var username: UILabel!
    @IBOutlet weak public var date: UILabel!
    
    @IBOutlet weak public var imageContent: UIImageView?
    @IBOutlet weak public var textContent: TTTAttributedLabel!
    
    @IBOutlet weak public var replyButton: UIButton!
    @IBOutlet weak public var playButton: UIButton?
    
    public weak var delegate: PostCellDelegate?
    
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
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "pressedUserProfile:")
        gestureRecognizer.numberOfTouchesRequired = 1
        gestureRecognizer.numberOfTapsRequired = 1
        avatar.addGestureRecognizer(gestureRecognizer)
        
        let gestureRecognizer2 = UITapGestureRecognizer(target: self, action: "pressedOnImage:")
        gestureRecognizer2.numberOfTouchesRequired = 1
        gestureRecognizer2.numberOfTapsRequired = 1
        imageContent?.addGestureRecognizer(gestureRecognizer2)
    }
    
    // MARK: - IBActions
    
    func pressedUserProfile(sender: AnyObject) {
        delegate?.postCellSelectedUserProfile(self)
    }
    
    func pressedOnImage(sender: AnyObject) {
        delegate?.postCellSelectedImage(self)
    }
    
    @IBAction func replyPressed(sender: AnyObject) {
        delegate?.postCellSelectedComment(self)
    }
}
