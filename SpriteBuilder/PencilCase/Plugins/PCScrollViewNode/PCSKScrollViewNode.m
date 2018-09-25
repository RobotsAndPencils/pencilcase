//
//  PCSKScrollViewNode.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-11.
//
//

#import "PCSKScrollViewNode.h"

#import "PCSKScrollContentNode.h"
#import "PCView.h"
#import "AppDelegate.h"
#import "PCOverlayView.h"
#import "PCStageScene.h"
#import "PCFocusRingView.h"
#import "NodeInfo.h"

// Categories
#import "SKNode+CocosCompatibility.h"
#import "SKNode+LifeCycle.h"
#import "SKNode+CoordinateConversion.h"
#import "SKNode+NodeInfo.h"
#import "SKCropNode+Nesting.h"
#import "SKNode+EditorResizing.h"

@interface PCSKScrollViewNode ()

@property (strong, nonatomic) SKCropNode *cropNode;
@property (strong, nonatomic) SKSpriteNode *maskNode;
@property (strong, nonatomic, readonly) PCSKScrollContentNode *contentNode;
@property (assign, nonatomic) BOOL hasEditingFocus;
@property (strong, nonatomic) PCView *rootView;
@property (assign, nonatomic) BOOL pagingEnabled;
@property (assign, nonatomic) BOOL userScrollEnabled;
@property (strong, nonatomic) PCFocusRingView *focusRingView;
@property (assign, nonatomic) CGSize resizeStartSize;

@end

@implementation PCSKScrollViewNode

#pragma mark - Super

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cropNode = [SKCropNode node];
        self.cropNode.userObject = [NodeInfo nodeInfoWithPlugIn:nil];
        self.cropNode.hideFromUI = YES;
        
        self.cropNode.position = CGPointZero;
        self.cropNode.anchorPoint = CGPointZero;
        [self addChild:self.cropNode];

        self.rootView = [[PCView alloc] init];
        self.focusRingView = [[PCFocusRingView alloc] init];
        [self.rootView addSubview:self.focusRingView];
    }
    return self;
}

- (void)pc_firstTimeSetup {
    SKNode *contentNode = [[AppDelegate appDelegate] addSpriteKitPlugInNodeNamed:@"PCScrollContentNode" asChild:YES toParent:self.cropNode atIndex:0 followInsertionNode:NO];
    contentNode.name = @"ScrollContent";
    contentNode.size = CGSizeMake(self.size.width * 2, self.size.height * 2);
    contentNode.position = CGPointMake(-self.size.width * 0.5, -self.size.height * 0.5);;
    [[AppDelegate appDelegate] setSelectedNode:self];
    [self updateUI];
}

- (PCEditorResizeBehaviour)editorResizeBehaviour {
    return PCEditorResizeBehaviourContentSize;
}

- (void)setSize:(CGSize)size {
    [super setSize:size];

    self.maskNode.size = self.size;
    self.maskNode.position = CGPointZero;
    self.cropNode.position = CGPointZero;
    [self.contentNode resizeToFitInParent];
    [self updateCropNode];
}

#pragma mark Life Cycle

- (void)pc_didEnterScene {
    [super pc_didEnterScene];
    [[PCOverlayView overlayView] addTrackingNode:self];
    [self updateCropNode];
}

- (void)pc_didMoveToParent {
    [super pc_didMoveToParent];
    [self updateCropNode];
}

- (void)pc_willExitScene {
    [super pc_willExitScene];
    [self endFocus];
    [[PCOverlayView overlayView] removeTrackingNode:self];
    [self.focusRingView removeFromSuperview];
}

#pragma mark - Crop node tracking

- (void)setPosition:(CGPoint)position {
    [super setPosition:position];
    [self updateCropNode];
}

- (void)setRotation:(CGFloat)rotation {
    [super setRotation:rotation];
    [self updateCropNode];
}

- (void)setZRotation:(CGFloat)zRotation {
    [super setZRotation:zRotation];
    [self updateCropNode];
}

- (void)setScaleX:(CGFloat)scaleX {
    [super setScaleX:scaleX];
    [self updateCropNode];
}

- (void)setXScale:(CGFloat)xScale {
    [super setXScale:xScale];
    [self updateCropNode];
}

- (void)setScaleY:(CGFloat)scaleY {
    [super setScaleY:scaleY];
    [self updateCropNode];
}

- (void)setYScale:(CGFloat)yScale {
    [super setYScale:yScale];
    [self updateCropNode];
}

- (void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    [self updateCropNode];
}

#pragma mark - Editor resize events

- (void)beginResizing {
    self.contentNode.hideBorder = YES;
    self.resizeStartSize = self.contentNode.size;
}

- (void)finishResizing {
    self.contentNode.size = self.resizeStartSize;
    [self.contentNode resizeToFitInParent];
    self.contentNode.hideBorder = NO;
}

#pragma mark - Private

- (void)updateUI {
    [self updateCropNode];
    self.contentNode.selectable = self.hasEditingFocus;
    self.focusRingView.ringColor = self.hasEditingFocus ? [NSColor keyboardFocusIndicatorColor] : [NSColor lightGrayColor];
    self.focusRingView.frame =  (CGRect){ [self editingOffset], self.contentSize };
}

- (CGPoint)editingOffset {
    if (!self.hasEditingFocus) return CGPointZero;

    //When we have editing focus, our frame must is expanded so that our external ring is not cropped. This handles offsetting the position so that the children and focus ring still render in the right place.
    return CGPointMake(self.contentNode.contentSize.width - self.contentSize.width, self.contentNode.contentSize.height - self.contentSize.height);
}

- (void)updateCropNode {
    if (self.hasEditingFocus) {
        self.cropNode.maskNode = nil;
        [self alertChildrenToUpdateCropNode];
        return;
    }
    SKSpriteNode *maskNode = [SKSpriteNode node];
    maskNode.color = [NSColor whiteColor];
    maskNode.size = self.size;
    maskNode.position = CGPointZero;
    maskNode.anchorPoint = CGPointZero;
    self.cropNode.maskNode = [self.cropNode constrainMaskToParentCropNodes:maskNode inScene:self.cropNode.scene];
    [self alertChildrenToUpdateCropNode];
}

#pragma mark - Properties

- (SKNode *)contentNode {
    return [[self.cropNode children] firstObject];
}

#pragma mark - PCFocusableNode

- (void)focus {
    self.hasEditingFocus = YES;
    [self updateUI];
    [[AppDelegate appDelegate] setSelectedNode:self.contentNode];
}

- (void)endFocus {
    self.hasEditingFocus = NO;
    [self updateUI];
}

- (BOOL)selectionOfNodesShouldEndFocus:(NSArray *)nodes {
    BOOL endFocus = NO;
    for (SKNode *node in nodes) {
        if (node != self && ![node inParentHierarchy:self]) endFocus = YES;
    }
    return endFocus;
}

#pragma mark - PCOverlayNode

- (NSView *)trackingView {
    return self.rootView;
}

- (CGRect)trackingFrame {
    if (!self.hasEditingFocus) return (CGRect){ CGPointZero, self.contentSize };

    return ({
        CGSize sizeDifference = CGSizeMake(self.contentNode.contentSize.width - self.contentSize.width, self.contentNode.contentSize.height - self.contentSize.height);
        CGSize size = CGSizeMake(self.contentSize.width + 2 * sizeDifference.width, self.contentSize.height + 2 * sizeDifference.height);
        CGPoint origin = CGPointMake(-sizeDifference.width, -sizeDifference.height);
        (CGRect){ origin, size };
    });
}

- (void)viewUpdated:(BOOL)frameChanged {
    if (frameChanged) {
        [self updateUI];
    }
}

#pragma mark - PCNodeChildInsertion

- (SKNode *)insertionNode {
    return [self contentNode] ?: self.cropNode;
}

#pragma mark - PCNodeChildExport

- (NSArray *)exportChildren {
    if (!self.contentNode) return @[];
    return @[ self.contentNode ];
}

@end
