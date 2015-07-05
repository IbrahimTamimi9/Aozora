//
//  AniListClient.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 4/29/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Alamofire

public struct Atarashii {
    
    public struct Progress {
        var animeID: Int
        var status: Int
        var episodes: Int
        var score: Int
        
        public init(animeID: Int, status: MALList, episodes: Int, score: Int) {
            self.animeID = animeID
            
            switch status {
            case .Planning:
                self.status = 6
            case .Watching:
                self.status = 1
            case .Completed:
                self.status = 2
            case .Dropped:
                self.status = 4
            case .OnHold:
                self.status = 3
            }
            
            self.episodes = episodes
            self.score = score
        }
        
        func toDictionary() -> [String: Int] {
            return ["anime_id": animeID, "status": status, "episodes": episodes, "score": score]
        }
    }
    
    public var accessToken: String
    
    public enum Router: URLRequestConvertible {
        static let BaseURLString = "https://api.atarashiiapp.com/2"
        
        case animeCast(id: Int)
        case verifyCredentials()
        case animeList(username: String)
        case profile(username: String)
        case friends(username: String)
        case history(username: String)
        case animeAdd(progress: Progress)
        case animeUpdate(progress: Progress)
        case animeDelete(id: Int)
        
        public var URLRequest: NSURLRequest {
            let (method: Alamofire.Method, path: String, parameters: [String: AnyObject]) = {
                switch self {
                case .animeCast(let id):
                    return (.GET,"anime/cast/\(id)",[:])
                case .verifyCredentials():
                    return (.GET,"account/verify_credentials",[:])
                case .animeList(let username):
                    return (.GET,"animelist/\(username)",[:])
                case .profile(let username):
                    return (.GET,"profile/\(username)",[:])
                case .friends(let username):
                    return (.GET,"friends/\(username)",[:])
                case .history(let username):
                    return (.GET,"history/\(username)",[:])
                case animeAdd(let progress):
                    return (.POST,"animelist/anime", progress.toDictionary())
                case animeUpdate(let progress):
                    return (.PUT,"animelist/anime/\(progress.animeID)", progress.toDictionary())
                case animeDelete(let id):
                    return (.DELETE,"animelist/anime/\(id)",[:])
                }
            }()
            
            let URL = NSURL(string: Router.BaseURLString)
            let URLRequest = NSMutableURLRequest(URL: URL!.URLByAppendingPathComponent(path))
            URLRequest.HTTPMethod = method.rawValue
            let encoding = Alamofire.ParameterEncoding.URL
            
            return encoding.encode(URLRequest, parameters: parameters).0
        }
    }
    
}

public enum MALList: String {
    case Planning = "plan to watch"
    case Watching = "watching"
    case Completed = "completed"
    case Dropped = "dropped"
    case OnHold = "on-hold"
}