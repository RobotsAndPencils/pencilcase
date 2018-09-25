//
//  PCSKTableNode.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-21.
//
//

#import <SpriteKit/SpriteKit.h>

@interface PCSKTableNode : SKSpriteNode

@property (strong, nonatomic) NSArray *cells;
@property (assign, nonatomic) BOOL enableRefreshControl;

@end
