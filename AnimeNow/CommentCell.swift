//
//  PostUserCell.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/28/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import TTTAttributedLabel

public protocol CommentCellDelegate: class {
    func commentCellSelectedImage(commentCell: CommentCell)
    func commentCellSelectedUserProfile(commentCell: CommentCell)
    func commentCellSelectedComment(commentCell: CommentCell)
}

public class CommentCell: UITableViewCell {
    
    @IBOutlet public weak var avatar: UIImageView!
    @IBOutlet public weak var textContent: TTTAttributedLabel!
    @IBOutlet public weak var date: UILabel!
    
    @IBOutlet public weak var imageContent: UIImageView?
    @IBOutlet public weak var playButton: UIButton?
    
    public weak var delegate: CommentCellDelegate?
    
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
        delegate?.commentCellSelectedUserProfile(self)
    }
    
    func pressedOnImage(sender: AnyObject) {
        delegate?.commentCellSelectedImage(self)
    }
    
    @IBAction func replyPressed(sender: AnyObject) {
        delegate?.commentCellSelectedComment(self)
    }
    
}