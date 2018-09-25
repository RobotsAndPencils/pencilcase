//
//  PCSKWebViewNode.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-17.
//
//

#import <SpriteKit/SpriteKit.h>
#import "PCOverlayNode.h"

@interface PCSKWebViewNode : SKSpriteNode <PCOverlayNode>

@property (copy, nonatomic) NSString *currentURL;
@property (copy, nonatomic) NSString *homeURL;

@end
