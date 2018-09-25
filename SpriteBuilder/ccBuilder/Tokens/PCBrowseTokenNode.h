//
//  PCToken.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-09-18.
//
//

#import <SpriteKit/SpriteKit.h>
#import "PCTokenBrowsable.h"

@interface PCBrowseTokenNode : NSObject <PCTokenBrowsable>

@property (strong, nonatomic, readonly) SKNode *node;

+ (instancetype)tokenWithNode:(SKNode *)node;

+ (NSArray *)tokensForObjectsOnCurrentCard;

@end
