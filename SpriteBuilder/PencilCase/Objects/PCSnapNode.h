//
//  PCSnapNode.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-06-24.
//
//

#import <SpriteKit/SpriteKit.h>
#import "PCStageScene.h"
#import "PCSnapFrame.h"
#import "SKNode+Selection.h"

/**
Contains the logic for rendering snap lines + snapping nodes to other nodes.
In future, may also contain snapping node to grid, node to stage, and node to guides.
*/
@interface PCSnapNode : SKNode

/**
If set to NO, the snap node will essentially do nothing. If set to YES, it will snap
*/
@property (assign, nonatomic) BOOL snappingToObjectsEnabled;
@property (assign, nonatomic) BOOL snappingToGuidesEnabled;
@property (assign, nonatomic) CGRect snapFrame;

- (void)mouseDraggedWithCornerId:(CCBCornerId)cornerId lockAspectRatio:(BOOL)lockAspectRatio;
- (void)removeSnapLines;

@end
