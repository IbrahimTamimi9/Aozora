//
//  TFHppleElement+MALScrapping.h
//  MALScrapping
//
//  Created by Paul Chavarria Podoliako on 4/27/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

#import "TFHppleElement.h"

@interface TFHppleElement (MALScrapping)

- (NSString *)linkContent;

- (NSString *)nthChildLinkContent:(int)nth;
- (NSString *)nthChildTextContent:(int)nth;
- (NSString *)childrenContentByRemovingHtml;

- (NSArray *)childrenByRemovingUnnecesaryNodes;

- (TFHppleElement *)nthChild:(int)nth;
@end
