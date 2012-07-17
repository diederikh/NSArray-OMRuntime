//
//  NSArray+OMRuntime.h
//  CasinoGridManager
//
//  Created by Diederik Hoogenboom on 17-07-12.
//  Copyright (c) 2012 Gaming Support. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (OMRuntime)
#if __IPHONE_OS_VERSION_MIN_REQUIRED <= __IPHONE_5_1
- (id)objectAtIndexedSubscript:(NSUInteger)index;
#endif
@end

@interface NSMutableArray (OMRuntime)
#if __IPHONE_OS_VERSION_MIN_REQUIRED <= __IPHONE_5_1
- (void)setObject:(id)object AtIndexedSubscript:(NSUInteger)index;
#endif
@end
