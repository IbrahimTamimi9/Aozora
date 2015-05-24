//
//  NSArray+TFHppleElement.h
//  MALScrapping
//
//  Created by Paul Chavarria Podoliako on 4/28/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFHpple.h"

@interface NSArray (TFHppleElement)
- (TFHppleElement *)nthHpple:(int)nth;
- (NSString *)nthHppleTextContent:(int)nth;
- (NSString *)nthHppleTagContent:(int)nth;
@end
