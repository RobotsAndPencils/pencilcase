//
//  StringPropertySetter.h
//  SpriteBuilder
//
//  Created by Viktor on 8/9/13.
//
//

#import <Foundation/Foundation.h>

@class SKNode;

@interface StringPropertySetter : NSObject

+ (void) refreshStringProp:(NSString*)prop forNode:(SKNode *)node;

+ (void) setString:(NSString*)str forNode:(SKNode*)node andProp:(NSString*)prop;
+ (NSString*) stringForNode:(SKNode*)node andProp:(NSString*)prop;

+ (void) setLocalized:(BOOL)localized forNode:(SKNode*)node andProp:(NSString*)prop;
+ (BOOL) isLocalizedNode:(SKNode*)node andProp:(NSString*)prop;

+ (BOOL) hasTranslationForNode:(SKNode*)node andProp:(NSString*)prop;
+ (void) refreshAllStringProps;

@end
