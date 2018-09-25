//
//  PCOverlayView.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 1/31/2014.
//  Copyright (c) 2012 Robots and Pencils Inc. All rights reserved.
//

#import "PCOverlayView.h"
#import "PCStageScene.h"
#import "PCView.h"
#import "PCOverlayWindow.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+CoordinateConversion.h"
#import "SKNode+NodeInfo.h"
#import "CGVectorUtilities.h"
#import "AppDelegate.h"
#import "PCSKView.h"

@interface PCOverlayView ()

@property (strong, nonatomic) PCView *contentView;
@property (strong, nonatomic) PCView *trackingContentView;

@property (strong, nonatomic) NSPointerArray *updateBlocks;
@property (strong, nonatomic) NSMutableArray *trackingNodes;
@property (strong, nonatomic) NSMutableArray *nestingDisabledTrackingNodes;
@property (strong, nonatomic) NSTimer *updateTimer;

@end

@implementation PCOverlayView

static PCOverlayWindow *uiKitWindow;

+ (PCOverlayView *)overlayView {
    if (![PCStageScene scene]) return nil;
    static PCOverlayView *overlayView = nil;
    if (!overlayView) {
        NSView *sceneView = [PCStageScene scene].view;
        NSWindow *glWindow = sceneView.window;
        
        // UI Kit Window
        uiKitWindow = [[PCOverlayWindow alloc] initWithContentRect:glWindow.frame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
        [uiKitWindow setIgnoresMouseEvents:YES];
        [uiKitWindow setBackgroundColor:[NSColor clearColor]];
        [uiKitWindow setOpaque:NO];
        [glWindow addChildWindow:uiKitWindow ordered:NSWindowAbove];
        
        // UI Kit Content View
        NSView *uiKitContentView = [[NSView alloc] initWithFrame:CGRectMake(0, 0, uiKitWindow.frame.size.width, uiKitWindow.frame.size.height)];
        uiKitContentView.wantsLayer = YES;
        uiKitContentView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        [uiKitWindow setContentView:uiKitContentView];
        
        // Overlay View
        overlayView = [[self alloc] initWithFrame:[PCOverlayView trackFrame]];
        [uiKitContentView addSubview:overlayView];
    }
    return overlayView;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        self.updateBlocks = [NSPointerArray weakObjectsPointerArray];
        self.trackingNodes = [NSMutableArray array];
        self.nestingDisabledTrackingNodes = [NSMutableArray array];
        
        self.wantsLayer = YES;
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
        self.pc_userInteractionEnabled = NO;
        [[PCStageScene scene].view addSubview:self];
        
        self.scrollView = [[NSScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.maxMagnification = 100;
        self.scrollView.minMagnification = 0;
        self.scrollView.verticalScrollElasticity = NSScrollElasticityNone;
        self.scrollView.horizontalScrollElasticity = NSScrollElasticityNone;
        self.scrollView.wantsLayer = YES; // Needs a layer for rotation to work
        self.scrollView.drawsBackground = NO;
        self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        self.scrollView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
        [self addSubview:self.scrollView];
        
        self.contentView = [[PCView alloc] initWithFrame:self.bounds];
        self.contentView.wantsLayer = YES;
        self.scrollView.documentView = self.contentView;

        self.trackingContentView = [[PCView alloc] initWithFrame:self.contentView.bounds];
        self.trackingContentView.wantsLayer = YES;
        self.trackingContentView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
        [self.contentView addSubview:self.trackingContentView];

        self.physicsHandlesView = [[PCPhysicsHandleOverlayView alloc] initWithFrame:self.bounds];
        [self addSubview:self.physicsHandlesView];

        self.nodeHandlesView = [[PCNodeHandlesOverlayView alloc] initWithFrame:self.bounds];
        [self addSubview:self.nodeHandlesView];
    }
    return self;
}

#pragma mark - Public

- (void)addTrackingNode:(SKNode<PCOverlayNode> *)node {
    SKNode<PCOverlayNode> *trackingParent = [self nearestParentTrackingNodeForNode:node];
    NSView *insertionView = trackingParent ? [self childrenContainerViewForNode:trackingParent] : self.trackingContentView;
    [insertionView addSubview:[node trackingView]];
    [self.trackingNodes addObject:node];

    [self setNeedsDisplay:YES];
}

- (void)removeTrackingNode:(SKNode<PCOverlayNode> *)node {
    [[node trackingView] removeFromSuperview];
    [self.trackingNodes removeObject:node];
    [self.nestingDisabledTrackingNodes removeObject:node];
}

- (void)updateTrackingViewsFromZOrder {
    NSMutableSet *parentViews = [NSMutableSet set];
    for (SKNode<PCOverlayNode> *node in self.trackingNodes) {
        if ([node trackingView].superview) [parentViews addObject:[node trackingView].superview];
    }

    for (SKView *parentView in parentViews) {
        NSArray *siblingTrackingNodes = Underscore.arrayMap(parentView.subviews, ^id(NSView *view) {
            for (SKNode<PCOverlayNode> *node in self.trackingNodes) {
                if ([node trackingView] == view) {
                    return node;
                }
            }
            return nil;
        });

        siblingTrackingNodes = Underscore.sort(siblingTrackingNodes, ^NSComparisonResult(SKNode<PCOverlayNode> *nodeA, SKNode<PCOverlayNode> *nodeB) {
            return [@(nodeA.zPosition) compare:@(nodeB.zPosition)];
        });

        NSArray *subviews = [siblingTrackingNodes valueForKeyPath:@"trackingView"];

        // The view can have it's own subviews. Children go above.
        NSArray *untrackedSubviews = Underscore.filter(parentView.subviews, ^BOOL(NSView *view){
            return ![subviews containsObject:view];
        });

        subviews = [untrackedSubviews arrayByAddingObjectsFromArray:subviews];
        [parentView setSubviews:subviews];
    }
}

- (void)enableInteractionInUIKitWindow {
    [uiKitWindow makeKeyWindow];
    [uiKitWindow setIgnoresMouseEvents:NO];
    
    __weak typeof(self) _self = self;
    [uiKitWindow setMouseDownHandler:^{
        [_self disableInteractionInUIKitWindow];
    }];
    [self setPc_userInteractionEnabled:YES];
}

- (void)disableInteractionInUIKitWindow {
    // When publishing this will eventually be called off the main thread, but that causes problems for WebViews
    dispatch_async(dispatch_get_main_queue(), ^{
        [uiKitWindow makeFirstResponder:nil];
        [uiKitWindow.parentWindow makeKeyWindow];
        [uiKitWindow setIgnoresMouseEvents:YES];
        [self setPc_userInteractionEnabled:NO];
    });
}

- (CGRect)directorViewFrameForNode:(SKNode *)node withNesting:(BOOL)nesting {
    return [self convertRect:[self trackingRectForNode:node withNesting:nesting] toDirectorViewFromNode:node withNesting:nesting];
}

- (CGRect)convertRect:(NSRect)aRect toDirectorViewFromNode:(SKNode *)node withNesting:(BOOL)nesting {
    CGRect rect = aRect;
    rect.origin = [self convertOrigin:rect.origin toWorldSpaceFromNode:node considerParentContainers:nesting];
    rect.size = [self convertSize:rect.size toWorldSpaceContentSizeFromNode:node];
    rect = [self convertWorldRectToDirectorView:rect];
    return rect;
}

- (CGRect)convertRect:(NSRect)aRect toOverlayContentViewFromNode:(SKNode *)node withNesting:(BOOL)nesting {
    CGRect rect = [self convertRect:aRect toDirectorViewFromNode:node withNesting:nesting];
    rect = [self convertRectToOverlayFromDirectorView:rect];
    return rect;
}

- (BOOL)isView:(NSView *)view trackingViewForNode:(SKNode *)node {
    if (!view) return NO;
    if ([node conformsToProtocol:@protocol(PCOverlayNode)]) {
        SKNode<PCOverlayNode> *trackingNode = (id)node;
        return [trackingNode trackingView] == view;
    }
    return NO;
}

- (CGSize)convertSize:(CGSize)size toWorldSpaceContentSizeFromNode:(SKNode *)node {
    CGSize contentSize = size;
    SKNode *parent = node.parent;
    while (parent) {
        contentSize = CGSizeMake(contentSize.width * parent.xScale, contentSize.height * parent.yScale);
        parent = parent.parent;
    }
    return contentSize;
}


/**
 Converting points to world space but allowing parents rotation to mess us up in cases where there will be a rotated tracking view.
 
 CGFloat rotation = node.parent.zRotation;
 node.parent.zRotation = 0;
 rect.origin = [[PCStageScene scene] convertPoint:rect.origin fromNode:node.parent];
 node.parent.zRotation = rotation;

 */
- (CGPoint)convertOrigin:(CGPoint)origin toWorldSpaceFromNode:(SKNode *)node considerParentContainers:(BOOL)considerParentContainers {
    if (!considerParentContainers) {
        return [[PCStageScene scene] convertPoint:origin fromNode:node.parent];
    }
    CGPoint currentPoint = origin;
    SKNode *currentNode = node.parent;
    while (currentNode.parent) {
        if ([currentNode conformsToProtocol:@protocol(PCOverlayNode)]) {
            CGFloat rotation = currentNode.zRotation;
            currentNode.zRotation = 0;
            currentPoint = [currentNode.parent convertPoint:currentPoint fromNode:currentNode];
            currentNode.zRotation = rotation;
        }
        else {
            currentPoint = [currentNode.parent convertPoint:currentPoint fromNode:currentNode];
        }
        currentNode = currentNode.parent;
    }
    return currentPoint;
}


/**
 This calculates a frame in the coordinate space of self.contentView.
 
 We first convert up the SKNode hierarchy to the scene itself and
 then into view land and then across to the overlay window and back
 down the view hierarchy in the overlay window.
 
 Because the NSView and SKNode hierarchies are not the same (only some
 SKNode's have matching NSViews) we have to take special care when
 converting. Some of the "up" conversions take into account what the
 "down" conversions on the other side will require. This helps us
 correctly account for anchor points and rotation.
 
 This has all been arrived at by trial and error and was initially
 written for cocos 2D. It would probably be a good idea to have a
 second pair of eyes see if they can simplify this at all.
 */
- (CGRect)overlayContentFrameForNode:(SKNode *)node withNesting:(BOOL)nesting {
    CGRect viewRect = [self directorViewFrameForNode:node withNesting:nesting];
    viewRect = [self convertRectToOverlayFromDirectorView:viewRect];
    return CGRectIntegral(viewRect);
}

+ (BOOL)rect:(CGRect)rectA isEqualToRect:(CGRect)rectB withTolerance:(NSInteger)tolerance {
    if (ABS(rectA.origin.x - rectB.origin.x) > tolerance
        || ABS(rectA.origin.y - rectB.origin.y) > tolerance
        || ABS(rectA.size.width - rectB.size.width) > tolerance
        || ABS(rectA.size.height - rectB.size.height) > tolerance) {
        return NO;
    }
    return YES;
}

#pragma mark Manual View Management

- (void)addContentView:(NSView<PCOverlayTrackingView> *)view withUpdateBlock:(dispatch_block_t)updateBlock {
    [self.contentView addSubview:view];
    if (updateBlock) {
        [self.updateBlocks compact];
        [self.updateBlocks insertPointer:(__bridge void *)(updateBlock) atIndex:[[self.updateBlocks allObjects] count]];
    }
}

- (void)updateView:(NSView<PCOverlayTrackingView> *)view fromNode:(SKNode *)node {
    [self updateView:view fromNode:node withNesting:NO];
}

#pragma mark - Nesting Toggle

- (void)disableNestingForTrackingNode:(SKNode<PCOverlayNode> *)node {
    [self.nestingDisabledTrackingNodes addObject:node];
    
    NSView<PCOverlayTrackingView> *view = [node trackingView];
    [view removeFromSuperview];
    [self updateView:view fromNode:node withNesting:NO];
    [self.trackingContentView addSubview:view];
}

- (void)enableNestingForTrackingNode:(SKNode<PCOverlayNode> *)node {
    [self.nestingDisabledTrackingNodes removeObject:node];
    
    NSView<PCOverlayTrackingView> *view = [node trackingView];
    SKNode<PCOverlayNode> *trackingParent = [self nearestParentTrackingNodeForNode:node];
    NSView<PCOverlayTrackingView> *insertionView = trackingParent ? [self childrenContainerViewForNode:trackingParent] : self.trackingContentView;
    [insertionView addSubview:view];
    [self updateView:view fromNode:node withNesting:YES];
}

#pragma mark - Private

#pragma mark Conversion Helpers

- (CGRect)convertWorldRectToDirectorView:(CGRect)rect {
    CGPoint origin = [[PCStageScene scene] convertToViewSpace:rect.origin];
    CGSize size = [self convertWorldSizeToDirectorView:rect.size];
    return (CGRect){ origin, size };
}

- (CGSize)convertWorldSizeToDirectorView:(CGSize)size {
    CGPoint point = CGPointMake(size.width, size.height);
    point = [[PCStageScene scene] convertToViewSpace:point];
    return CGSizeMake(point.x, point.y);
}

#pragma mark - Private

+ (CGRect)trackFrame {
    PCStageScene *scene = [PCStageScene scene];
    CGRect frame = [scene stageUIFrame];
    return frame;
}

- (CGRect)convertRectToOverlayFromDirectorView:(CGRect)frame {
    NSView *cocosView = [[PCStageScene scene] view];
    frame = [cocosView.superview convertRect:frame toView:nil]; // Get frame in window space
    frame = [cocosView.window convertRectToScreen:frame];
    frame = [uiKitWindow convertRectFromScreen:frame];
    return [self.contentView convertRect:frame fromView:nil];
}

#pragma mark Update Helpers

- (void)updateTrackingNodePositions {
    for (dispatch_block_t block in self.updateBlocks) {
        if (block) block();
    }
    
    // Reverse order so parents get updated before children
    [self.trackingNodes enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(SKNode<PCOverlayNode> *node, NSUInteger idx, BOOL *stop) {
        BOOL nestingEnabled = ![self.nestingDisabledTrackingNodes containsObject:node];
        BOOL frameChanged = [self updateView:[node trackingView] fromNode:node withNesting:nestingEnabled];
        if ([node respondsToSelector:@selector(viewUpdated:)]) {
            [node viewUpdated:frameChanged];
        }
    }];
}

- (BOOL)updateView:(NSView<PCOverlayTrackingView> *)view fromNode:(SKNode *)node withNesting:(BOOL)nesting {
    [view setHidden:node.hidden || node.parentHidden];
    if (view.hidden) return NO;

    view.alphaValue = node.alpha;

    CGAffineTransform transform;
    CGRect newFrame = [self trackingRectForNode:node withNesting:nesting];
    CGPoint newAnchorPoint;
    if (nesting) {
        newAnchorPoint = node.anchorPoint;
        SKNode *targetAncestor = [self nearestParentTrackingNodeForNode:node] ?: [PCStageScene scene].rootNode;
        transform = [node pc_nodeToAncestorSpaceTransform:targetAncestor];
    } else {
        newAnchorPoint = CGPointZero;
        transform = CGAffineTransformIdentity;
        newFrame = [self convertRect:newFrame toOverlayContentViewFromNode:node withNesting:nesting];
    }

    BOOL changed = (!CGAffineTransformEqualToTransform(transform, view.layer.affineTransform) || !CGRectEqualToRect(newFrame, view.frame) || !CGPointEqualToPoint(view.anchorPoint, newAnchorPoint));
    if (changed) {
        view.frame = newFrame;
        view.anchorPoint = newAnchorPoint;
        view.layer.affineTransform = transform;
        [view setNeedsDisplay:YES];
    }
    if ([node conformsToProtocol:@protocol(PCOverlayNode)] && [node respondsToSelector:@selector(viewUpdated:)]) {
        SKNode<PCOverlayNode> *overlayNode = (id)node;
        if (view == overlayNode.trackingView) {
            [overlayNode viewUpdated:changed];
        }
    }
    return changed;
}

/**
 NSView doesn't account for it's layers anchorPoint in its convertRect methods. We account for this by doing the conversion one view at a time and manually accounting for the anchorpoint.
 */
- (CGRect)convertFrame:(CGRect)frame fromContentViewToSubview:(NSView *)subview {
    // Collect all parents into an array like: [subview..self.contentView.correctSubview]
    NSMutableArray *parents = [NSMutableArray array];
    NSView *currentView = subview;
    while (currentView != self.contentView && currentView.superview) {
        [parents addObject:currentView];
        currentView = currentView.superview;
    }
    
    __block CGRect currentFrame = frame;
    // Iterate over parents from highest to lowest (reversed)
    [parents enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSView *view, NSUInteger idx, BOOL *stop) {
        // Convert down to view space
        currentFrame = [view convertRect:currentFrame fromView:view.superview];
        // Convert according to our anchor point
        if ([view conformsToProtocol:@protocol(PCOverlayTrackingView)]) {
            NSView<PCOverlayTrackingView> *trackingView = (id)view;
            CGPoint origin = currentFrame.origin;
            origin.x = origin.x + trackingView.anchorPoint.x * trackingView.frame.size.width;
            origin.y = origin.y + trackingView.anchorPoint.y * trackingView.frame.size.height;
            currentFrame.origin = origin;
        }
    }];
    
    return currentFrame;
}

+ (CGAffineTransform)aspectRatioScaleTransform {
    CGSize originalSize = [PCStageScene scene].size;
    CGSize newSize = [AppDelegate appDelegate].spriteKitView.frame.size;
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

- (CGRect)trackingRectForNode:(SKNode *)node withNesting:(BOOL)nesting {
    if (nesting && [node conformsToProtocol:@protocol(PCOverlayNode)] && [node respondsToSelector:@selector(trackingFrame)]) {
        return [(SKNode<PCOverlayNode> *)node trackingFrame];
    }
    else if (nesting) {
        return (CGRect){ CGPointZero, node.contentSize };
    }
    else {
        CGPoint bottomLeftNodeSpace = CGPointMake(-node.anchorPoint.x * node.contentSize.width, -node.anchorPoint.y * node.contentSize.height);
        CGPoint bottomLeftParentSpace = [node convertPoint:bottomLeftNodeSpace toNode:node.parent];
        return (CGRect){ bottomLeftParentSpace, node.size };
    }
}

- (NSView<PCOverlayTrackingView> *)childrenContainerViewForNode:(SKNode<PCOverlayNode> *)node {
    NSView<PCOverlayTrackingView> *view = [node trackingView];
    return view;
}

#pragma mark Layout

- (void)layout {
    [super layout];
    [self.physicsHandlesView removeFromSuperview];
    [self.contentView addSubview:self.physicsHandlesView];
    [self.nodeHandlesView removeFromSuperview];
    [self.contentView addSubview:self.nodeHandlesView];
    
    // UIKit window will always track our cocos view.
    NSView *cocosView = [[PCStageScene scene] view];
    CGRect frame = [cocosView.superview convertRect:cocosView.frame toView:nil]; // Get frame in window space
    frame = [cocosView.window convertRectToScreen:frame];
    frame = CGRectIntegral(frame);
    if (![PCOverlayView rect:frame isEqualToRect:uiKitWindow.frame withTolerance:1]) {
        [uiKitWindow setFrame:frame display:NO];
    }
    
    CGRect mainFrame = [self.class trackFrame];
    if (isnan(mainFrame.origin.x) || isnan(mainFrame.origin.y) || isnan(mainFrame.size.width) || isnan(mainFrame.size.height)) return;
    mainFrame = CGRectIntegral(mainFrame);
    
    if (self.scrollView.magnification != [[PCStageScene scene] stageZoom]) {
        self.scrollView.magnification = [[PCStageScene scene] stageZoom];
    }
    
    if (![PCOverlayView rect:mainFrame isEqualToRect:self.frame withTolerance:1]) {
        self.frame = mainFrame;
        self.scrollView.frame = CGRectIntegral(self.bounds);
        CGRect unzoomedFrame = CGRectMake(mainFrame.origin.x, mainFrame.origin.y, mainFrame.size.width / self.scrollView.magnification, mainFrame.size.height / self.scrollView.magnification);
        self.contentView.frame = CGRectIntegral(unzoomedFrame);
        self.nodeHandlesView.frame = self.physicsHandlesView.frame = CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.contentView.frame.size.width, self.contentView.frame.size.height);
    }
}

@end
