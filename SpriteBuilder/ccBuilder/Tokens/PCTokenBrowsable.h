//
//  PCTokenBrowsable.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-09-19.
//
//

#import <Foundation/Foundation.h>

@protocol PCTokenBrowsable <NSObject>

- (NSString *)browseDisplayName;
- (NSArray *)browseChildren; // id<PCTokenBrowsable>
- (BOOL)isSelectable;

@end
