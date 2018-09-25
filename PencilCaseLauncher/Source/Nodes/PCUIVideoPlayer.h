//
//  PCUIVideoPlayer.h
//  Pods
//
//  Created by Cody Rayment on 2015-04-15.
//
//

#import <SpriteKit/SpriteKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "PCOverlayNode.h"
#import "PCVideoPlayerNode.h"

@interface PCUIVideoPlayer : SKSpriteNode <PCVideoPlayerNode, PCOverlayNode>

- (void)teardownVideo;
- (void)loadVideo;

@end
