//
//  UserList.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 1/9/16.
//  Copyright © 2016 AnyTap. All rights reserved.
//

import Foundation
import Parse

public class UserList: PFObject, PFSubclassing, Postable {
    override public class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    public class func parseClassName() -> String {
        return "UserList"
    }
    
    @NSManaged public var title: String
    @NSManaged public var about: String
    @NSManaged public var anime: [Anime]
    
    public var imagesDataInternal: [ImageData]?
    public var linkDataInternal: LinkData?
}