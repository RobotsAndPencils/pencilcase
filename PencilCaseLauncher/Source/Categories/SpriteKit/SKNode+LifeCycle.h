//
//  SKNode+LifeCycle.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-10.
//
//

#import <SpriteKit/SpriteKit.h>

// Some help from: https://github.com/KoboldKit/KoboldKit/blob/master/KoboldKit/KoboldKitFree/Framework/Nodes/Framework/KKNodeShared.h
@interface SKNode (LifeCycle)

@property (weak, nonatomic, readonly) SKScene *pc_scene;
/// When the node was added to it's parent
@property (strong, nonatomic) NSDate *addedAt;

- (void)pc_didMoveToParent NS_REQUIRES_SUPER;
- (void)pc_willMoveToParent:(SKNode *)newParent NS_REQUIRES_SUPER;
- (void)pc_didEnterScene NS_REQUIRES_SUPER;
- (void)pc_willExitScene NS_REQUIRES_SUPER;
- (void)pc_presentationDidStart NS_REQUIRES_SUPER;
- (void)pc_presentationCompleted NS_REQUIRES_SUPER;
- (void)pc_dismissTransitionWillStart NS_REQUIRES_SUPER;

@end
