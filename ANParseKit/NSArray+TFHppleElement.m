//
//  NSArray+TFHppleElement.m
//  MALScrapping
//
//  Created by Paul Chavarria Podoliako on 4/28/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

#import "NSArray+TFHppleElement.h"

@implementation NSArray (TFHppleElement)
- (TFHppleElement *)nthHpple:(int)nth
{
    if (self.count >= nth
        ) {
        return self[nth-1];
    }else{
        NSLog(@"Index out of bounds for hppleAtIndex, returning nil");
        return nil;
    }
}
- (NSString *)nthHppleTextContent:(int)nth
{
    return [self nthHpple:nth].content;
}
- (NSString *)nthHppleTagContent:(int)nth
{
    return [[self nthHpple:nth].children nthHpple:1].content;
}
@end
