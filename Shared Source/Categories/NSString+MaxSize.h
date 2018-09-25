//
//  NSString+MaxSize.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-06-16.
//
//

#import <Foundation/Foundation.h>

@interface NSString (MaxSize)

/**
 Breaks a string into chunks no greater than a specific size when rendered
 @param width The maximum width that each chunk can be
 @param textAttributes the attributes to apply to the strings when calculating the size
 */
- (NSArray *)pc_splitIntoChunksWithMaxWidth:(NSInteger)width attributes:(NSDictionary *)textAttributes;

@end
