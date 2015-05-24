//
//  TFHppleElement+MALScrapping.m
//  MALScrapping
//
//  Created by Paul Chavarria Podoliako on 4/27/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

#import "TFHppleElement+MALScrapping.h"

@implementation TFHppleElement (MALScrapping)

- (NSString *)linkContent
{
    return [self objectForKey:@"href"];
}
- (NSString *)nthChildLinkContent:(int)nth
{
    return [[self nthChild:nth] linkContent];
}
- (NSString *)nthChildTextContent:(int)nth
{
    return [self nthChild:nth].content;
}
- (void)formatContentForTextNode:(TFHppleElement *)textNode
{
    textNode.updatedContent = [[[textNode.content stringByReplacingOccurrencesOfString:@"\n" withString:@""]
                               stringByReplacingOccurrencesOfString:@"  " withString:@""]
                              stringByReplacingOccurrencesOfString:@"\t" withString:@""];
}
- (NSString *)childrenContentByRemovingHtml
{
    NSMutableString *allContent = [NSMutableString string];
    for (TFHppleElement *element in self.children) {
        if (element.isTextNode) {
            [self formatContentForTextNode:element];
            [allContent appendString:element.content];
        }
    }
    return allContent;
}
- (NSArray *)childrenByRemovingUnnecesaryNodes
{
    NSMutableArray *children = [NSMutableArray array];
    
    for (TFHppleElement *element in self.children) {
        if (![element.tagName isEqualToString:@"br"]) {
            if (element.isTextNode) {
                [self formatContentForTextNode:element];
                if (element.updatedContent.length) {
                    [children addObject:element];
                }
            } else {
                [children addObject:element];
            }
        }
    }
    return children;
}
- (TFHppleElement *)nthChild:(int)nth
{
    if (self.children.count >= nth) {
        return self.children[nth-1];
    } else {
        NSLog(@"Index out of bounds for nthChild, returning nil");
        return nil;
    }
    
}
@end
