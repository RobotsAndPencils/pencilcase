//
//  NSObject+DebugPrinting.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-12-18.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (DebugPrinting)

/**
 *  Recursively compare between obj and obj1 and return a formatted string of the differences between the two.
 *  @param obj    First object to compare
 *  @param obj1   Second object to compare
 */
+ (NSString *)pc_debugDifferentDescriptionBetween:(id)obj and:(id)obj1;

@end
