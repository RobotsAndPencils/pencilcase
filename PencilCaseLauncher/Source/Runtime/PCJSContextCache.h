//
//  PCJSContextCache.h
//  Pods
//
//  Created by Cody Rayment on 2015-03-16.
//
//

#import <Foundation/Foundation.h>

@class PCJSContext;

@interface PCJSContextCache : NSObject

+ (instancetype)sharedInstance;
- (void)buildCache;
- (void)clearCacheAndCancelCacheBuilding;
- (PCJSContext *)take;

@end
