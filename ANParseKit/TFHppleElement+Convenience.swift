//
//  TFHppleElement+Convenience.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/12/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation

extension TFHppleElement {
    public func linkContent() -> String {
        return objectForKey("href")
    }
    
    public func nthChildLinkContent(nth: Int) -> String? {
        return nthChild(nth)?.linkContent()
    }
    
    public func nthChildTextContent(nth: Int) -> String? {
        return nthChild(nth)?.content
    }
    
    public func childrenContentByRemovingHtml() -> String {
        var allContent: String = ""
        
        for child in (children as! [TFHppleElement]) {
            if child.isTextNode() {
                formatContentForTextNode(child)
                allContent += child.content
            }
        }
        return allContent
    }
    
    public func childrenByRemovingUnnecesaryNodes() -> [TFHppleElement] {
        var allChildren: [TFHppleElement] = []
        
        for element in (children as! [TFHppleElement]) {
            if element.tagName != "br" {
                if element.isTextNode() {
                    formatContentForTextNode(element)
                    if count(element.updatedContent) > 0 {
                        allChildren.append(element)
                    }
                } else {
                    allChildren.append(element)
                }
            }
        }
        return allChildren
    }
    
    public func nthChild(nth: Int) -> TFHppleElement? {
        if children.count >= nth {
            return children[nth-1] as? TFHppleElement
        } else {
            println("Index out of bounds for nthChild, returning nil")
            return nil;
        }
    }
    
    
    func formatContentForTextNode(textNode: TFHppleElement) {
        textNode.updatedContent = textNode.content
            .stringByReplacingOccurrencesOfString("\n", withString: "")
            .stringByReplacingOccurrencesOfString("  ", withString: "")
            .stringByReplacingOccurrencesOfString("\t", withString: "")
    }
}
