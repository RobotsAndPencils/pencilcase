//
//  PCStageScene.h
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-06-11.
//
//

#import <SpriteKit/SpriteKit.h>
#import "Constants.h"
#import "PCProjectSettings.h"


@class AppDelegate;
@class PCGuidesNode;
@class PCSnapNode;
@class PCRulersNode;

typedef NS_OPTIONS(NSUInteger, PCTransformSnapEdge) {
    PCTransformSnapEdgeNone = 0,
    PCTransformSnapEdgeLeft = 1 << 0,
    PCTransformSnapEdgeRight = 1 << 1,
    PCTransformSnapEdgeTop = 1 << 2,
    PCTransformSnapEdgeBottom = 1 << 3,
};

@interface PCStageScene : SKScene

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) SKNode *rootNode;
@property (nonatomic, strong) SKSpriteNode *stageBgLayer;
@property (nonatomic, strong) SKSpriteNode *bgLayer;
@property (nonatomic, strong) SKSpriteNode *contentLayer;
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, strong) PCSnapNode *snapNode;
@property (nonatomic, strong) PCRulersNode *rulerLayer;
@property (nonatomic, strong) PCGuidesNode *guideLayer;

@property (nonatomic, assign) CGSize winSize;
@property (nonatomic, assign) CGPoint scrollOffset;
@property (nonatomic, assign) CCBTool currentTool;
@property (nonatomic, assign) CGFloat stageZoom;
@property (nonatomic, assign) CGPoint origin;

+ (SKScene *)sceneWithAppDelegate:(AppDelegate *)app;
+ (instancetype)scene;

- (void)forceRedraw;

- (void)setStageSize:(CGSize)size centeredOrigin:(BOOL)centeredOrigin;
- (CGSize)stageSize;
- (BOOL)centeredOrigin;
- (void)fitStageToRootNodeIfNecessary;
- (void)setStageBorder:(PCStageBorderType)borderType;

- (void)zoomToFit;

- (void)removeRootNode;
- (void)replaceRootNodeWith:(SKNode *)node;

- (void)updateSelection;

// Event handling forwarded by view
- (void)mouseMoved:(NSEvent *)event;
- (void)mouseEntered:(NSEvent *)event;
- (void)mouseExited:(NSEvent *)event;
- (void)cursorUpdate:(NSEvent *)event;
- (void)flagsChanged:(NSEvent *)event;
- (BOOL)handleKeyDown:(NSEvent *)theEvent;

- (void)savePreviewToFile:(NSString *)path completion:(dispatch_block_t)completion;

// Converts to document coordinates from view coordinates
- (CGPoint)convertToDocSpace:(CGPoint)viewPt;
// Converst to view coordinates from document coordinates
- (CGPoint)convertToViewSpace:(CGPoint)docPt;

- (CGRect)stageUIFrame;
- (void)endFocusedNode;
- (void)conditionallyEndFocusedNodeBasedOnSelectedNodes:(NSArray *)nodes;
- (NSArray *)allNodesOfClass:(Class)klass;

/**
 Typically, we only store the nodes under the last click when determining which transforms we can apply. In some cases (like a new node being added, then immediately selected) we need to manually say 'This node can interact with the mouse.'
 */
- (void)selectNodeForMouseInput:(SKNode *)node;

@end
