//
//  PCDictionaryKeyValueStore.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-08-14.
//
//

#import <Foundation/Foundation.h>

@protocol PCDictionaryKeyValueStore

/**
 Sets a value for the key on the internal objects while properly managing the value in the dictionary.
 Used in the case that an object has a special setter that differs from its accessor, but we want the dict
 to remain valid so we don't overwrite values. An example of where this was happening was anchorPoints, which
 has an x and a y, and a custom setter. After setting one value, if you changed the other, the first would
 be reverted because the dictionary wouldn't update properly.
 @param value The value to set
 @param key The key of the value in the object
 @param dictionaryKey The key to store in our internal dictionary
 */
- (void)setValue:(id)value forKey:(NSString *)key dictionaryKey:(NSString *)dictionaryKey;

@end