//
//  PCSKScrollContentNode.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-11.
//
//

#import <SpriteKit/SpriteKit.h>
#import "PCFrameConstrainingNode.h"
#import "PCOverlayNode.h"

@interface PCSKScrollContentNode : SKSpriteNode <PCFrameConstrainingNode, PCOverlayNode>

@property (assign, nonatomic) BOOL hideBorder;

- (void)resizeToFitInParent;

@end
