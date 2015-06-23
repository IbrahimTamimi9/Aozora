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
    
    public var accessToken: String
    
    public enum Router: URLRequestConvertible {
        static let BaseURLString = "https://api.atarashiiapp.com/2"
        
        case animeCast(id: Int)
        case verifyCredentials()
        case animeList(username: String)
        case profile(username: String)
        case friends(username: String)
        case history(username: String)
        
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