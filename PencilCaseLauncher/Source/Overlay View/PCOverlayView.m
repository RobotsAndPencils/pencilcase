//
//  PCOverlayView.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-06-29.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCOverlayView.h"
#import "PCAppViewController.h"

// Categories
#import "SKNode+GeneralHelpers.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+CoordinateConversion.h"
#import "PCTextView.h"
#import "SKNode+LifeCycle.h"
#import "PCApp.h"
#import "PCSKView.h"
#import "PCScene.h"

@interface PCOverlayView ()

@property (strong, nonatomic) NSMutableArray *trackingNodes;

@end

@implementation PCOverlayView

+ (PCOverlayView *)overlayView {
    __weak static PCOverlayView *weakOverlayView = nil;
    if (!weakOverlayView.superview) weakOverlayView = nil;
    if (!weakOverlayView) {
        // Overlay View
        PCOverlayView *overlayView = [[self alloc] initWithFrame:[self spriteKitView].bounds];
        [[self spriteKitView] addSubview:overlayView];
        overlayView.underlayView = [[UIView alloc] initWithFrame:overlayView.bounds];
        [[self spriteKitView].superview insertSubview:overlayView.underlayView atIndex:0];

        weakOverlayView = overlayView;
    }
    return weakOverlayView;
}

- (instancetype)initWithFrame:(CGRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        self.trackingNodes = [NSMutableArray array];

        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

#pragma mark - Public

- (void)addTrackingNode:(SKNode<PCOverlayNode> *)node {
    SKNode<PCOverlayNode> *trackingParent = [self nearestParentTrackingNodeForNode:node];
    UIView *insertionView = trackingParent ? [self childrenContainerViewForNode:trackingParent] : self;
    [insertionView addSubview:[node trackingView]];
    [self updateView:[node trackingView] fromNode:node];
    [self.trackingNodes addObject:node];
}

- (void)removeTrackingNode:(SKNode<PCOverlayNode> *)node {
    [[node trackingView] removeFromSuperview];
    [self.trackingNodes removeObject:node];
}

- (CGRect)convertRect:(CGRect)rect toSpriteKitViewForNode:(SKNode *)node willAdjustAnchorPointOfView:(BOOL)willAdjustAnchorPoint {
    rect.origin = [node.parent pc_convertToWorldSpace:rect.origin];
    rect.size = [self convertSize:rect.size toWorldSpaceContentSizeFromNode:node];
    rect = [self convertWorldRectToDirectorView:rect];
    if (!willAdjustAnchorPoint) {
        rect.origin.y -= rect.size.height;
    }

    return rect;
}

- (CGSize)convertSize:(CGSize)size toWorldSpaceContentSizeFromNode:(SKNode *)node {
    CGSize contentSize = size;
    SKNode *current = node;
    while (current) {
        contentSize = CGSizeMake(contentSize.width * current.scaleX, contentSize.height * current.scaleY);
        current = current.parent;
    }
    return contentSize;
}

- (CGRect)convertRect:(CGRect)rect toOverlayViewFromNode:(SKNode *)node willAdjustAnchorPointOfView:(BOOL)willAdjustAnchorPoint {
    CGRect viewRect = [self convertRect:rect toSpriteKitViewForNode:node willAdjustAnchorPointOfView:willAdjustAnchorPoint];
    viewRect = [self convertRectToOverlayFromDirectorView:viewRect];
    return CGRectIntegral(viewRect);
}

+ (BOOL)rect:(CGRect)rectA isEqualToRect:(CGRect)rectB withTolerance:(NSInteger)tolerance {
    return [self point:rectA.origin isEqualToPoint:rectB.origin withTolerance:tolerance]
    && [self size:rectA.size isEqualToSize:rectB.size withTolerance:tolerance];
}

+ (BOOL)size:(CGSize)sizeA isEqualToSize:(CGSize)sizeB withTolerance:(NSInteger)tolerance {
    if (ABS(sizeA.width - sizeB.width) > tolerance
        || ABS(sizeA.height - sizeB.height) > tolerance) {
        return NO;
    }
    return YES;
}

+ (BOOL)point:(CGPoint)pointA isEqualToPoint:(CGPoint)pointB withTolerance:(NSInteger)tolerance {
    if (ABS(pointA.x - pointB.x) > tolerance
        || ABS(pointA.y - pointB.y) > tolerance) {
        return NO;
    }
    return YES;
}

/**
 *   When a popover is provided with a node to originate from, we can make no assumptions about the fitness of the node for this purpose. The node could be the size of the full screen (or larger), in which case a popover that tries to appear outside the rect would not work as it would appear offscreen. Likewise, the node could be very large and the center of its edges may be off screen. The node may even be entirely off screen. In these cases, the popover would also be unable to find a suitable place to position itself. This method seeks to resolve these situations in the following ways:
 *
 *   1. It only cares about the portion of the node that is actually visible on the screen
 *   2. If the node is too large, the rectangle is shifted down, essentially inverting the behaviour so that the popover appears on the top of the node in question.
     3. If the node is completely off screen, we just use the bottom of the screen
 */
- (CGRect)rectForPopoverOriginatingFromNode:(SKNode *)node {
    if (!node) return self.bounds;
    
    CGRect originRect = [self convertRect:node.frame toOverlayViewFromNode:node.parent willAdjustAnchorPointOfView:NO];
    originRect = CGRectIntersection(originRect, self.frame);
    if (CGRectIsNull(originRect)) {
        return CGRectMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame), 0, 0);
    }
    CGFloat percentOfScreenCovered = ((originRect.size.width * originRect.size.height) / (self.frame.size.width * self.frame.size.height));
    if (percentOfScreenCovered > 0.9f) {
        originRect.origin.y = CGRectGetMaxY(originRect);
    }
    return originRect;
}

#pragma mark - Private

+ (PCSKView *)spriteKitView {
    return [PCAppViewController lastCreatedInstance].spriteKitView;
}

#pragma mark Conversion Helpers

- (CGRect)convertWorldRectToDirectorView:(CGRect)rect {
    PCSKView *spriteKitView = [PCOverlayView spriteKitView];
    if (!spriteKitView || !spriteKitView.pc_scene) return CGRectZero;

    CGPoint origin = [spriteKitView convertPoint:rect.origin fromScene:spriteKitView.pc_scene];
    CGSize size = [self convertWorldSizeToDirectorView:rect.size];
    return (CGRect){ origin, size };
}


// NOTE: Here we are doing the conversion manually, the function:[[PCOverlayView spriteKitView] convertPoint:point fromScene:[PCOverlayView spriteKitView].scene];
// that was previously being used does not return the correct yValue(height).
- (CGSize)convertWorldSizeToDirectorView:(CGSize)size {
    CGFloat sizeX = [PCOverlayView spriteKitView].frame.size.width / [PCOverlayView spriteKitView].scene.size.width * size.width;
    CGFloat sizeY = [PCOverlayView spriteKitView].frame.size.height / [PCOverlayView spriteKitView].scene.size.height * size.height;
    return CGSizeMake(sizeX, sizeY);
}

- (CGRect)convertRectToOverlayFromDirectorView:(CGRect)frame {
    return [self convertRect:frame fromView:[PCOverlayView spriteKitView]];
}

#pragma mark Update Helpers

- (void)updateTrackingNodePositions {
    self.frame = [PCOverlayView spriteKitView].bounds;
    //SpriteKit is set up so that y of 0 is at the bottom and increasing the y value goes up, UIKit set up so that y of 0 is at the top and increasing the y value goes down. This reverses the coordinate system of this node to match SpriteKit.
    //Note: This also has the side effect of making all views render upside down. This is handled in the views transform. See `updateView` for more information.
    self.transform = CGAffineTransformMakeScale(1, -1);
    self.underlayView.frame = self.frame;
    [self.trackingNodes enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(SKNode<PCOverlayNode> *node, NSUInteger idx, BOOL *stop) {
        [self updateView:[node trackingView] fromNode:node];
    }];
}

- (BOOL)updateView:(UIView *)view fromNode:(SKNode *)node {
    if (![PCOverlayView spriteKitView].scene) return NO;
    if (!node.pc_scene) return NO;
    
    [view setHidden:node.hidden || node.anyParentNotVisible];
    if (view.isHidden) return NO;
    
    view.alpha = node.alpha;

    CGAffineTransform transform;
    SKNode *parent = [self nearestParentTrackingNodeForNode:node];
    if (parent) {
        CGPoint anchorPoint = CGPointMake(parent.xScale >= 0 ? parent.anchorPoint.x : 1 - parent.anchorPoint.x,
                                          parent.yScale >= 0 ? 1 - parent.anchorPoint.y : parent.anchorPoint.y);
        transform = CGAffineTransformMakeTranslation(parent.contentSize.width * anchorPoint.x, parent.contentSize.height * anchorPoint.y);
        transform = CGAffineTransformConcat([node pc_nodeToFirstTrackingParentTransform], transform);
    } else {
        transform = [node pc_nodeToWorldTransform];
        transform = CGAffineTransformConcat(transform, [PCOverlayView aspectRatioScaleTransform]);
        //To handle the fact that SpriteKit and UIKit have inverted coordinate systems, we flip the overlay view upside down to get the same coordinate system, but we have to flip all views so that they don't render upside down. See `update` for more details.
        transform = CGAffineTransformScale(transform, 1, -1);
    }

    BOOL changed = NO;
    if (!CGSizeEqualToSize(view.layer.bounds.size, node.contentSize)) {
        view.layer.bounds = CGRectMake(0, 0, node.contentSize.width, node.contentSize.height);
        changed = YES;
    }
    if (!CGAffineTransformEqualToTransform(transform, view.layer.affineTransform)) {
        view.layer.affineTransform = transform;
        changed = YES;
    }
    CGPoint desiredAnchorPoint = CGPointMake(node.anchorPoint.x, 1 - node.anchorPoint.y);
    if (!CGPointEqualToPoint(desiredAnchorPoint, view.layer.anchorPoint)) {
        view.layer.anchorPoint = desiredAnchorPoint;
        changed = YES;
    }
    if (changed) {
        [view setNeedsDisplay];
    }
    if ([node conformsToProtocol:@protocol(PCOverlayNode)] && [node respondsToSelector:@selector(viewUpdated:)]) {
        SKNode<PCOverlayNode> *overlayNode = (SKNode<PCOverlayNode> *)node;
        [overlayNode viewUpdated:changed];
    }
    
    return changed;
}

+ (CGAffineTransform)aspectRatioScaleTransform {
    CGSize originalSize = [PCOverlayView spriteKitView].scene.size;
    CGSize newSize = [PCOverlayView spriteKitView].frame.size;
    CGFloat scale = MIN(newSize.width / originalSize.width, newSize.height / originalSize.height);
    return CGAffineTransformMakeScale(scale, scale);
}

#pragma mark PCOverlayNode Protocol Helpers

- (SKNode<PCOverlayNode> *)nearestParentTrackingNodeForNode:(SKNode *)node {
    SKNode *parent = node.parent;
    while (parent) {
        if ([parent conformsToProtocol:@protocol(PCOverlayNode)]) {
            return (SKNode<PCOverlayNode> *)parent;
        }
        parent = parent.parent;
    }
    return nil;
}

- (UIView *)childrenContainerViewForNode:(SKNode<PCOverlayNode> *)node {
    UIView *view = [node trackingView];
    if ([node respondsToSelector:@selector(childrenContainerView)]) {
        view = [node childrenContainerView];
    }
    return view;
}

- (void)sceneTransitionWillStart {
    self.hidden = YES;
}

- (void)sceneTransitionCompleted {
    self.hidden = NO;
}

@end
