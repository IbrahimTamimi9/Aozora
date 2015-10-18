//
//  PostInterface.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 8/8/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Parse

public protocol Postable {
    
    var createdDate: NSDate? { get }
    var episode: Episode? { get }
    var youtubeID: String? { get set }
    var postedBy: User? { get set }
    var edited: Bool { get set }
    var content: String { get set }
    var nonSpoilerContent: String? { get set }
    var replyLevel: Int { get set }
    var hasSpoilers: Bool { get set }
    var isSpoilerHidden: Bool { get set }
    var subscribers: [User] { get set }
    var likedBy: [User]? { get set }
    
    var parentPost: PFObject? { get }
    var images: [ImageData] { get set }
    
    var replies: [PFObject] { get set }
    
    var showAllReplies: Bool { get set }
}

public protocol TimelinePostable: Postable {
    var userTimeline: User { get set }
}

public protocol ThreadPostable: Postable {
    var thread: Thread { get set }
}