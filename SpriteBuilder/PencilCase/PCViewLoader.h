//
//  PCViewLoader.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-05-28.
//
//

#import <Foundation/Foundation.h>

@interface PCViewLoader : NSObject

+ (id)decodeValue:(id)value ofType:(NSString *)type;
+ (id)encodeValue:(id)value asType:(NSString *)type;

@end
