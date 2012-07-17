//
//  NSArray+OMRuntime.m
//  CasinoGridManager
//
//  Created by Diederik Hoogenboom on 17-07-12.
//  Copyright (c) 2012 Gaming Support. All rights reserved.
//

#import "NSArray+OMRuntime.h"

@implementation NSArray (OMRuntime)
#if __IPHONE_OS_VERSION_MIN_REQUIRED <= __IPHONE_5_1
- (id)objectAtIndexedSubscript:(NSUInteger)index
{
    return [self objectAtIndex:index];
}
#endif
@end

@implementation NSMutableArray (OMRuntime)
#if __IPHONE_OS_VERSION_MIN_REQUIRED <= __IPHONE_5_1
- (void)setObject:(id)object AtIndexedSubscript:(NSUInteger)index
{
    [self replaceObjectAtIndex:index withObject:object];
}
#endif
@end
