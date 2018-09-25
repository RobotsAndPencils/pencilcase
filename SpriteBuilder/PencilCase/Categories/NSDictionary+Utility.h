//
//  NSDictionary+Utility.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-07-07.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Utility)

/**
 @returns A list of all keys that exist in a dictionary that do not exist in another dictionary
 */
- (nonnull NSSet *)keysThatDoNotExistInDictionary:(nonnull NSDictionary *)compareDictionary;

@end
