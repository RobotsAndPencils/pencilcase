//
//  PCScrollViewNode.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-06-26.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCScrollViewNode.h"
#import "PCScrollView.h"
#import "SKNode+SFGestureRecognizers.h"
#import "SKNode+LifeCycle.h"
#import "SKNode+CocosCompatibility.h"
#import "SKCropNode+Nesting.h"
#import "PCOverlayView.h"
#import "PCPassthroughView.h"

@interface PCScrollViewNode () <UIScrollViewDelegate>

@property (strong, nonatomic) SKCropNode *cropNode;
@property (strong, nonatomic) SKSpriteNode *maskNode;
@property (strong, nonatomic, readonly) SKNode *contentNode;
@property (strong, nonatomic) PCScrollView *scrollView;
@property (strong, nonatomic) UIView *scrollContentView;
@property (strong, nonatomic) PCPassthroughView *contentView;
@property (strong, nonatomic) NSMutableArray *jsScrollHandlers;
@property (assign, nonatomic) CGFloat xRatio;
@property (assign, nonatomic) CGFloat yRatio;
@property (strong, nonatomic) UIPinchGestureRecognizer *scrollPinchGesture;

@end

@implementation PCScrollViewNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cropNode = [SKCropNode node];
        self.cropNode.position = CGPointZero;
        [self addChild:self.cropNode];

        [self setupScrollView];
        
        self.contentView = [[PCPassthroughView alloc] init];
        self.contentView.clipsToBounds = YES;
        
        self.jsScrollHandlers = [NSMutableArray array];

        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)addChild:(SKNode *)node {
    if (node == self.cropNode) {
        [super addChild:node];
    }
    else {
        [self.cropNode addChild:node];
    }
}

- (void)pc_presentationDidStart {
    [[PCOverlayView overlayView] addTrackingNode:self];
    [self addScrollView];
    [super pc_presentationDidStart];
    [self updateCropNode];
}

- (void)pc_presentationCompleted {
    [super pc_presentationCompleted];
    self.scrollView.delegate = self;
}

- (void)pc_willExitScene {
    [super pc_willExitScene];
    [self removeScrollView];
    self.jsScrollHandlers = nil;
}

- (void)pc_dismissTransitionWillStart {
    [super pc_dismissTransitionWillStart];
    [[PCOverlayView overlayView] removeTrackingNode:self];
}

#pragma mark - Public

- (void)addScrollHandler:(JSValue *)handler {
    JSManagedValue *managedHandler = [JSManagedValue managedValueWithValue:handler andOwner:self];
    [self.jsScrollHandlers addObject:managedHandler];
}

#pragma mark - Private

- (void)setupScrollView {
    self.scrollView = [[PCScrollView alloc] init];
    self.scrollView.hidden = YES;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollContentView = [[UIView alloc] init];
    self.scrollContentView.layer.borderColor = [UIColor redColor].CGColor;
    self.scrollContentView.layer.borderWidth = 4;
    self.scrollContentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.scrollContentView];
    self.scrollView.node = self;
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    self.scrollView.pagingEnabled = self.pagingEnabled;
    self.scrollView.userInteractionEnabled = self.userScrollEnabled;
}

- (void)addScrollView {
    [[PCOverlayView overlayView].underlayView addSubview:self.scrollView];
    self.scrollView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
    [[PCOverlayView overlayView] addGestureRecognizer:self.scrollView.panGestureRecognizer];
    self.scrollContentView.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.5];

    [self updateUIView];
}

- (CGPoint)currentContentOffset {
    CGFloat heightDifference = (self.contentNode.contentSize.height - self.contentSize.height);
    CGPoint position = CGPointMake(-self.contentNode.position.x,
                                   self.contentNode.position.y + heightDifference);
    return position;
}

- (CGPoint)overlayOffset {
    CGFloat heightDifference = (self.contentNode.contentSize.height - self.contentSize.height);
    CGPoint offset = CGPointMake(-self.contentNode.position.x,
                                 self.contentNode.position.y + heightDifference);

    offset.x *= self.scrollView.frame.size.width / self.contentSize.width;
    offset.y *= self.scrollView.frame.size.height / self.contentSize.height;

    return offset;
}

- (void)removeScrollView {
    [[PCOverlayView overlayView] removeGestureRecognizer:self.scrollView.panGestureRecognizer];
    if (self.scrollPinchGesture) {
        [[PCOverlayView overlayView] removeGestureRecognizer:self.scrollPinchGesture];
    }
    [self.scrollView removeFromSuperview];
}

- (void)updateUIView {
    //While making changes to our scroll view, we don't want to recieve delegate callbacks that may change our position incorrectly, so we temporarily remove ourself as the delegate. Fixes an issue with the start position of the scroll view in the player on the device.
    self.scrollView.delegate = nil; {
        CGRect uiFrame = [[PCOverlayView overlayView] convertRect:self.frame toOverlayViewFromNode:self willAdjustAnchorPointOfView:NO];
        self.scrollView.frame = uiFrame;

        uiFrame = [[PCOverlayView overlayView] convertRect:self.contentNode.frame toOverlayViewFromNode:self.contentNode willAdjustAnchorPointOfView:NO];
        uiFrame.origin = CGPointZero;
        self.scrollContentView.frame = uiFrame;

        self.xRatio = self.contentNode.frame.size.width / self.scrollContentView.frame.size.width;
        self.yRatio = self.contentNode.frame.size.height / self.scrollContentView.frame.size.height;

        self.scrollView.contentSize = self.scrollContentView.frame.size;
        self.scrollView.contentOffset = [self overlayOffset];
    }
    self.scrollView.delegate = self;
}

- (void)dispatchValueChanged {
    NSArray *arguments = @[ @(self.offset.x), @(self.offset.y) ];
    for (JSManagedValue *managedHandler in self.jsScrollHandlers) {
        [managedHandler.value callWithArguments:arguments];
    }
}

- (void)updateCropNode {
    SKSpriteNode *maskNode = [[SKSpriteNode alloc] initWithColor:[UIColor whiteColor] size:self.contentSize];
    maskNode.position = CGPointZero;
    maskNode.anchorPoint = CGPointZero;
    self.cropNode.maskNode = [self.cropNode constrainMaskToParentCropNodes:maskNode inScene:self.pc_scene];
    [self alertChildrenToUpdateCropNode];
}

- (void)grabGestureIfNeeded {
    if (!self.scrollView.pinchGestureRecognizer) return;

    if (self.scrollPinchGesture) {
        [[PCOverlayView overlayView] removeGestureRecognizer:self.scrollPinchGesture];
    }
    
    [[PCOverlayView overlayView] addGestureRecognizer:self.scrollView.pinchGestureRecognizer];
    self.scrollPinchGesture = self.scrollView.pinchGestureRecognizer;
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

#pragma mark - Properties

/**
 @return Our PCScrollContentNode node
 */
- (SKNode *)contentNode {
    return [[[[self children] firstObject] children] firstObject];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat bottomScrollViewInSKCoordinates = scrollView.contentOffset.y + scrollView.bounds.size.height;
    CGFloat nodeY = -(scrollView.contentSize.height - bottomScrollViewInSKCoordinates);
    CGPoint offset = CGPointMake(-scrollView.contentOffset.x, nodeY);

    offset.x *= self.xRatio;
    offset.y *= self.yRatio;

    self.contentNode.position = offset;
    [self dispatchValueChanged];
    [self alertChildrenToUpdateCropNode];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self.contentNode setScale:scrollView.zoomScale];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.scrollContentView;
}

#pragma mark - PCOverlayNode

- (UIView *)trackingView {
    return self.contentView;
}

- (void)viewUpdated:(BOOL)frameChanged {
    if (frameChanged) {
        [self updateUIView];
    }
}

#pragma mark - Properties

- (void)setPagingEnabled:(BOOL)pagingEnabled {
    _pagingEnabled = pagingEnabled;
    self.scrollView.pagingEnabled = pagingEnabled;
}

- (void)setUserScrollEnabled:(BOOL)userScrollEnabled {
    _userScrollEnabled = userScrollEnabled;
    self.scrollView.userInteractionEnabled = userScrollEnabled;
}

- (CGPoint)offset {
    return self.scrollView.contentOffset;
}

- (void)setOffset:(CGPoint)offset animated:(BOOL)animated {
    [self.scrollView setContentOffset:offset animated:animated];
}

- (CGFloat)zoomScale {
    return self.scrollView.zoomScale;
}

- (void)setZoomScale:(CGFloat)zoomScale {
    self.scrollView.zoomScale = zoomScale;
}

- (CGFloat)maximumZoomScale {
    return self.scrollView.maximumZoomScale;
}

- (void)setMaximumZoomScale:(CGFloat)maximumZoomScale {
    self.scrollView.maximumZoomScale = maximumZoomScale;
    [self grabGestureIfNeeded];
}

- (CGFloat)minimumZoomScale {
    return self.scrollView.minimumZoomScale;
}

- (void)setMinimumZoomScale:(CGFloat)minimumZoomScale {
    self.scrollView.minimumZoomScale = minimumZoomScale;
    [self grabGestureIfNeeded];
}

@end
