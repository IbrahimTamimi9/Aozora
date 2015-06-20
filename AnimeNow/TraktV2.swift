//
//  AniListClient.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 4/29/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Alamofire

public struct TraktV2 {
    
    public var accessToken: String
    
    public enum Router: URLRequestConvertible {
        static let ClientID = "12f8cae902e79db4344c261df078e2b2ea3bea57ca86240bf0d506e1ae514c2b"
        static let ClientSecret = "c4847ea39d465aaede74c8253418855f3ea96f4488705a84a1f85aa45a3672cf"
        static let BaseURLString = "https://api-v2launch.trakt.tv"
        
        case requestAccessToken()
        case showSummaryForSlug(slug: String)
        case showSummaryForId(id: Int)
        case searchShowForTitle(title: String, year: Int)
        
        public var URLRequest: NSURLRequest {
            let (method: Alamofire.Method, path: String, parameters: [String: AnyObject]) = {
                let accessToken = NSUserDefaults.standardUserDefaults().stringForKey("access_token") ?? ""
                switch self {
                case .requestAccessToken:
                    let params = ["grant_type": "client_credentials", "client_id": Router.ClientID, "client_secret": Router.ClientSecret]
                    return (.POST, "/auth/access_token", params)
                case .showSummaryForSlug(let slug):
                    return (.GET, "/shows/\(slug)", ["extended":"full"])
                case .showSummaryForId(let id):
                    return (.GET, "/shows/\(id)", ["extended":"full"])
                case .searchShowForTitle(let title, let year):
                    let params = ["query":title,"type":"show","year":year]
                    return (.GET, "/search", params as! [String : AnyObject])
                }
            }()
            
            let URL = NSURL(string: Router.BaseURLString)
            let URLRequest = NSMutableURLRequest(URL: URL!.URLByAppendingPathComponent(path))
            URLRequest.setValue("2", forHTTPHeaderField: "trakt-api-version")
            URLRequest.setValue(Router.ClientID, forHTTPHeaderField: "trakt-api-key")
            URLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            URLRequest.HTTPMethod = method.rawValue
            let encoding = Alamofire.ParameterEncoding.URL
            
            return encoding.encode(URLRequest, parameters: parameters).0
        }
    }
    

}