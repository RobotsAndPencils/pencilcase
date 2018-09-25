//
//  PCSKMultiViewNode.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-09.
//
//

#import "PCSKMultiViewNode.h"
#import "PCMultiViewControlView.h"
#import "PCFocusRingView.h"
#import "SKNode+CocosCompatibility.h"
#import "PCSKMultiViewCellNode.h"
#import "AppDelegate.h"
#import "SKNode+LifeCycle.h"
#import "SKNode+NodeInfo.h"

NSInteger const PCSKMultiViewDefaultCellCount = 3;

@interface PCSKMultiViewNode ()

@property (assign, nonatomic) NSInteger focusedCellIndex;
@property (assign, nonatomic) NSInteger focusedCellIndexOneBased;
@property (assign, nonatomic) BOOL hasEditingFocus;
@property (strong, nonatomic) NSView *focusControlContainer;
@property (strong, nonatomic) PCMultiViewControlView *focusControlView;
@property (strong, nonatomic) PCFocusRingView *focusRingView;
@property (assign, nonatomic) BOOL isMainFocus;
@property (strong, nonatomic) PCView *contentView;
@property (nonatomic, readonly) PCSKMultiViewCellNode *editingCell;
@property (nonatomic, readonly) PCSKMultiViewCellNode *focusedCell;
@property (assign, nonatomic) BOOL loaded;

@end

@implementation PCSKMultiViewNode

- (PCEditorResizeBehaviour)editorResizeBehaviour {
    return PCEditorResizeBehaviourContentSize;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.contentView = [[PCView alloc] init];
        self.contentView.wantsLayer = YES;
        self.hasEditingFocus = NO;
        self.currentPageIndicatorColor = [NSColor whiteColor];
        self.pageIndicatorColor = [NSColor colorWithCalibratedWhite:1.0 alpha:0.5];
    }
    return self;
}

- (void)pc_firstTimeSetup {
    if ([[self cells] count] == 0) {
        [self createDefaultCells];
    }
}

- (void)pc_didLoad {
    self.loaded = YES;
}

- (void)pc_didEnterScene {
    [super pc_didEnterScene];
    [[PCOverlayView overlayView] addTrackingNode:self];
    [self updateCells];
}

- (void)pc_willExitScene {
    [super pc_willExitScene];
    [self endFocus];
    [[PCOverlayView overlayView] removeTrackingNode:self];
}

- (void)removeChildrenInArray:(NSArray *)nodes {
    [super removeChildrenInArray:nodes];

    [self ensureWeHaveACell];
    [self ensureValidFocusIndex];
    
    [self updateCells];
    [self updateFocusUI];
}

- (void)addChild:(SKNode *)node {
    [super addChild:node];
    node.size = self.size;
}

#pragma mark - Private

- (void)createDefaultCells {
    for (NSInteger i = 0; i < PCSKMultiViewDefaultCellCount; i++) {
        [self addCell];
    }
    self.focusedCellIndex = 0;
    [self updateCells];
}

- (void)updateCells {
    for (PCSKMultiViewCellNode *cell in self.cells) {
        cell.hidden = YES;
        cell.selectable = NO;
        cell.size = self.contentSize;
    }
    
    self.focusedCell.hidden = NO;
    self.editingCell.selectable = YES;
}

- (void)updateCellCropNodes {
    [self.focusedCell updateCropNode];
}

- (PCSKMultiViewCellNode *)focusedCell {
    return [self cellAtIndex:self.focusedCellIndex];
}

- (PCSKMultiViewCellNode *)editingCell {
    if (!self.hasEditingFocus) return nil;
    return [self cellAtIndex:self.focusedCellIndex];
}

- (PCSKMultiViewCellNode *)cellAtIndex:(NSInteger)index {
    if ([self.cells count] == 0) return nil;
    if (index < 0 || index >= [self.cells count]) return nil;
    return self.cells[index];
}

- (void)addFocusUI {
    self.focusControlContainer = [[NSView alloc] init];
    
    self.focusControlView = [PCMultiViewControlView create];
    __weak typeof(self) weakSelf = self;
    [self.focusControlView setNextCellHandler:^{
        [weakSelf nextCell];
    }];
    [self.focusControlView setPreviousCellHandler:^{
        [weakSelf previousCell];
    }];
    [self.focusControlView setAddCellHandler:^{
        [weakSelf addCell];
    }];
    [self.focusControlView setRemoveCellHandler:^{
        [weakSelf removeCell];
    }];
    [self.focusControlContainer addSubview:self.focusControlView];
    [self.scene.view addSubview:self.focusControlContainer];
    
    self.focusRingView = [[PCFocusRingView alloc] init];
    [[PCOverlayView overlayView] addContentView:self.focusRingView withUpdateBlock:nil];
    [[PCOverlayView overlayView].window makeFirstResponder:self.focusRingView];

    [self updateFocusUI];
}

- (void)updateFocusUI {
    if (!self.focusControlContainer) return;
    
    [self.focusControlContainer setHidden:self.parentHidden || !self.isMainFocus];
    if (self.focusControlContainer.isHidden) return;
    
    self.focusControlView.numberOfCells = [[self cells] count];
    self.focusControlView.currentCellIndex = self.focusedCellIndex + 1;
    
    CGRect nodeFrame = [[PCOverlayView overlayView] directorViewFrameForNode:self withNesting:NO];
    CGRect frame = self.focusControlContainer.frame;
    frame.size = [self.focusControlView fittingSize];
    frame.origin.y = nodeFrame.origin.y - frame.size.height - 10;
    frame.origin.x = nodeFrame.origin.x + (nodeFrame.size.width - frame.size.width) * 0.5;
    self.focusControlContainer.frame = CGRectIntegral(frame);
    
    [[PCOverlayView overlayView] updateView:self.focusRingView fromNode:self];
}

- (void)removeFocusUI {
    [self.focusControlContainer removeFromSuperview];
    self.focusControlContainer = nil;
    self.focusControlView = nil;
    [self.focusRingView removeFromSuperview];
    self.focusRingView = nil;
}

- (void)nextCell {
    self.focusedCellIndex += 1;
    if (self.loaded) {
        // When changed from our overlay view we need to call this. Normally inspector would.
        [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"focusedCellIndex"];
        [[AppDelegate appDelegate] setSelectedNode:self.focusedCell];
    }
}

- (void)previousCell {
    self.focusedCellIndex -= 1;
    if (self.loaded) {
        // When changed from our overlay view we need to call this. Normally inspector would.
        [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"focusedCellIndex"];
        [[AppDelegate appDelegate] setSelectedNode:self.focusedCell];
    }
}

- (void)addCell {
    [[AppDelegate appDelegate] addSpriteKitPlugInNodeNamed:@"PCMultiViewCellNode" asChild:YES toParent:self atIndex:(int)self.focusedCellIndex+1 followInsertionNode:NO];
    [self updateCells];
    [self nextCell];
}

- (void)removeCell {
    [[AppDelegate appDelegate] deleteNode:self.focusedCell];
    [self ensureWeHaveACell];
    [self previousCell];
}

- (void)ensureWeHaveACell {
    if ([[self cells] count] == 0) {
        [self addCell];
    }
}

- (void)ensureValidFocusIndex {
    if (self.focusedCellIndex < 0 || self.focusedCellIndex >= [[self cells] count] ) {
        self.focusedCellIndex = 0;
    }
}

#pragma mark - PCFocusableNode

- (void)focus {
    self.isMainFocus = YES;
    self.hasEditingFocus = YES;
    [self updateCells];
    [self addFocusUI];
    [[AppDelegate appDelegate] setSelectedNode:self.focusedCell];
}

- (void)endFocus {
    self.hasEditingFocus = NO;
    [self updateCells];
    [self removeFocusUI];
}

- (BOOL)selectionOfNodesShouldEndFocus:(NSArray *)nodes {
    BOOL endFocus = NO;
    for (SKNode *node in nodes) {
        if (node != self && ![node hasParent:self]) endFocus = YES;
    }
    return endFocus;
}

- (void)viewUpdated:(BOOL)frameChanged {
    if (frameChanged) {
        [self updateFocusUI];
    }
}

#pragma mark - Properties

- (NSArray *)cells {
    return [self children];
}

- (void)setFocusedCellIndex:(NSInteger)focusedCellIndex {
    if (self.loaded) {
        // Wrapping
        if (focusedCellIndex < 0) {
            focusedCellIndex = [[self cells] count] - 1;
        }
        if (focusedCellIndex >= [[self cells] count]) {
            focusedCellIndex = 0;
        }
    }

    _focusedCellIndex = focusedCellIndex;

    [self updateCells];
    [self updateCellCropNodes];
    [self updateFocusUI];
}

- (NSInteger)focusedCellIndexOneBased {
    return self.focusedCellIndex + 1;
}

- (void)setFocusedCellIndexOneBased:(NSInteger)focusedCellIndexOneBased {
    self.focusedCellIndex = focusedCellIndexOneBased - 1;
}

- (void)setMainFocus:(BOOL)mainFocus {
    self.isMainFocus = mainFocus;
}

- (void)setPosition:(CGPoint)position {
    [super setPosition:position];
    [self updateCellCropNodes];
}

- (void)setRotation:(CGFloat)rotation {
    [super setRotation:rotation];
    [self updateCellCropNodes];
}

- (void)setScale:(CGFloat)scale {
    [super setScale:scale];
    [self updateCellCropNodes];
}

- (void)setYScale:(CGFloat)yScale {
    [super setYScale:yScale];
    [self updateCellCropNodes];
}

- (void)setXScale:(CGFloat)xScale {
    [super setXScale:xScale];
    [self updateCellCropNodes];
}

- (void)setSize:(CGSize)size {
    [super setSize:size];
    [self updateCells];
    [self updateCellCropNodes];
}

- (void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    [self updateCellCropNodes];
}

#pragma mark - PCOverlayNode

- (NSView<PCOverlayTrackingView> *)trackingView {
    return self.contentView;
}

#pragma mark - PCNodeChildInsertion

- (SKNode *)insertionNode {
    if (!self.loaded) return self;
    return self.focusedCell;
}

@end
