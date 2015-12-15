//
//  LinkScrapper.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 12/14/15.
//  Copyright © 2015 AnyTap. All rights reserved.
//

import Foundation
import Bolts

public class LinkData {
    
    public var url: String?
    public var type: String?
    public var title: String?
    public var description: String?
    public var imageUrls: [String] = []
    public var updatedTime: String?
    public var siteName: String?
    
    class func mapDataWithDictionary(dictionary: [String: AnyObject]) -> LinkData {
        let linkData = LinkData()
        
        if let url = dictionary["url"] as? String {
            linkData.url = url
        }
        if let type = dictionary["type"] as? String {
            linkData.type = type
        }
        if let url = dictionary["title"] as? String {
            linkData.title = url
        }
        if let description = dictionary["description"] as? String {
            linkData.description = description
        }
        if let imageUrls = dictionary["imageUrls"] as? [String] {
            linkData.imageUrls = imageUrls
        }
        if let updatedTime = dictionary["updatedTime"] as? String {
            linkData.updatedTime = updatedTime
        }
        if let siteName = dictionary["siteName"] as? String {
            linkData.siteName = siteName
        }
        return linkData
    }
    
    public func toDictionary() -> [String: AnyObject] {
        return [
            "url": url ?? "",
            "type": type ?? "",
            "title": title ?? "",
            "description": description ?? "",
            "imageUrls": imageUrls,
            "updatedTime": updatedTime ?? "",
            "siteName": siteName ?? ""
        ]
    }
}

public class LinkScrapper {
    
    var viewController: UIViewController
    
    public init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    public func findInformationForLink(stringUrl: String) -> BFTask {

        guard let encodedRequest = stringUrl.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet()), let urlRequest = NSURL(string: encodedRequest) else {
            return BFTask(result: nil)
        }
        let completion = BFTaskCompletionSource()
        
        viewController.webScraper.scrape(urlRequest.absoluteString) { (hpple) -> Void in
            if hpple == nil {
                print("hpple is nil")
                completion.setError(NSError(domain: "aozora.findInformationForLink", code: 0, userInfo: nil))
                return
            }
            
            let results = hpple.searchWithXPathQuery("//meta") as! [TFHppleElement]
            let data = LinkData()
            
            for result in results {
                if let name = result.objectForKey("name") {
                    switch name {
                    case "title":
                        data.title = result.objectForKey("content")
                    case "description":
                        data.description = result.objectForKey("content")
                    default:
                        continue
                    }
                }
                
                guard let property = result.objectForKey("property") else {
                    continue
                }
                
                switch property {
                case "og:title":
                    data.title = result.objectForKey("content")
                case "og:url":
                    data.url = result.objectForKey("content")
                case "og:description":
                    data.description = result.objectForKey("content")
                case "og:image":
                    data.imageUrls.append(result.objectForKey("content"))
                case "og:site_name":
                    data.siteName = result.objectForKey("content")
                case "og:updated_time":
                    data.updatedTime = result.objectForKey("content")
                case "og:type":
                    data.type = result.objectForKey("content")
                default:
                    continue
                }
            }
            
            completion.setResult(data)
        }
        
        return completion.task
    }
}