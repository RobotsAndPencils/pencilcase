//
//  PCOverlayView.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 1/31/2014.
//  Copyright (c) 2012 Robots and Pencils Inc. All rights reserved.
//

#import "PCView.h"
#import "PCOverlayNode.h"
#import "PCPhysicsHandleOverlayView.h"
#import "PCNodeHandlesOverlayView.h"

@class SKNode;

/**
 Allows you to use NSViews that are overlayed on top of the stage. You can set up a view to track a node by adopting the PCOverlayNode protocol. When you adopt this protocol views are added in a hierarchy. So if a parent node has a tracking view your nodes tracking view will be added to it. This is mainly to support clipping.
 
You can also directly add views and manually manager their frames with an update block. These manual views will be added directly to the overlay view without any hierarchy management.
 */
@interface PCOverlayView : PCView

@property (strong, nonatomic, readonly) PCView *contentView;

@property (strong, nonatomic) NSScrollView *scrollView;

@property (strong, nonatomic) PCPhysicsHandleOverlayView *physicsHandlesView;
@property (strong, nonatomic) PCNodeHandlesOverlayView *nodeHandlesView;

+ (PCOverlayView *)overlayView;

- (void)addTrackingNode:(SKNode<PCOverlayNode> *)node;
- (void)removeTrackingNode:(SKNode<PCOverlayNode> *)node;
- (void)updateTrackingViewsFromZOrder;

- (void)enableInteractionInUIKitWindow;
- (void)disableInteractionInUIKitWindow;

// Helpers
- (void)updateTrackingNodePositions;
- (CGRect)directorViewFrameForNode:(SKNode *)node withNesting:(BOOL)nesting;
- (CGRect)convertRect:(NSRect)aRect toDirectorViewFromNode:(SKNode *)node withNesting:(BOOL)nesting;
- (CGRect)convertRect:(NSRect)aRect toOverlayContentViewFromNode:(SKNode *)node withNesting:(BOOL)nesting;
+ (BOOL)rect:(CGRect)rectA isEqualToRect:(CGRect)rectB withTolerance:(NSInteger)tolerance;

/* Manual view management - Does not support hierarchy / clipping.
 * The view will be added directly to `contentView`.
 * This is handy for views that need user interaction like instant alpha overlay.
 */
- (void)addContentView:(NSView<PCOverlayTrackingView> *)view withUpdateBlock:(dispatch_block_t)updateBlock;
- (void)updateView:(NSView<PCOverlayTrackingView> *)view fromNode:(SKNode *)node;

/**
 * Use to temporarily opt out of tracking features.
 * The NSTextView does this during editing to remove layer transforms so that the cursor can behave correctly.
 */
- (void)disableNestingForTrackingNode:(SKNode<PCOverlayNode> *)node;
- (void)enableNestingForTrackingNode:(SKNode<PCOverlayNode> *)node;

@end
