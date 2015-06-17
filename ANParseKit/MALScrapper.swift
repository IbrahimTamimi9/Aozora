//
//  MALScrapper.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 5/23/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import Bolts

public class MALScrapper {
    
    var viewController: UIViewController
    
    public init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    // Classes
    
    public class Review {
        public var avatarUrl: String
        public var date: String
        public var helpful: String
        public var rating: Int
        public var review: String
        public var username: String
        
        init(avatarUrl: String, date: String, helpful:String, rating: Int, review: String, username: String) {
            
            self.avatarUrl = avatarUrl.stringByRemovingOccurencesOfString(["background-image:url(",")","thumbs/","_thumb"])
            self.date = date.stringByRemovingOccurencesOfString(["| "])
            self.helpful = helpful
            self.rating = rating
            self.review = review
            self.username = username
            
        }
    }
    
    public class Topic {
        public var id: Int
        public var title: String
        public var fromUser: String
        public var date: String
        
        public var replies: Int
        
        public var lastPost: Post
        
        init(id: Int, title: String, fromUser: String, date: String, replies: Int, lastPost: Post) {
            self.id = id
            self.title = title
            self.fromUser = fromUser
            self.date = date
            self.replies = replies
            self.lastPost = lastPost
        }
    }
    
    public class Post {
        public var fromUser: String = ""
        public var date: String = ""
    }
    
    
    // Functions
    
    func malTitleToSlug(title: String) -> String {
        return title
            .stringByReplacingOccurencesOfString([" ","/"], withString: "_")
            .stringByRemovingOccurencesOfString(["%"])
    }
    
    public func reviewsFor(#anime: Anime) -> BFTask{
        let completion = BFTaskCompletionSource()
        
        let malSlug = malTitleToSlug(anime.title!)
        let requestURL = "http://myanimelist.net/anime/\(anime.myAnimeListID)/\(malSlug)/reviews"
        
        let encodedRequest = requestURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        
        
        viewController.webScraper.scrape(encodedRequest) { (hpple) -> Void in
            if hpple == nil {
                println("hpple is nil")
                completion.setError(NSError())
                return
            }
            
            let results = hpple.searchWithXPathQuery("//div[@class='box-unit4']") as! [TFHppleElement]
            
            var reviews: [Review] = []
            
            for result in results {
                let avatarString = result.hppleElementFor(path: [0,0,0])?.objectForKey("style")
                let username = result.hppleElementFor(path: [0,1,0,0])?.text()
                let score = result.hppleElementFor(path: [0,1,1,1])?.text()
                let review = result.hppleElementFor(path: [1,0,0,0])?.childrenContentByRemovingHtml()
                let date = result.hppleElementFor(path: [2,0])?.content
                let currentHelpful = result.hppleElementFor(path: [2,1])?.text()
                let totalHelpful = result.hppleElementFor(path: [2,2])?.content
                
                if let _ = avatarString {
                    var reviewStruct = Review(
                        avatarUrl: avatarString ?? "",
                        date: date ?? "",
                        helpful: (currentHelpful ?? "") + (totalHelpful ?? ""),
                        rating: score!.toInt() ?? 0,
                        review: review ?? "",
                        username: username ?? "")
                    reviews.append(reviewStruct)
                }
            }
            
            completion.setResult(reviews)
        }
        
        return completion.task
    }
    
    public func topicsForAnime(#anime: Anime) -> BFTask {
        let completion = BFTaskCompletionSource()
        
        let malSlug = malTitleToSlug(anime.title!)
        let requestURL = "http://myanimelist.net/forum/?animeid=\(anime.myAnimeListID)"
        
        viewController.webScraper.scrape(requestURL) { (hpple) -> Void in
            if hpple == nil {
                println("hpple is nil")
                completion.setError(NSError())
                return
            }
            
            var results = hpple.searchWithXPathQuery("//table[@id='forumTopics']/tbody/tr") as! [TFHppleElement]
            
            // Removing header
            results.removeAtIndex(0)
            
            var topics: [Topic] = []
            
            for result in results {
                
                var topicID = result.hppleElementFor(path: [1,1])?.objectForKey("href")
                let title = result.hppleElementFor(path: [1,1])?.text()
                let fromUser = result.hppleElementFor(path: [1,4,0])?.text()
                let date = result.hppleElementFor(path: [1,5])?.text()
                var replies = result.hppleElementFor(path: [2])?.text()
                let lastReplyFromUser = result.hppleElementFor(path: [3,1])?.text()
                let lastReplyDate = result.hppleElementFor(path: [3,4])?.content
                
                topicID = topicID?.stringByRemovingOccurencesOfString(["/forum/?topicid="])
                replies = replies?.stringByRemovingOccurencesOfString([","])
                
                if let _ = topicID {
                    var lastPost = Post()
                    lastPost.fromUser = lastReplyFromUser ?? ""
                    lastPost.date = lastReplyDate ?? ""
                    
                    var topic = Topic(
                        id: topicID?.toInt() ?? 0,
                        title: title ?? "",
                        fromUser: fromUser ?? "",
                        date: date ?? "",
                        replies: replies?.toInt() ?? 0,
                        lastPost: lastPost)
                    topics.append(topic)
                }
            }
            
            completion.setResult(topics)
        }
        
        return completion.task
    }
    

    
}

extension String {
    func stringByRemovingOccurencesOfString(occurences: [String]) -> String {
        var allOccurences = occurences
        var finalString = self
        
        while allOccurences.count > 0 {
            var occurence = allOccurences[0]
            finalString = finalString.stringByReplacingOccurrencesOfString(occurence, withString: "")
            allOccurences.removeAtIndex(0)
        }
        
        return finalString
    }
    
    func stringByReplacingOccurencesOfString(occurences: [String], withString: String) -> String {
        var allOccurences = occurences
        var finalString = self
        
        while allOccurences.count > 0 {
            var occurence = allOccurences[0]
            finalString = finalString.stringByReplacingOccurrencesOfString(occurence, withString: withString)
            allOccurences.removeAtIndex(0)
        }
        
        return finalString
    }
}