//
//  AniListClient.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 4/29/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Alamofire

struct TraktV1 {
    
    enum Router: URLRequestConvertible {
        static let TraktAPIKey = "3d00b19f07b707f960e58fd9fa81caf2"
        static let BaseURLString = "http://api.trakt.tv"
        
        case showSummaryForID(tvdbID: Int)
        
        var URLRequest: NSURLRequest {
            let (method: Alamofire.Method, path: String, parameters: [String: AnyObject]) = {
                switch self {
                case .showSummaryForID(let tvdbID):
                    return (.GET, "show/summary.json/\(Router.TraktAPIKey)/\(tvdbID)", [:])
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