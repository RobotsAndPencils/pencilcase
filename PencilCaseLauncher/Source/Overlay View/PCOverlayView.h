//
//  PCOverlayView.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-06-29.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCOverlayNode.h"

@interface PCOverlayView : UIView

@property (assign, nonatomic) CGPoint scaleFactor;

/**
 The underlayView is necessary currently only for the scrollview. The pinch to zoom doesn't calculate correctly unless the scrollview is in the correct position. But since we don't want it to take any touches we hide it behind the SKView.
 */
@property (strong, nonatomic) UIView *underlayView;

+ (PCOverlayView *)overlayView;

- (void)addTrackingNode:(SKNode<PCOverlayNode> *)node;
- (void)removeTrackingNode:(SKNode<PCOverlayNode> *)node;

// Helpers
- (CGRect)overlayContentFrameForNode:(SKNode *)node;
- (CGRect)convertRect:(CGRect)rect toOverlayViewFromNode:(SKNode *)node willAdjustAnchorPointOfView:(BOOL)willAdjustAnchorPoint;
+ (BOOL)rect:(CGRect)rectA isEqualToRect:(CGRect)rectB withTolerance:(NSInteger)tolerance;
+ (BOOL)size:(CGSize)sizeA isEqualToSize:(CGSize)sizeB withTolerance:(NSInteger)tolerance;
+ (BOOL)point:(CGPoint)pointA isEqualToPoint:(CGPoint)pointB withTolerance:(NSInteger)tolerance;
+ (SKView *)spriteKitView;

- (void)sceneTransitionWillStart;
- (void)sceneTransitionCompleted;

- (void)updateTrackingNodePositions;

/**
 Determines the rect that a popover should appear from given a node
 @param node The node to figure out the rect for
 */
- (CGRect)rectForPopoverOriginatingFromNode:(SKNode *)node;

@end
