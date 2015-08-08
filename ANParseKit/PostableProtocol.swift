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
    var replyLevel: Int { get set }
    
    var replies: [PFObject]? { get }
    var images: [String]? { get }
}

public protocol TimelinePostable: Postable {
    var userTimeline: User { get set }
}

public protocol ThreadPostable: Postable {
    
}