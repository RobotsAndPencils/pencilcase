//
//  PCSKScrollContentNode.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-11.
//
//

#import "PCSKScrollContentNode.h"

#import "SKNode+CocosCompatibility.h"
#import "PCSKScrollViewNode.h"
#import "PCFocusRingView.h"
#import "SKNode+LifeCycle.h"

@interface PCSKScrollContentNode ()

@property (strong, nonatomic) PCFocusRingView *focusRingView;
@property (strong, nonatomic) PCView *contentView;

@end

@implementation PCSKScrollContentNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.focusRingView = [[PCFocusRingView alloc] init];
        self.focusRingView.ringColor = [NSColor lightGrayColor];
        self.focusRingView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;

        self.contentView = [[PCView alloc] init];
        self.contentView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        [self.contentView addSubview:self.focusRingView];
    }
    return self;
}

- (PCEditorResizeBehaviour)editorResizeBehaviour {
    return PCEditorResizeBehaviourContentSize;
}

- (void)removeFromParent {} // Do not allow removal

- (void)setHideBorder:(BOOL)hideBorder {
    if (hideBorder == _hideBorder) return;

    _hideBorder = hideBorder;
    self.focusRingView.hidden = hideBorder;
}

#pragma mark Life Cycle

- (void)pc_willMoveToParent:(SKNode *)newParent {
    [super pc_willMoveToParent:newParent];
    [[PCOverlayView overlayView] removeTrackingNode:self];
}

- (void)pc_didEnterScene {
    [super pc_didEnterScene];
    [[PCOverlayView overlayView] addTrackingNode:self];
}

- (void)pc_willExitScene {
    [super pc_willExitScene];
    [[PCOverlayView overlayView] removeTrackingNode:self];
}

#pragma mark - Public

- (void)resizeToFitInParent {
    CGRect frame = [self constrainFrameInPoints:self.frame];
    self.position = frame.origin;
    self.size = frame.size;
}

#pragma mark - Private

- (CGRect)minFrameInPoints {
    return CGRectMake(0, 0, [self scrollViewNode].frame.size.width, [self scrollViewNode].frame.size.height);
}

- (PCSKScrollViewNode *)scrollViewNode {
    return (PCSKScrollViewNode *)self.parent.parent;
}

#pragma mark - Properties

#pragma mark - PCFrameConstrainingNode

- (CGRect)constrainFrameInPoints:(CGRect)proposedFrame {
    if (![self scrollViewNode]) return proposedFrame;
    
    // This math was arrived at through a combination of thoughtfully drawn diagrams and good old trial and error. Naive approaches fail because we want to sometimes adjust the position and sometimes the size depending on which direction the node is being dragged. The diagram that helped me arrive at this logic is here: http://cl.ly/image/1L1b3d3k3M3M/Image%202014-07-04%20at%201.58.42%20AM.png
    CGRect minFrame = [self minFrameInPoints];
    CGRect newFrame = CGRectUnion(minFrame, proposedFrame);
    
    // Length of blue arrows
    CGFloat xOffset = (minFrame.origin.x + minFrame.size.width) - (proposedFrame.origin.x + proposedFrame.size.width);
    CGFloat yOffset = (minFrame.origin.y + minFrame.size.height) - (proposedFrame.origin.y + proposedFrame.size.height);
    
    // We only adjust by blue arrows if they have position length
    // AND the node is being moved down/left
    if (xOffset > 0 && proposedFrame.origin.x < self.position.x) {
        newFrame.origin.x += xOffset;
        newFrame.size.height -= xOffset;
    }
    
    if (yOffset > 0 && proposedFrame.origin.y < self.position.y) {
        newFrame.origin.y += yOffset;
        newFrame.size.height -= yOffset;
    }
    
    return newFrame;
}

#pragma mark - PCOverlayNode

- (NSView *)trackingView {
    return self.contentView;
}

- (CGRect)trackingFrame {
    return (CGRect){ self.scrollViewNode.editingOffset, self.contentSize };
}

@end
