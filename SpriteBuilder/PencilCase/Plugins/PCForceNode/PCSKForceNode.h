//
//  PCSKForceNode.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-07-21.
//
//

#import <SpriteKit/SpriteKit.h>
#import "PCCustomPreviewNode.h"

@interface PCSKForceNode : SKSpriteNode <PCCustomPreviewNode>

@property (assign, nonatomic) BOOL enabled;
@property (assign, nonatomic) BOOL drawArrow;

@end
