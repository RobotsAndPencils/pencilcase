//
//  PCMultiViewNode.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-06-19.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;

#import <PencilCaseLauncher/PCMultiViewNode.h>
#import "PCMultiViewNode.h"
#import "PCMultiViewCellNode.h"
#import "PCOverlayView.h"
#import "PCPassthroughView.h"
#import "SKNode+JavaScript.h"
#import "SKNode+LifeCycle.h"
#import "PCJSContext.h"
#import "SKNode+CropNodeNesting.h"
#import "SKNode+JSExport.h"

static const CGFloat PCMultiViewNodePagerHeight = 20;

@interface PCMultiViewNode ()

@property (strong, nonatomic) PCPassthroughView *contentView;
@property (assign, nonatomic) BOOL transitionInProgress;
@property (strong, nonatomic) UIPageControl *pageControl;

@end

@implementation PCMultiViewNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.contentView = [[PCPassthroughView alloc] init];
        self.contentView.clipsToBounds = YES;

        self.pageControl = [[UIPageControl alloc] init];
        self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.contentView addSubview:self.pageControl];
        _transitionInProgress = NO;
    }
    return self;
}

- (void)pc_didEnterScene {
    [super pc_didEnterScene];
    [self updateCells];
}

- (void)pc_presentationDidStart {
    [super pc_presentationDidStart];
    [[PCOverlayView overlayView] addTrackingNode:self];
}

- (void)pc_dismissTransitionWillStart {
    [super pc_dismissTransitionWillStart];
    [[PCOverlayView overlayView] removeTrackingNode:self];
}

- (void)setXScale:(CGFloat)xScale {
    [super setXScale:xScale];
    [self alertChildrenToUpdateCropNode];
}

- (void)setYScale:(CGFloat)yScale {
    [super setYScale:yScale];
    [self alertChildrenToUpdateCropNode];
}

- (void)setScale:(CGFloat)scale {
    [super setScale:scale];
    [self alertChildrenToUpdateCropNode];
}

- (void)setScalePoint:(CGPoint)scale {
    [super setScalePoint:scale];
    [self alertChildrenToUpdateCropNode];
}

- (void)setZRotation:(CGFloat)zRotation {
    [super setZRotation:zRotation];
    [self alertChildrenToUpdateCropNode];
}

#pragma mark - Public

- (void)nextCell:(PCMultiviewTransitionType)transitionType transitionDuration:(NSNumber *)transitionDuration {
    NSInteger nextCellIndex = [self nextIndex];
    [self transitionToCell:nextCellIndex transitionType:transitionType transitionDuration:transitionDuration];
}

- (void)previousCell:(PCMultiviewTransitionType)transitionType transitionDuration:(NSNumber *)transitionDuration {
    NSInteger previousCellIndex = [self previousIndex];
    [self transitionToCell:previousCellIndex transitionType:transitionType transitionDuration:transitionDuration];
}

- (void)goToCell:(NSInteger)cellIndex transitionType:(PCMultiviewTransitionType)transitionType transitionDuration:(NSNumber *)transitionDuration {
    [self transitionToCell:cellIndex transitionType:transitionType transitionDuration:transitionDuration];
}

- (NSInteger)nextIndex {
    NSInteger nextIndex = self.focusedCellIndex + 1;
    if (nextIndex > self.cells.count - 1) {
        nextIndex = 0;
    }
    return nextIndex;
}

- (NSInteger)previousIndex {
    NSInteger previousIndex = self.focusedCellIndex - 1;
    if (previousIndex < 0) {
        previousIndex = self.cells.count - 1;
    }
    return previousIndex;
}

- (void)transitionToCell:(NSInteger)cellIndex transitionType:(PCMultiviewTransitionType)transitionType transitionDuration:(NSNumber *)transitionDuration {
    if (cellIndex > [self cells].count || cellIndex < 0) return;
    if (self.transitionInProgress) return;
    if (self.focusedCellIndex == cellIndex) return;

    PCMultiViewCellNode *currentView = [self focusedCell];
    PCMultiViewCellNode *transitionToView = [self cellAtIndex:cellIndex];

    currentView.hidden = NO;
    transitionToView.hidden = NO;
    self.transitionInProgress = YES;

    NSArray *transitionActions;
    switch (transitionType) {
        case PCMultiviewTransitionRight:
            transitionActions = [self createTransitionRightActionsTo:transitionToView from:currentView withDuration:[transitionDuration floatValue]];
            break;
        case PCMultiviewTransitionLeft:
            transitionActions = [self createTransitionLeftActionsTo:transitionToView from:currentView withDuration:[transitionDuration floatValue]];
            break;
        case PCMultiviewTransitionUp:
            transitionActions = [self createTransitionUpActionsTo:transitionToView from:currentView withDuration:[transitionDuration floatValue]];
            break;
        case PCMultiviewTransitionDown:
            transitionActions = [self createTransitionDownActionsTo:transitionToView from:currentView withDuration:[transitionDuration floatValue]];
            break;
        case PCMultiviewTransitionInstant:
        default:
            [self transitionCompletedFrom:self.focusedCellIndex toView:cellIndex];
            return;
    }

    [currentView.contentnode runAction:transitionActions[0]];
    [transitionToView.contentnode runAction:transitionActions[1] completion:^{
        [self transitionCompletedFrom:self.focusedCellIndex toView:cellIndex];
    }];
}

- (void)transitionCompletedFrom:(NSInteger)fromCellIndex toView:(NSInteger)toCellIndex {
    self.transitionInProgress = NO;
    self.focusedCellIndex = toCellIndex;
    [self resetAllNodePositions];
    PCMultiViewCellNode *fromCell = [self cellAtIndex:fromCellIndex];
    fromCell.hidden = YES;
}

- (void)resetAllNodePositions {
    for (PCMultiViewCellNode *node in [self cells]) {
        node.contentnode.position = CGPointZero;
    }
}

- (void)setShowPageIndicator:(BOOL)value {
    _showPageIndicator = value;
    self.pageControl.hidden = !value;
}

- (void)setCurrentPageIndicatorColor:(UIColor *)currentPageIndicatorColor {
    _currentPageIndicatorColor = currentPageIndicatorColor;
    self.pageControl.currentPageIndicatorTintColor = currentPageIndicatorColor;
}

- (void)setPageIndicatorColor:(UIColor *)pageIndicatorColor {
    _pageIndicatorColor = pageIndicatorColor;
    self.pageControl.pageIndicatorTintColor = pageIndicatorColor;
}

#pragma mark - Private

- (NSArray *)cells {
    return [self children];
}

- (void)updateCells {
    for (PCMultiViewCellNode *cell in self.cells) {
        cell.hidden = YES;
    }
    [self focusedCell].hidden = NO;
    self.pageControl.numberOfPages = self.cells.count;
    self.pageControl.currentPage = self.focusedCellIndex;
    self.pageControl.frame = CGRectMake(0, self.frame.size.height - PCMultiViewNodePagerHeight, self.frame.size.width, PCMultiViewNodePagerHeight);
}

- (PCMultiViewCellNode *)focusedCell {
    return [self cellAtIndex:self.focusedCellIndex];
}

- (PCMultiViewCellNode *)cellAtIndex:(NSInteger)index {
    if ([self.cells count] == 0) return nil;
    if (index < 0 || index >= [self.cells count]) return nil;
    return self.cells[index];
}

#pragma mark - transitionAnimations

- (NSArray *)createTransitionLeftActionsTo:(PCMultiViewCellNode *)transitionToCell from:(PCMultiViewCellNode *)currentCell withDuration:(CGFloat)duration {
    CGPoint transitionToCellStartPosition = CGPointMake(currentCell.position.x + (self.size.width), transitionToCell.position.y);
    CGPoint transitionToCellEndPosition = currentCell.contentnode.position;
    CGPoint currentCellEndPosition = CGPointMake(currentCell.position.x - (self.size.width), currentCell.position.y);
    SKAction *currentCellAnimation = [SKAction moveTo:currentCellEndPosition duration:duration];
    currentCellAnimation.timingMode = SKActionTimingEaseInEaseOut;
    transitionToCell.contentnode.position = transitionToCellStartPosition;
    SKAction *transitionToCellAnimation = [SKAction moveTo:transitionToCellEndPosition duration:duration];
    transitionToCellAnimation.timingMode = SKActionTimingEaseInEaseOut;

    return @[ currentCellAnimation, transitionToCellAnimation ];
}

- (NSArray *)createTransitionRightActionsTo:(PCMultiViewCellNode *)transitionToCell from:(PCMultiViewCellNode *)currentCell withDuration:(CGFloat)duration {
    CGPoint transitionToCellStartPosition = CGPointMake(currentCell.position.x - (self.size.width), transitionToCell.position.y);
    CGPoint transitionToCellEndPosition = currentCell.contentnode.position;
    CGPoint currentCellEndPosition = CGPointMake(currentCell.position.x + (self.size.width), currentCell.position.y);
    SKAction *currentCellAnimation = [SKAction moveTo:currentCellEndPosition duration:duration];
    currentCellAnimation.timingMode = SKActionTimingEaseInEaseOut;
    transitionToCell.contentnode.position = transitionToCellStartPosition;
    SKAction *transitionToCellAnimation = [SKAction moveTo:transitionToCellEndPosition duration:duration];
    transitionToCellAnimation.timingMode = SKActionTimingEaseInEaseOut;

    return @[ currentCellAnimation, transitionToCellAnimation ];
}

- (NSArray *)createTransitionUpActionsTo:(PCMultiViewCellNode *)transitionToCell from:(PCMultiViewCellNode *)currentCell withDuration:(CGFloat)duration {
    CGPoint transitionToCellStartPosition = CGPointMake(currentCell.position.x, transitionToCell.position.y - self.size.height);
    CGPoint transitionToCellEndPosition = currentCell.contentnode.position;
    CGPoint currentCellEndPosition = CGPointMake(currentCell.position.x, currentCell.position.y + self.size.height);
    SKAction *currentCellAnimation = [SKAction moveTo:currentCellEndPosition duration:duration];
    currentCellAnimation.timingMode = SKActionTimingEaseInEaseOut;
    transitionToCell.contentnode.position = transitionToCellStartPosition;
    SKAction *transitionToCellAnimation = [SKAction moveTo:transitionToCellEndPosition duration:duration];
    transitionToCellAnimation.timingMode = SKActionTimingEaseInEaseOut;

    return @[ currentCellAnimation, transitionToCellAnimation ];
}

- (NSArray *)createTransitionDownActionsTo:(PCMultiViewCellNode *)transitionToCell from:(PCMultiViewCellNode *)currentCell withDuration:(CGFloat)duration {
    CGPoint transitionToCellStartPosition = CGPointMake(currentCell.position.x, transitionToCell.position.y + self.size.height);
    CGPoint transitionToCellEndPosition = currentCell.contentnode.position;
    CGPoint currentCellEndPosition = CGPointMake(currentCell.position.x, currentCell.position.y - self.size.height);
    SKAction *currentCellAnimation = [SKAction moveTo:currentCellEndPosition duration:duration];
    currentCellAnimation.timingMode = SKActionTimingEaseInEaseOut;
    transitionToCell.contentnode.position = transitionToCellStartPosition;
    SKAction *transitionToCellAnimation = [SKAction moveTo:transitionToCellEndPosition duration:duration];
    transitionToCellAnimation.timingMode = SKActionTimingEaseInEaseOut;

    return @[ currentCellAnimation, transitionToCellAnimation ];
}

#pragma mark - Properties

- (void)setFocusedCellIndex:(NSInteger)index {
    _focusedCellIndex = index;

    [self updateCells];

    // A change will always be to an index, so always fire that event
    [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:self userInfo:@{
        PCJSContextEventNotificationEventNameKey: @"focusedViewChanged",
        PCJSContextEventNotificationArgumentsKey: @[ @(self.focusedCellIndex) ]
    }];
}

#pragma mark - PCOverlayNode

- (UIView *)trackingView {
    return self.contentView;
}

@end
