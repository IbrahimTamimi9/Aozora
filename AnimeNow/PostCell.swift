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
    func postCellSelectedToUserProfile(postCell: PostCell)
    func postCellSelectedComment(postCell: PostCell)
}

public class PostCell: UITableViewCell {
    
    @IBOutlet weak public var avatar: UIImageView!
    @IBOutlet weak public var username: UILabel?
    @IBOutlet weak public var date: UILabel!
    
    @IBOutlet weak public var toIcon: UILabel?
    @IBOutlet weak public var toUsername: UILabel?
    
    @IBOutlet weak public var imageContent: UIImageView?
    @IBOutlet weak public var imageHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak public var textContent: TTTAttributedLabel!
    
    @IBOutlet weak public var replyButton: UIButton!
    @IBOutlet weak public var playButton: UIButton?
    
    public weak var delegate: PostCellDelegate?
    
    public enum PostType {
        case Text
        case Image
        case Image2
        case Image3
        case Image4
        case Image5
        case Video
    }
    
    public class func registerNibFor(#tableView: UITableView) {

        let listNib = UINib(nibName: "PostTextCell", bundle: ANCommonKit.bundle())
        tableView.registerNib(listNib, forCellReuseIdentifier: "PostTextCell")
        let listNib2 = UINib(nibName: "PostImageCell", bundle: ANCommonKit.bundle())
        tableView.registerNib(listNib2, forCellReuseIdentifier: "PostImageCell")
        
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "pressedUserProfile:")
        gestureRecognizer.numberOfTouchesRequired = 1
        gestureRecognizer.numberOfTapsRequired = 1
        avatar.addGestureRecognizer(gestureRecognizer)
        
        if let imageContent = imageContent {
            let gestureRecognizer2 = UITapGestureRecognizer(target: self, action: "pressedOnImage:")
            gestureRecognizer2.numberOfTouchesRequired = 1
            gestureRecognizer2.numberOfTapsRequired = 1
            imageContent.addGestureRecognizer(gestureRecognizer2)
        }
        
        if let username = username {
            let gestureRecognizer3 = UITapGestureRecognizer(target: self, action: "pressedUserProfile:")
            gestureRecognizer3.numberOfTouchesRequired = 1
            gestureRecognizer3.numberOfTapsRequired = 1
            username.addGestureRecognizer(gestureRecognizer3)
        }
        
        if let toUsername = toUsername {
            let gestureRecognizer4 = UITapGestureRecognizer(target: self, action: "pressedToUserProfile:")
            gestureRecognizer4.numberOfTouchesRequired = 1
            gestureRecognizer4.numberOfTapsRequired = 1
            toUsername.addGestureRecognizer(gestureRecognizer4)
        }
    }
    
    // MARK: - IBActions
    
    func pressedUserProfile(sender: AnyObject) {
        delegate?.postCellSelectedUserProfile(self)
    }
    
    func pressedToUserProfile(sender: AnyObject) {
        delegate?.postCellSelectedToUserProfile(self)
    }
    
    func pressedOnImage(sender: AnyObject) {
        delegate?.postCellSelectedImage(self)
    }
    
    @IBAction func replyPressed(sender: AnyObject) {
        delegate?.postCellSelectedComment(self)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
        textContent.preferredMaxLayoutWidth = textContent.frame.size.width
    }
    
    
    public override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}
