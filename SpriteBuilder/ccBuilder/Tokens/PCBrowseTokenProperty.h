//
//  PCBrowseTokenProperty.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-09-19.
//
//

#import <Foundation/Foundation.h>
#import "PCTokenBrowsable.h"

@interface PCBrowseTokenProperty : NSObject <PCTokenBrowsable>

// propertyInfo can lead to multiple tokens sometimes.
// Other times it will lead to one token with 2 children.
// [ scaleX, scaleY ] vs position -> [x, y]
+ (NSArray *)propertyTokensFromPropertyInfo:(NSDictionary *)propertyInfo;

@end
