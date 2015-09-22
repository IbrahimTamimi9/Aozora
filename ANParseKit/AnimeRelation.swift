//
//  AnimeRelation.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/11/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Parse

public class AnimeRelation: PFObject, PFSubclassing {
    override public class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    public class func parseClassName() -> String {
        return "AnimeRelation"
    }
    
    @NSManaged public var alternativeVersions: [[String:AnyObject]]
    @NSManaged public var mangaAdaptations: [[String:AnyObject]]
    @NSManaged public var prequels: [[String:AnyObject]]
    @NSManaged public var sequels: [[String:AnyObject]]
    @NSManaged public var sideStories: [[String:AnyObject]]
    @NSManaged public var spinOffs: [[String:AnyObject]]
    
    public var totalRelations: Int {
        get {
            if self.isDataAvailable() {
                return allRelationsCount()
            } else {
                return 0
            }
        }
    }
    
    public enum RelationType: String {
        case AlternativeVersion = "Alternative Version"
        case Prequel = "Prequel"
        case Sequel = "Sequel"
        case SideStory = "SideStory"
        case SpinOff = "SpinOff"
    }
    
    public struct Relation {
        public var animeID: Int
        public var title: String
        public var url: String
        public var relationType: RelationType
        
        static func relationWithData(data: [String:AnyObject], relationType: RelationType) -> Relation{
            // All this mess of types is because of Atarashii api fault..
            var animeIdentifier: Int?
            if let animeID = (data["anime_id"] ?? data["manga_id"]) as? Int {
                animeIdentifier = animeID
            }
            if let animeID = (data["anime_id"] ?? data["manga_id"]) as? String, let animeID2 = Int(animeID) {
                animeIdentifier = animeID2
            }
            return Relation(
                animeID: animeIdentifier!,
                title: data["title"] as! String,
                url: data["url"] as! String,
                relationType:relationType)
        }
    }
    
    // TODO: Improve this to don't iterate through all relations..
    
    func allRelationsCount() -> Int {
        var count = 0
        let allRelations = alternativeVersions + prequels + sequels + sideStories + spinOffs
        for relation in allRelations {
            if let url = relation["url"] as? String, let _ = url.rangeOfString("anime") {
                count += 1
            }
        }
        return count
    }
    
    public func relationAtIndex(index: Int) -> Relation {
        var allRelations: [Relation] = []
        
        for relation in alternativeVersions {
            if let url = relation["url"] as? String, let _ = url.rangeOfString("anime") {
                let newRelation = Relation.relationWithData(relation, relationType: .AlternativeVersion)
                allRelations.append(newRelation)
            }
        }
        
        for relation in prequels {
            if let url = relation["url"] as? String, let _ = url.rangeOfString("anime") {
                let newRelation = Relation.relationWithData(relation, relationType: .Prequel)
                allRelations.append(newRelation)
            }
        }
        for relation in sequels {
            if let url = relation["url"] as? String, let _ = url.rangeOfString("anime") {
                let newRelation = Relation.relationWithData(relation, relationType: .Sequel)
                allRelations.append(newRelation)
            }
        }
        for relation in sideStories {
            if let url = relation["url"] as? String, let _ = url.rangeOfString("anime") {
                let newRelation = Relation.relationWithData(relation, relationType: .SideStory)
                allRelations.append(newRelation)
            }
        }
        for relation in spinOffs {
            if let url = relation["url"] as? String, let _ = url.rangeOfString("anime") {
                let newRelation = Relation.relationWithData(relation, relationType: .SpinOff)
                allRelations.append(newRelation)
            }
        }
        
        return allRelations[index]
    }
    
    
}
