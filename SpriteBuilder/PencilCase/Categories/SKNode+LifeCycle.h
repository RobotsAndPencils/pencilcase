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

+ (void)pc_setupLifecycleCallbacks;

/**
 *  This is called elsewhere when the node is going to be added to the stage for
 *  the first time, and so it doesn't need to be swizzled into any existing
 *  lifecycle methods.
 */
- (void)pc_firstTimeSetup;
- (void)pc_didLoad;
- (void)pc_didMoveToParent NS_REQUIRES_SUPER;
- (void)pc_willMoveToParent:(SKNode *)newParent NS_REQUIRES_SUPER;
- (void)pc_didEnterScene NS_REQUIRES_SUPER;
- (void)pc_willExitScene NS_REQUIRES_SUPER;

@end
