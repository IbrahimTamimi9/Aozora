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
    
    @NSManaged public var alternativeVersions: [[String:String]]
    @NSManaged public var mangaAdaptations: [[String:String]]
    @NSManaged public var prequels: [[String:String]]
    @NSManaged public var sequels: [[String:String]]
    @NSManaged public var sideStories: [[String:String]]
    @NSManaged public var spinOffs: [[String:String]]
    
    public var totalRelations: Int {
        get {
            if self.isDataAvailable() {
                return alternativeVersions.count + prequels.count + sequels.count + sideStories.count + spinOffs.count
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
        
        static func relationWithData(data: [String:String], relationType: RelationType) -> Relation{
            return Relation(
                animeID: data["anime_id"]!.toInt()!,
                title: data["title"]!,
                url: data["url"]!,
                relationType:relationType)
        }
    }
    
    // TODO: Improve this to don't iterate through all relations..
    public func relationAtIndex(index: Int) -> Relation {
        var allRelations: [Relation] = []
        
        for relation in alternativeVersions {
            var newRelation = Relation.relationWithData(relation, relationType: .AlternativeVersion)
            allRelations.append(newRelation)
        }
        for relation in prequels {
            var newRelation = Relation.relationWithData(relation, relationType: .Prequel)
            allRelations.append(newRelation)
        }
        for relation in sequels {
            var newRelation = Relation.relationWithData(relation, relationType: .Sequel)
            allRelations.append(newRelation)
        }
        for relation in sideStories {
            var newRelation = Relation.relationWithData(relation, relationType: .SideStory)
            allRelations.append(newRelation)
        }
        for relation in spinOffs {
            var newRelation = Relation.relationWithData(relation, relationType: .SpinOff)
            allRelations.append(newRelation)
        }
        
        return allRelations[index]
    }
    
    
}
