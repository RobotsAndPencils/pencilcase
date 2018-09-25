//
//  PCStageScene.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-06-11.
//
//

// Header
#import "PCStageScene.h"

// Categories
#import "SKNode+CocosCompatibility.h"
#import "SKNode+CoordinateConversion.h"
#import "SKNode+Sequencer.h"
#import "NSImage+Rotation.m"
#import "SKNode+NodeInfo.h"
#import "SKNode+HitTest.h"
#import "NSImage+PNGRepresentation.h"
#import "SKNode+Selection.h"
#import "SKNode+EditorResizing.h"
#import "PCMathUtilities.h"
#import "NSView+Snapshot.h"
#import "SKNode+Movement.h"
#import "SKNode+AnchorPoint.h"

// Project
#import "AppDelegate.h"
#import "CGPointUtilities.h"
#import "PCGuidesNode.h"
#import "MainWindow.h"
#import "NodeInfo.h"
#import "PlugInNode.h"
#import "PCOverlayView.h"
#import "PhysicsHandler.h"
#import "PositionPropertySetter.h"
#import "PCRulersNode.h"
#import "SequencerKeyframe.h"
#import "PCSnapNode.h"
#import "PCFocusableNode.h"
#import "PCFrameConstrainingNode.h"
#import "PCNodeManager.h"
#import "SKNode+JavaScript.h"
#import "PCUndoManager.h"
#import "PCCustomPreviewNode.h"
#import "PCResourceManager.h"
#import "PCDoubleClickableNode.h"
#import "CGSizeUtilities.h"

// Frameworks
#import <tgmath.h>

const CGFloat CCBSinglePointSelectionRadius = 23.0;
const CGFloat CCBAnchorPointMouseOverRadius = 3.0;
const CGFloat CCBRotationMouseOverMinRadius = 8.0;
const CGFloat CCBRotationMouseOverMaxRadius = 25.0;
const CGFloat CCBRotationShiftLockMinimumAngleInRadians = M_PI / 8; // 1/16 of a circle

const CGFloat PCIPhoneZoomScaleX = 70;
const CGFloat PCIPhoneZoomScaleY = 245;
const CGFloat PCIPadZoomScaleX = 85;
const CGFloat PCIPadZoomScaleY = 85;

const CGFloat PCMaxStageZoom = 1.5;
const CGFloat PCMinStageZoom = 0.25;

static const CGFloat PCForegroundZPosition = 100;
static const CGFloat PCNodeHandleZPosition = 999;

static PCStageScene *sharedScene;

static const CGPoint PCScrollMinimumVisibleContent = { 100, 100 };

@interface PCStageScene ()

@property (nonatomic, assign) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic, strong) SKShapeNode *marqueeSelectionNode;

@property (nonatomic, strong) SKShapeNode *behaviourHightlightNode;

@property (nonatomic, strong) SKNode *selectionLayer;
@property (nonatomic, strong) SKNode *physicsLayer;
@property (nonatomic, strong) SKNode *borderLayer;
@property (nonatomic, strong) SKNode *transformScalingNode;

@property (nonatomic, strong) SKSpriteNode *anchorPointSprite;

// Borders
@property (nonatomic, strong) SKSpriteNode *borderBottom;
@property (nonatomic, strong) SKSpriteNode *borderDevice;
@property (nonatomic, strong) SKSpriteNode *borderRight;
@property (nonatomic, strong) SKSpriteNode *borderLeft;
@property (nonatomic, strong) SKSpriteNode *borderTop;

@property (nonatomic, assign) int currentMouseTransform;
@property (nonatomic, assign) CGPoint mousePos;
@property (nonatomic, assign) CGPoint mouseDownPos;
@property (nonatomic, assign) CGPoint previousDragMousePos;
@property (nonatomic, assign) CGFloat transformStartRotation;
@property (nonatomic, assign) BOOL isPanning;
@property (nonatomic, assign) CGPoint panningStartScrollOffset;
@property (nonatomic, strong) NSMutableArray *nodesAtSelectionPt;
@property (nonatomic, assign) int currentNodeAtSelectionPtIdx;
@property (nonatomic, assign) CGPoint cornerOrientation; // Which way is the corner facing.
@property (nonatomic, assign) int cornerIndex; // Which corner is being transformed
@property (nonatomic, assign) BOOL useMarqueeSelection;
@property (nonatomic, assign) BOOL shouldMarqueeSelect;
@property (nonatomic, assign) CGPoint marqueeSelectionStartPoint;
@property (nonatomic, weak) SKNode *marqueeSelectionRootNode;
@property (nonatomic, assign) BOOL isMouseTransforming;
@property (nonatomic, assign) BOOL mouseInside;

@property (strong, nonatomic) NSMutableArray /* SKNode<PCFocusableNode> */ *focusedNodes;

@end


@implementation PCStageScene

- (id)initWithAppDelegate:(AppDelegate *)app {
    self = [super init];
    if (self) {
        _appDelegate = app;
        _stageZoom = 1;
        _nodesAtSelectionPt = [NSMutableArray array];
        self.name = @"PCStageScene";
        // self.mouseEnabled = YES;
        self.userInteractionEnabled = YES;
        [self setupEditorNodes];
        self.focusedNodes = [NSMutableArray array];

        __weak typeof(self) weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:PCTokenHighlightSourceChangeNotification object:nil queue:nil usingBlock:^(NSNotification *notification) {
            NSUUID *sourceUUID = notification.userInfo[PCTokenHighlightSourceUUIDKey];
            BOOL state = [notification.userInfo[PCTokenHighlightSourceStateKey] boolValue];
            [weakSelf setHightlight:state forNodeWithUUID:sourceUUID];
        }];

        [[PCResourceManager sharedManager] addResourceObserver:self];
    }
    return self;
}

- (void)setHightlight:(BOOL)hightlight forNodeWithUUID:(NSUUID *)UUID {
    SKNode *node = [self.rootNode recursiveChildNodeWithUUID:[UUID UUIDString]];
    if (!node) return;

    if (!self.behaviourHightlightNode) {
        self.behaviourHightlightNode = [[SKShapeNode alloc] init];
        self.behaviourHightlightNode.lineWidth = 1;
        self.behaviourHightlightNode.strokeColor = [[SKColor blueColor] colorWithAlphaComponent:0.75];
        self.behaviourHightlightNode.fillColor = [SKColor colorWithRed:210/255.0 green:231/255.0 blue:251/255.0 alpha:0.9];
        self.behaviourHightlightNode.zPosition = 9001;
        self.behaviourHightlightNode.antialiased = NO;
    }
    if (!hightlight) {
        [self.behaviourHightlightNode removeFromParent];
    }
    else {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPoint points[PCTransformEdgeHandleCount];
        [node pc_calculateCornerPointsWithPoints:points];

        CGPoint bl = pc_CGPointRound([node.parent convertPoint:points[PCTransformEdgeHandleBottomLeft] toNode:self.contentLayer]);
        CGPoint br = pc_CGPointRound([node.parent convertPoint:points[PCTransformEdgeHandleBottomRight] toNode:self.contentLayer]);
        CGPoint tr = pc_CGPointRound([node.parent convertPoint:points[PCTransformEdgeHandleTopRight] toNode:self.contentLayer]);
        CGPoint tl = pc_CGPointRound([node.parent convertPoint:points[PCTransformEdgeHandleTopLeft] toNode:self.contentLayer]);

        if (self.behaviourHightlightNode.parent) [self.behaviourHightlightNode removeFromParent];

        if ([self pointContainsNaN:bl]
            || [self pointContainsNaN:br]
            || [self pointContainsNaN:tr]
            || [self pointContainsNaN:tl]) {

            CGPathRelease(path);
            return;
        }

        CGPathMoveToPoint(path, NULL, bl.x, bl.y);
        CGPathAddLineToPoint(path, NULL, br.x, br.y);
        CGPathAddLineToPoint(path, NULL, tr.x, tr.y);
        CGPathAddLineToPoint(path, NULL, tl.x, tl.y);
        CGPathAddLineToPoint(path, NULL, bl.x, bl.y);

        self.behaviourHightlightNode.path = path;
        CGPathRelease(path);

        [self.contentLayer addChild:self.behaviourHightlightNode];
    }
}

- (BOOL)pointContainsNaN:(CGPoint)point {
    return isnan(point.x) || isnan(point.y);
}

+ (SKScene *)sceneWithAppDelegate:(AppDelegate *)app {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedScene = [[PCStageScene alloc] initWithAppDelegate:app];
    });
    return sharedScene;
}

+ (instancetype)scene {
    return sharedScene;
}

- (void)setupEditorNodes {
    // Gray background
    self.bgLayer = [SKSpriteNode spriteNodeWithColor:[NSColor grayColor] size:CGSizeMake(4096, 4096)];
    self.bgLayer.name = @"bgLayer";
    self.bgLayer.position = CGPointZero;
    self.bgLayer.anchorPoint = CGPointZero;
    self.bgLayer.userInteractionEnabled = NO;
    [self addChild:self.bgLayer];

    // Guides
    self.guideLayer = [PCGuidesNode node];
    [self addChild:self.guideLayer];
    self.guideLayer.zPosition = PCForegroundZPosition;
    
    // Rulers
    self.rulerLayer = [PCRulersNode node];
    [self addChild:self.rulerLayer];
    self.rulerLayer.zPosition = PCForegroundZPosition;


    // White content layer
    self.stageBgLayer = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeZero];
    self.stageBgLayer.name = @"stageBgLayer";
    self.stageBgLayer.userInteractionEnabled = NO;
    [self addChild:self.stageBgLayer];

    self.contentLayer = [SKSpriteNode spriteNodeWithColor:[NSColor clearColor] size:CGSizeZero];
    self.contentLayer.name = @"contentLayer";
    self.contentLayer.anchorPoint = CGPointZero;
    [self.stageBgLayer addChild:self.contentLayer];

    // Border layer (translucent gray that extends from stage bounds to edge of scene)
    self.borderLayer = [SKNode node];
    self.borderLayer.name = @"borderLayer";
    [self addChild:self.borderLayer];
    
    // Physics layer
    self.physicsLayer = [SKNode node];
    self.physicsLayer.name = @"physicsLayer";
    self.physicsLayer.zPosition = 9000;
    [self addChild:self.physicsLayer];

    NSColor *borderColor = [NSColor colorWithWhite:0.5 alpha:0.7];

    self.borderBottom = [SKSpriteNode spriteNodeWithColor:borderColor size:CGSizeZero];
    self.borderTop = [SKSpriteNode spriteNodeWithColor:borderColor size:CGSizeZero];
    self.borderLeft = [SKSpriteNode spriteNodeWithColor:borderColor size:CGSizeZero];
    self.borderRight = [SKSpriteNode spriteNodeWithColor:borderColor size:CGSizeZero];
    for (SKSpriteNode *border in @[ self.borderBottom, self.borderTop, self.borderLeft, self.borderRight ]) {
        border.anchorPoint = CGPointZero;
    }

    self.borderBottom.userInteractionEnabled = NO;
    self.borderTop.userInteractionEnabled = NO;
    self.borderLeft.userInteractionEnabled = NO;
    self.borderRight.userInteractionEnabled = NO;

    [self.borderLayer addChild:self.borderBottom];
    [self.borderLayer addChild:self.borderTop];
    [self.borderLayer addChild:self.borderLeft];
    [self.borderLayer addChild:self.borderRight];

    self.borderDevice = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeZero];
    [self.borderLayer addChild:self.borderDevice];

    // Selection layer
    self.selectionLayer = [SKNode node];
    self.selectionLayer.name = @"selectionLayer";
    self.selectionLayer.zPosition = 9000;
    [self addChild:self.selectionLayer];
    
    // Snapping
    self.snapNode = [PCSnapNode node];
    [self addChild:self.snapNode];
    
    // marquee selection
    self.marqueeSelectionNode = [[SKShapeNode alloc] init];
    self.marqueeSelectionNode.lineWidth = 1;
    self.marqueeSelectionNode.strokeColor = [[SKColor lightGrayColor] colorWithAlphaComponent:0.75];
    self.marqueeSelectionNode.fillColor = [[SKColor darkGrayColor] colorWithAlphaComponent:0.25];
    self.marqueeSelectionNode.zPosition = 9000;
    self.marqueeSelectionNode.antialiased = NO;
}

- (void)setStageBorder:(PCStageBorderType)borderType {
    self.borderDevice.hidden = YES;
    self.stageBgLayer.hidden = NO;
    if (CGSizeEqualToSize(self.stageBgLayer.frame.size, CGSizeZero)) {
        borderType = PCStageBorderTypeNone;
        self.stageBgLayer.hidden = YES;
    }
    
    switch (borderType) {
        case PCStageBorderTypeDevice: {
            SKTexture *deviceTexture = nil;
            BOOL rotateDevice = NO;

            PCCanvasSize canvasSize = [self.appDelegate orientedDeviceTypeForSize:self.stageBgLayer.frame.size];
            switch (canvasSize) {
                case PCCanvasSizeIPhonePortrait:
                    deviceTexture = [SKTexture textureWithImageNamed:@"frame-iphone6Plus.png"];
                    rotateDevice = NO;
                    break;
                case PCCanvasSizeIPhoneLandscape:
                    deviceTexture = [SKTexture textureWithImageNamed:@"frame-iphone6Plus.png"];
                    rotateDevice = YES;
                    break;
                case PCCanvasSizeIPadPortrait:
                    deviceTexture = [SKTexture textureWithImageNamed:@"frame-ipad.png"];
                    rotateDevice = NO;
                    break;
                case PCCanvasSizeIPadLandscape:
                    deviceTexture = [SKTexture textureWithImageNamed:@"frame-ipad.png"];
                    rotateDevice = YES;
                    break;
                default:
                    break;
            }
            if (deviceTexture) {
                if (rotateDevice) {
                    self.borderDevice.rotation = 90;
                } else {
                    self.borderDevice.rotation = 0;
                }
                self.borderDevice.texture = deviceTexture;
            }
            
            PCDeviceTargetOrientation orientationTarget = self.appDelegate.currentProjectSettings.deviceResolutionSettings.deviceOrientation;
            CGSize stageBorderSize = self.stageUIFrame.size;
            if (orientationTarget == PCDeviceTargetOrientationLandscape) {
                 stageBorderSize = CGSizeMake(self.stageUIFrame.size.height, self.stageUIFrame.size.width);
            }
            CGSize stageBorderZoomScale = [self stageBorderZoomScale:self.appDelegate.currentProjectSettings.deviceResolutionSettings.deviceTarget];
            self.borderDevice.size =  CGSizeMake(stageBorderSize.width + stageBorderZoomScale.width, stageBorderSize.height + stageBorderZoomScale.height);

            self.borderLayer.alpha = 1.0;
            self.borderDevice.hidden = NO;
            self.borderLayer.hidden = NO;
            break;
        }
        case PCStageBorderTypeTransparent: {
            self.borderLayer.alpha = 0.5;
            self.borderLayer.hidden = NO;
            break;
        }
        case PCStageBorderTypeOpaque: {
            self.borderLayer.alpha = 1.0;
            self.borderLayer.hidden = NO;
            break;
        }
        case PCStageBorderTypeNone:
        default: {
            self.borderLayer.hidden = YES;
            break;
        }
    }

    [self.appDelegate updateCanvasBorderMenu];
}

- (CGSize)stageBorderZoomScale:(PCDeviceTargetType)deviceTarget {
    switch (deviceTarget) {
        case PCDeviceTargetTypePhone:
            return CGSizeMake(self.stageZoom * PCIPhoneZoomScaleX, self.stageZoom * PCIPhoneZoomScaleY);
        case PCDeviceTargetTypeTablet:
        default:
            return CGSizeMake(self.stageZoom * PCIPadZoomScaleX, self.stageZoom * PCIPadZoomScaleY);
    }
}

#pragma mark Stage properties

- (void)setStageSize:(CGSize)size centeredOrigin:(BOOL)centeredOrigin {
    CGSize scaledSize = pc_CGSizeIntegral(CGSizeMake(size.width * self.stageBgLayer.xScale, size.height * self.stageBgLayer.yScale));
    self.stageBgLayer.size = scaledSize;
    self.contentLayer.size = size;

    if (centeredOrigin) {
        self.contentLayer.position = CGPointZero;
    }
    else {
        self.contentLayer.position = pc_CGPointIntegral(CGPointMake(-size.width / 2, -size.height / 2));
    }

    NSInteger stageBorderType = [AppDelegate appDelegate].currentProjectSettings.stageBorderType;
    [self setStageBorder:stageBorderType];
}

- (BOOL)centeredOrigin {
    return (self.contentLayer.position.x != 0);
}

- (CGSize)stageSize {
    return self.stageBgLayer.contentSize;
}

- (CGSize)viewSizeInPixels {
    return self.view.bounds.size;
}

- (CGSize)viewSize {
    CGFloat scale = [AppDelegate appDelegate].contentScaleFactor;
    CGSize viewSizeInPixels = self.view.bounds.size;
    viewSizeInPixels.width /= scale;
    viewSizeInPixels.height /= scale;
    return pc_CGSizeIntegral(viewSizeInPixels);
}

#pragma mark - Scene Events

- (void)didFinishUpdate {
    [[PCOverlayView overlayView] updateTrackingNodePositions];
}

#pragma mark Zoom

- (void)fitStageToRootNodeIfNecessary {
    if (self.appDelegate.parentDocument) {
        [self setStageSize:self.rootNode.frame.size centeredOrigin:NO];
    }
}

- (void)zoomToFit {
    CGSize stageSize = self.stageBgLayer.contentSize;
    stageSize = CGSizeMake(stageSize.width * 1.1, stageSize.height * 1.1);
    CGSize contentSize = self.frame.size;
    CGFloat zoom = contentSize.height / stageSize.height;
    zoom = fmin(zoom, contentSize.width / stageSize.width);
    self.stageZoom = zoom;
}

- (void)setStageZoom:(CGFloat)zoom {
    zoom = MAX(PCMinStageZoom, MIN(zoom, PCMaxStageZoom));

    CGFloat zoomFactor = zoom / _stageZoom;

    self.scrollOffset = pc_CGPointMultiply(self.scrollOffset, zoomFactor);

    self.stageBgLayer.scale = zoom;
    self.borderDevice.scale = zoom;

    _stageZoom = zoom;
}

#pragma mark Extra properties

- (void)setupExtraPropsForNode:(SKNode *)node {
    [node setExtraProp:@(-1) forKey:@"tag"];
    [node setExtraProp:@YES forKey:@"lockedScaleRatio"];

    [node setExtraProp:@"" forKey:@"customClass"];
    [node setExtraProp:@0 forKey:@"memberVarAssignmentType"];
    [node setExtraProp:@"" forKey:@"memberVarAssignmentName"];

    [node setExtraProp:@YES forKey:@"isExpanded"];
}

- (void)removeRootNode {
    if (self.rootNode) {
        [self.rootNode removeFromParent];
    }
    self.rootNode = nil;
}

- (void)replaceRootNodeWith:(SKNode *)node {
    [self removeRootNode];

    self.rootNode = node;

    if (!node) return;

    [self.contentLayer addChild:node];

    [self fitStageToRootNodeIfNecessary];
}

#pragma mark Selections

- (BOOL)selectedNodeHasReadOnlyProperty:(NSString *)prop {
    SKNode *selectedNode = self.appDelegate.selectedSpriteKitNode;

    if (!selectedNode) return NO;
    NodeInfo *info = selectedNode.userObject;
    PlugInNode *plugIn = info.plugIn;

    NSDictionary *propInfo = [plugIn.nodePropertiesDict objectForKey:prop];
    return [[propInfo objectForKey:@"readOnly"] boolValue];
}

- (void)addHandlesToNode:(SKNode *)node points:(CGPoint *)points {
    NSMutableArray *handles = [NSMutableArray array];
    SKTexture *handleTexture = [SKNode pc_handleTexture];
    for (NSUInteger i = 0; i < PCTransformEdgeHandleCount; i++) {
        SKSpriteNode *handleNode = [SKSpriteNode spriteNodeWithTexture:handleTexture];
        handleNode.zPosition = PCNodeHandleZPosition;
        [handles addObject:handleNode];
    }

    [node pc_calculateSelectionCornerPointsWithPoints:points inNodeSpace:self.selectionLayer];
    [handles enumerateObjectsUsingBlock:^(SKSpriteNode *handle, NSUInteger handleIndex, BOOL *stop) {
        handle.position = pc_CGPointRound(points[handleIndex]);
        [self.selectionLayer addChild:handle];
    }];
}

- (void)updateSelection {
    NSArray *selectedNodes = self.appDelegate.selectedSpriteKitNodes;
    PCNodeManager *spriteKitNodeManager = self.appDelegate.nodeManager;

    uint overTypeField = 0x0;

    [[PCOverlayView overlayView].nodeHandlesView removeAnchorPoints];

    if (selectedNodes.count > 0) {
        for (SKNode *node in selectedNodes) {
            if (node.locked) continue;

            self.anchorPointSprite = [SKSpriteNode spriteNodeWithImageNamed:@"select-pt"];
            CGPoint anchorPointPosition = [node.parent convertPoint:node.position toNode:self.selectionLayer];
            self.anchorPointSprite.position = anchorPointPosition;
            [self.selectionLayer addChild:self.anchorPointSprite];
            BOOL commandKeyPressed = (NSCommandKeyMask & [NSEvent modifierFlags]) == NSCommandKeyMask;
            self.anchorPointSprite.hidden = !commandKeyPressed;

            if ([node conformsToProtocol:@protocol(PCOverlayNode)] && commandKeyPressed) {
                CGRect frame = [[PCOverlayView overlayView] convertRect:CGRectMake(node.position.x, node.position.y, 0, 0) toOverlayContentViewFromNode:node withNesting:NO];
                [[PCOverlayView overlayView].nodeHandlesView showAnchorPointAtPosition:frame.origin];
            }
            
            CGPoint points[PCTransformEdgeHandleCount];

            // Selection corners in world space
            [self addHandlesToNode:node points:points];

            CGPoint mousePositionInSelectionLayer = [self.contentLayer convertPoint:self.mousePos toNode:self.selectionLayer];

            if (!CGSizeEqualToSize(node.size, CGSizeZero)
                && !(overTypeField & kCCBToolAnchor)
                && self.currentMouseTransform == kCCBTransformHandleNone
                && [node allowsUserAnchorPointChange]
                && [self isOverSpriteKitNodeAnchor:node withPoint:mousePositionInSelectionLayer]) {
                
                if ((NSCommandKeyMask & [NSEvent modifierFlags]) == NSCommandKeyMask){
                    overTypeField |= kCCBToolAnchor;
                }
            }

            if (!(overTypeField & kCCBToolRotate)
                && self.currentMouseTransform == kCCBTransformHandleNone
                && [spriteKitNodeManager allowsUserRotation]
                && [self isOverRotation:mousePositionInSelectionLayer withPoints:points withCorner:&_cornerIndex withOrientation:&_cornerOrientation]) {
                    overTypeField |= kCCBToolRotate;
            }

            if (!(overTypeField & kCCBToolScale)
                && self.currentMouseTransform == kCCBTransformHandleNone
                && [spriteKitNodeManager allowsUserSizing]
                && ([self isOverScale:mousePositionInSelectionLayer withPoints:points withCorner:&_cornerIndex withOrientation:&_cornerOrientation]
                    || [self isOverScaleInDirection:mousePositionInSelectionLayer withPoints:points cornerIndex:&_cornerIndex withOrientation:&_cornerOrientation])) {
                overTypeField |= kCCBToolScale;
            }

            if (!(overTypeField & kCCBToolTranslate) && self.currentMouseTransform == kCCBTransformHandleNone && [node allowsUserPositioning]) {
                if ([self isOverContentBorders:mousePositionInSelectionLayer withPoints:points]) {
                    overTypeField |= kCCBToolTranslate;
                }
            }
        }
    }

    if (self.currentMouseTransform == kCCBTransformHandleNone) {
        if (!(overTypeField & self.currentTool)) {
            self.currentTool = kCCBToolSelection;
        }

        if (overTypeField) {
            for (int i = 1; i < kCCBToolMax; i++) {
                CCBTool type = (CCBTool)(1 << i);
                if (overTypeField & type && self.currentTool > type) {
                    self.currentTool = type;
                    break;
                }
            }
        }
    }
}

- (BOOL)isOverSpriteKitNodeAnchor:(SKNode *)node withPoint:(CGPoint)point {
    CGPoint center = [node.parent convertPoint:node.position toNode:self.selectionLayer];
    if (pc_CGPointDistance(point, center) < CCBAnchorPointMouseOverRadius) return YES;
    return NO;
}

- (BOOL)isOverContentBorders:(CGPoint)_mousePoint withPoints:(const CGPoint *)points /* {bl,br,tr,tl,b,r,t,l} */
{
    CGMutablePathRef mutablePath = CGPathCreateMutable();
    CGPathAddLines(mutablePath, nil, points, 4);
    CGPathCloseSubpath(mutablePath);
    BOOL result = CGPathContainsPoint(mutablePath, nil, _mousePoint, NO);
    CFRelease(mutablePath);
    return result;
}

- (BOOL)isOverScale:(CGPoint)mousePos withPoints:(const CGPoint *)points/* {bl,br,tr,tl,b,r,t,l} */  withCorner:(int *)cornerIndex withOrientation:(CGPoint *)orientation {
    const float kDistanceToCorner = 8.0f;

    for (int i = 0; i < 4; i++) {
        CGPoint p1 = points[i % 4];
        CGPoint p2 = points[(i + 1) % 4];
        CGPoint p3 = points[(i + 2) % 4];

        if (pc_CGPointLength(pc_CGPointSubtract(mousePos, p2)) < kDistanceToCorner) {
            if (orientation) {
                CGPoint segment1 = pc_CGPointSubtract(p2, p1);
                CGPoint segment2 = pc_CGPointSubtract(p2, p3);

                *orientation = pc_CGPointNormalize(pc_CGPointAdd(segment1, segment2));
            }

            if (cornerIndex) {
                *cornerIndex = (i + 1) % 4;
            }

            return YES;
        }
    }

    return NO;
}

- (BOOL)isOverRotation:(CGPoint)mousePosition withPoints:(const CGPoint *)points/* {bl,br,tr,tl,b,r,t,l} */ withCorner:(int *)cornerIndex withOrientation:(CGPoint *)orientation {
    for (int i = 0; i < 4; i++) {
        CGPoint p1 = points[i % 4];
        CGPoint p2 = points[(i + 1) % 4];
        CGPoint p3 = points[(i + 2) % 4];

        CGPoint segment1 = pc_CGPointSubtract(p2, p1);
        CGPoint unitSegment1 = pc_CGPointNormalize(segment1);

        CGPoint segment2 = pc_CGPointSubtract(p2, p3);
        CGPoint unitSegment2 = pc_CGPointNormalize(segment2);

        CGPoint mouseVector = pc_CGPointSubtract(mousePosition, p2);

        CGFloat dot1 = pc_CGPointDot(mouseVector, unitSegment1);
        CGFloat dot2 = pc_CGPointDot(mouseVector, unitSegment2);
        CGFloat distanceToCorner = pc_CGPointLength(mouseVector);

        if (dot1 > 0.0f && dot2 > 0.0f && distanceToCorner > CCBRotationMouseOverMinRadius && distanceToCorner < CCBRotationMouseOverMaxRadius) {
            if (cornerIndex) {
                *cornerIndex = (i + 1) % 4;
            }

            if (orientation) {
                *orientation = pc_CGPointNormalize(pc_CGPointAdd(unitSegment1, unitSegment2));
            }

            return YES;
        }
    }

    return NO;
}

- (BOOL)isOverScaleInDirection:(CGPoint)mousePos withPoints:(const CGPoint *)points /* {bl,br,tr,tl,b,r,t,l} */ cornerIndex:(int *)cornerIndex withOrientation:(CGPoint *)orientation {
    CGPoint edges[] = { points[4], points[5], points[6], points[7] };
    
    for (int side = 0; side < 4; side++) {
        CGPoint p = edges[side];
        
        const float kDistanceToCorner = 4.0f;
        
        if (pc_CGPointLength(pc_CGPointSubtract(mousePos, p)) < kDistanceToCorner ) {
            if (cornerIndex) {
                *cornerIndex = side + 4;
            }
            if (orientation) {
                CGPoint opposite = edges[(side + 2) % 4];
                *orientation = pc_CGPointNormalize(pc_CGPointSubtract(p, opposite));
            }
            return YES;
        }
    }
    return NO;
}

#pragma mark Handle mouse input

- (CGPoint)convertToDocSpace:(CGPoint)viewPt {
    return [self convertPointFromView:viewPt];
}

- (CGPoint)convertToViewSpace:(CGPoint)docPt {
    return [self convertPointToView:docPt];
}

- (NSString *)positionPropertyForSelectedNode {
    NodeInfo *info = self.appDelegate.selectedSpriteKitNode.userObject;
    PlugInNode *plugIn = info.plugIn;

    return plugIn.positionProperty;
}

- (CGPoint)selectedNodePos {
    if (!self.appDelegate.selectedSpriteKitNode) return CGPointZero;

    return NSPointToCGPoint(self.appDelegate.selectedSpriteKitNode.position);
}

- (CCBTransformHandle)transformHandleUnderPt:(CGPoint)pt {
    for (SKNode *node in self.appDelegate.selectedSpriteKitNodes) {
        if (node.locked) continue;

        self.transformScalingNode = node;

        //NOTE The following return statements should go in order of the CCBTool enumeration.
        //kCCBToolAnchor
        if (!self.anchorPointSprite.hidden && !CGSizeEqualToSize(self.transformScalingNode.size, CGSizeZero) && [self isOverSpriteKitNodeAnchor:node withPoint:pt]) {
            if ((NSCommandKeyMask & [NSEvent modifierFlags]) == NSCommandKeyMask) {
                return kCCBTransformHandleAnchorPoint;
            }
        }

        CGPoint points[PCTransformEdgeHandleCount];
        [node pc_calculateSelectionCornerPointsWithPoints:points inNodeSpace:self.selectionLayer];

        if ([self.appDelegate.selectedSpriteKitNode allowsUserSizing]) {
            //kCCBToolScale
            if ([self isOverScale:pt withPoints:points withCorner:&_cornerIndex withOrientation:&_cornerOrientation]) {
                switch ([[self.appDelegate.selectedSpriteKitNodes firstObject] editorResizeBehaviour]) {
                case PCEditorResizeBehaviourScale:
                    return kCCBTransformHandleScale;
                case PCEditorResizeBehaviourContentSize:
                    return kCCBTransformHandleContentSize;
                }
            }
        
            //kCCBScaleInDirection
            if ([self isOverScaleInDirection:pt withPoints:points cornerIndex:&_cornerIndex withOrientation:&_cornerOrientation]) {
                PCEditorResizeBehaviour resizeBehaviour = [[self.appDelegate.selectedSpriteKitNodes firstObject] editorResizeBehaviour];
                if (self.cornerIndex == PCTransformEdgeHandleBottom || self.cornerIndex == PCTransformEdgeHandleTop) {
                    return resizeBehaviour == PCEditorResizeBehaviourScale ? kCCBTransformHandleScaleY : kCCBTransformHandleContentSizeY;
                } else {
                    return resizeBehaviour == PCEditorResizeBehaviourScale ? kCCBTransformHandleScaleX : kCCBTransformHandleContentSizeX;
                }
            }
        }

        //kCCBToolRotate
        if ([self isOverRotation:pt withPoints:points withCorner:&_cornerIndex withOrientation:&_cornerOrientation]) {
            return kCCBTransformHandleRotate;
        }
    }

    self.transformScalingNode = NULL;
    return kCCBTransformHandleNone;
}

- (void)nodesUnderPt:(CGPoint)pt rootNode:(SKNode *)node nodes:(NSMutableArray *)nodes {
    if (!node) return;

    NodeInfo *parentInfo = node.parent.userObject;
    PlugInNode *parentPlugIn = parentInfo.plugIn;
    if (parentPlugIn && !parentPlugIn.canHaveChildren) return;

    if (CGRectGetWidth(node.frame) == 0 || CGRectGetHeight(node.frame) == 0) {
        CGPoint worldPos = [node.parent pc_convertToWorldSpace:node.position];
        if (pc_CGPointDistance(worldPos, pt) < CCBSinglePointSelectionRadius) {
            [nodes addObject:node];
        }
    }
    else {
        CGPoint point = [self.contentLayer convertPoint:pt toNode:self];
        if ([node pc_hitTestWithWorldPoint:point]) {
            [nodes addObject:node];
        }
    }

    // Visit children
    for (int i = 0; i < [node.children count]; i++) {
        [self nodesUnderPt:pt rootNode:node.children[(NSUInteger)i] nodes:nodes];
    }

    //Don't select nodes that are locked or hidden.
    NSArray *selectableNodes = Underscore.array(nodes).filter(^BOOL(SKNode *node) {
        return node.userSelectable;
    }).unwrap;
    [nodes removeAllObjects];
    [nodes addObjectsFromArray:selectableNodes];
}

- (NSMutableArray *)nodesUnderAreaFromStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint rootNode:(SKNode *)node nodes:(NSMutableArray *)nodes {
    if (!node) return nodes;

    NodeInfo *parentInfo = node.parent.userObject;
    PlugInNode *parentPlugIn = parentInfo.plugIn;
    if (parentPlugIn && !parentPlugIn.canHaveChildren) return nodes;
    
    if ([node pc_hitTestWithWorldRect:startPoint endPoint:endPoint]) {
        if (!node.locked && !node.hidden && !node.parentHidden && !node.hideFromUI && node.selectable && node != self.rootNode) {
            [nodes addObject:node];
        }
    }
    
    // Visit children
    for (int i = 0; i < [node.children count]; i++) {
        [self nodesUnderAreaFromStartPoint:startPoint endPoint:endPoint rootNode:node.children[(NSUInteger)i] nodes:nodes];
    }
    return nodes;
}

- (BOOL)isLocalCoordinateSystemFlipped:(SKNode *)node {
    // TODO: Can this be done more efficiently?
    BOOL isMirroredX = NO;
    BOOL isMirroredY = NO;
    SKNode *nodeMirrorCheck = node;
    while (nodeMirrorCheck != self.rootNode && nodeMirrorCheck != NULL) {
        if (nodeMirrorCheck.yScale < 0) isMirroredY = !isMirroredY;
        if (nodeMirrorCheck.xScale < 0) isMirroredX = !isMirroredX;
        nodeMirrorCheck = nodeMirrorCheck.parent;
    }

    return (isMirroredX ^ isMirroredY);
}

- (void)enableAnchorPoint:(BOOL)enabled {
    if (self.anchorPointSprite) {
        self.anchorPointSprite.hidden = !enabled;
    }
}

- (void)mouseDown:(NSEvent *)event {
    if (!self.appDelegate.hasOpenedDocument) return;

    [[PCUndoManager sharedPCUndoManager] beginBatchChanges];

    CGPoint pos = [event locationInNode:self.contentLayer];
    self.previousDragMousePos = pos;

    if ([self.guideLayer mouseDown:pos event:event]) return;
    if ([self.appDelegate.physicsHandler mouseDown:[self.contentLayer pc_convertToWorldSpace:pos] event:event]) return;

    self.mouseDownPos = pos;

    self.shouldMarqueeSelect = NO;
    self.marqueeSelectionStartPoint = [self.contentLayer convertPoint:pos toNode:self];
    [self.marqueeSelectionNode removeFromParent]; // Apparently mouseDown isn't allways followed by mouseUp.
    [self addChild:self.marqueeSelectionNode];
    self.marqueeSelectionNode.hidden = YES;

    // Handle grab tool
    if (self.currentTool == kCCBToolGrab || ([event modifierFlags] & NSAlternateKeyMask)) {
        self.currentTool = kCCBToolGrab;
        self.isPanning = YES;
        self.panningStartScrollOffset = self.scrollOffset;
        return;
    }

    // Transform handles
    if (!self.appDelegate.physicsHandler.editingPhysicsBody && ![self.appDelegate isShowingInstantAlpha]) {
        CCBTransformHandle th = [self transformHandleUnderPt:[event locationInNode:self.selectionLayer]];
        self.useMarqueeSelection = NO;

        if (th == kCCBTransformHandleAnchorPoint) {
            // Anchor points are fixed for singel point nodes
            if (CGRectGetWidth(self.transformScalingNode.frame) == 0 || CGRectGetHeight(self.transformScalingNode.frame) == 0) {
                return;
            }

            if (![self.transformScalingNode allowsUserAnchorPointChange]) {
                return;
            }

            // Transform anchor point
            self.currentMouseTransform = kCCBTransformHandleAnchorPoint;
            if ([self.transformScalingNode respondsToSelector:@selector(anchorPoint)]) {
                self.transformScalingNode.transformStartAnchorPoint = self.transformScalingNode.anchorPoint;
                self.transformScalingNode.transformStartPosition = self.transformScalingNode.position;
                for (SKNode *childnode in self.transformScalingNode.children) {
                    childnode.transformStartPosition = childnode.position;
                }
                for (SKNode *node in self.appDelegate.selectedSpriteKitNodes) {
                    node.transformStartPosition = node.position;
                }
            }
            else {
                for (SKNode *node in self.appDelegate.selectedSpriteKitNodes) {
                    node.transformStartPosition = [node position];
                }
            }
            return;
        }
        if (th == kCCBTransformHandleRotate && self.appDelegate.selectedSpriteKitNode != self.rootNode) {
            if (![self.appDelegate.nodeManager allowsUserRotation]) {
                return;
            }
            // Start rotation transform
            self.currentMouseTransform = kCCBTransformHandleRotate;
            for (SKNode *node in self.appDelegate.selectedSpriteKitNodes) {
                node.transformStartRotation = DEGREES_TO_RADIANS(node.rotation);
            }
            return;
        }

        if ((th == kCCBTransformHandleScale || th == kCCBTransformHandleScaleY || th == kCCBTransformHandleScaleX) && self.appDelegate.selectedSpriteKitNode != self.rootNode) {
            if (![self.appDelegate.nodeManager allowsUserSizing]) {
                return;
            }
            self.currentMouseTransform = th;
            [self.appDelegate setSelectedNode:self.transformScalingNode];
            for (SKNode *node in self.appDelegate.selectedSpriteKitNodes) {
                node.transformStartScaleX = node.xScale;
                node.transformStartScaleY = node.yScale;
            }
            
            return;
        }
        
        if ((th == kCCBTransformHandleContentSize || th == kCCBTransformHandleContentSizeX || th == kCCBTransformHandleContentSizeY) && (self.appDelegate.selectedSpriteKitNode != self.rootNode || self.appDelegate.parentDocument != nil)) {
            self.currentMouseTransform = th;
            [self.appDelegate setSelectedNode:self.transformScalingNode];
            if (self.rootNode == self.appDelegate.selectedSpriteKitNode) {
                self.stageBgLayer.alpha = 0.5f;
            }
            for (SKNode *node in self.appDelegate.selectedSpriteKitNodes) {
                [node beginResizing];
            }
            return;
        }
    }


    // Clicks inside objects
    [self.nodesAtSelectionPt removeAllObjects];
    [self nodesUnderPt:pos rootNode:self.rootNode nodes:self.nodesAtSelectionPt];
    self.currentNodeAtSelectionPtIdx = (int)[self.nodesAtSelectionPt count] - 1;
    self.currentMouseTransform = kCCBTransformHandleNone;

    if (self.currentNodeAtSelectionPtIdx >= 0) {
        self.currentMouseTransform = kCCBTransformHandleDownInside;
    }
    else {
        // No clicked node
        if ([event modifierFlags] & NSShiftKeyMask) {
            // Ignore
            return;
        } else {
            // Deselect
            self.appDelegate.selectedSpriteKitNodes = nil;
        }
    }

    self.useMarqueeSelection = NO;
    if (self.currentMouseTransform == kCCBTransformHandleDownInside) {
        SKNode *clickedNode = self.nodesAtSelectionPt[(NSUInteger)self.currentNodeAtSelectionPtIdx];
        NSMutableArray *modifiedSelection = [self.appDelegate.selectedSpriteKitNodes mutableCopy];
        if ([event modifierFlags] & NSShiftKeyMask || [event modifierFlags] & NSCommandKeyMask) {
            // Add to/subtract from selection
            if ([modifiedSelection containsObject:clickedNode]) {
                [modifiedSelection removeObject:clickedNode];
            } else {
                [modifiedSelection addObject:clickedNode];
            }
            self.appDelegate.selectedSpriteKitNodes = modifiedSelection;
        } else {
            // Replace selection
            if ([self canStartMarqueeSelectionFromClickOnNode:clickedNode]) {
                self.marqueeSelectionRootNode = clickedNode;
                self.useMarqueeSelection = YES;
                [self.appDelegate setSelectedNode:clickedNode];
            } else {
                if (![modifiedSelection containsObject:clickedNode]) {
                    [self.appDelegate setSelectedNode:clickedNode];
                }
            }
        }
    } else {
        self.marqueeSelectionRootNode = self.rootNode;
        self.useMarqueeSelection = YES;
    }
    return;
}

//0=bottom, 1=right  2=top 3=left
- (CGPoint)vertexLocked:(CGPoint)anchorPoint {
    CGPoint vertexScaler = CGPointMake(-1.0f, -1.0f);

    const float kTolerance = 0.01f;
    if (fabs(anchorPoint.x) <= kTolerance) {
        vertexScaler.x = 3;
    }

    if (fabs(anchorPoint.x) >= 1.0f - kTolerance) {
        vertexScaler.x = 1;
    }

    if (fabs(anchorPoint.y) <= kTolerance) {
        vertexScaler.y = 0;
    }
    if (fabs(anchorPoint.y) >= 1.0f - kTolerance) {
        vertexScaler.y = 2;
    }
    return vertexScaler;
}

- (CGPoint)vertexLockedScaler:(CGPoint)anchorPoint withCorner:(int)cornerSelected /* {bl,br,tr,tl,b,r,t,l} */
{
    CGPoint vertexScaler = { 1.0f, 1.0f };

    const float kTolerance = 0.01f;
    if (fabs(anchorPoint.x) < kTolerance) {
        if (cornerSelected == 0 || cornerSelected == 3 || cornerSelected == 7) {
            vertexScaler.x = 0.0f;
        }
    }
    if (fabs(anchorPoint.x) > 1.0f - kTolerance) {
        if (cornerSelected == 1 || cornerSelected == 2 || cornerSelected == 5) {
            vertexScaler.x = 0.0f;
        }
    }

    if (fabs(anchorPoint.y) < kTolerance) {
        if (cornerSelected == 0 || cornerSelected == 1 || cornerSelected == 4) {
            vertexScaler.y = 0.0f;
        }
    }
    if (fabs(anchorPoint.y) > 1.0f - kTolerance) {
        if (cornerSelected == 2 || cornerSelected == 3 || cornerSelected == 6) {
            vertexScaler.y = 0.0f;
        }
    }
    return vertexScaler;
}

- (CGPoint)projectOntoVertex:(CGPoint)point withContentSize:(CGSize)size alongAxis:(int)axis//b,r,t,l
{
    CGPoint v = CGPointZero;
    CGPoint w = CGPointZero;

    switch (axis) {
        case 0:
            w = CGPointMake(size.width, 0.0f);
            break;
        case 1:
            v = CGPointMake(size.width, 0.0f);
            w = CGPointMake(size.width, size.height);

            break;
        case 2:
            v = CGPointMake(size.width, size.height);
            w = CGPointMake(0, size.height);

            break;
        case 3:
            v = CGPointMake(0, size.height);
            break;

        default:
            break;
    }

    //see ccpClosestPointOnLine for notes.
    const CGFloat l2 = pc_CGPointLengthSquare(pc_CGPointSubtract(w, v));  // i.e. |w-v|^2 -  avoid a sqrt
    const CGFloat t = pc_CGPointDot(pc_CGPointSubtract(point, v), pc_CGPointSubtract(w, v)) / l2;
    const CGPoint projection = pc_CGPointAdd(v, pc_CGPointMultiply(pc_CGPointSubtract(w, v), t));  // v + t * (w - v);  Projection falls on the segment
    return projection;
}

- (void)rightMouseDown:(NSEvent *)theEvent {
    CGPoint pos = [theEvent locationInNode:self.contentLayer];

    if ([self.guideLayer rightMouseDown:pos event:theEvent]) return;

    // Clicks inside objects
    [self.nodesAtSelectionPt removeAllObjects];
    [self nodesUnderPt:pos rootNode:self.rootNode nodes:self.nodesAtSelectionPt];
    if ([self.nodesAtSelectionPt count] == 0) return;
    self.currentNodeAtSelectionPtIdx = (int)[self.nodesAtSelectionPt count] - 1;

    SKNode *clickedNode = self.nodesAtSelectionPt[(NSUInteger)self.currentNodeAtSelectionPtIdx];

    // Add to/subtract from selection
    NSMutableArray *modifiedSelection = [self.appDelegate.selectedSpriteKitNodes mutableCopy];

    if ([modifiedSelection count] == 1) {
        [modifiedSelection removeAllObjects];
        [modifiedSelection addObject:clickedNode];
    } else {
        if (![modifiedSelection containsObject:clickedNode]) {
            [modifiedSelection addObject:clickedNode];
        }
    }
    self.appDelegate.selectedSpriteKitNodes = modifiedSelection;

    NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
    NSMenuItem *menuItemCut = [[NSMenuItem alloc] initWithTitle:@"Cut" action:@selector(cut:) keyEquivalent:@""];
    NSMenuItem *menuItemCopy = [[NSMenuItem alloc] initWithTitle:@"Copy" action:@selector(copy:) keyEquivalent:@""];
    NSMenuItem *menuItemPaste = [[NSMenuItem alloc] initWithTitle:@"Paste" action:@selector(paste:) keyEquivalent:@""];
    NSMenuItem *menuItemDelete = [[NSMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteBackward:) keyEquivalent:@""];

    [theMenu addItem:menuItemCut];
    [theMenu addItem:menuItemCopy];
    [theMenu addItem:menuItemPaste];
    [theMenu addItem:[NSMenuItem separatorItem]];
    [theMenu addItem:menuItemDelete];

    [NSMenu popUpContextMenu:theMenu withEvent:theEvent forView:self.view];
}

- (void)mouseDragged:(NSEvent *)event {
    CGPoint mousePositionInContentLayer = [event locationInNode:self.contentLayer];

    if ([self.guideLayer mouseDragged:mousePositionInContentLayer event:event]) return;
    if ([self.appDelegate.physicsHandler mouseDragged:[self.contentLayer pc_convertToWorldSpace:mousePositionInContentLayer] event:event]) return;

    if (self.useMarqueeSelection) {
        self.marqueeSelectionNode.hidden = NO;
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, self.marqueeSelectionStartPoint.x, self.marqueeSelectionStartPoint.y);
        CGPoint endPoint = [self.contentLayer convertPoint:mousePositionInContentLayer toNode:self];
        CGFloat x = self.marqueeSelectionStartPoint.x;
        CGFloat y = self.marqueeSelectionStartPoint.y;
        CGFloat width = endPoint.x - x;
        CGFloat height = endPoint.y - y;
        CGPathAddRect(path, NULL, CGRectIntegral(CGRectMake(x, y, width, height)));
        self.marqueeSelectionNode.path = path;
        
        NSArray *nodes = [self marqueeSelectNodesWithStartPoint:self.marqueeSelectionStartPoint endPoint:[self convertPoint:mousePositionInContentLayer fromNode:self.contentLayer]];
        if ([nodes count] > 0) {
            self.appDelegate.selectedSpriteKitNodes = nodes;
            self.currentNodeAtSelectionPtIdx = [nodes count] - 1;
        }
        else {
            if (self.marqueeSelectionRootNode) {
                [self.appDelegate setSelectedNode:self.marqueeSelectionRootNode];
            }
        }
        return;
    }

    if (!self.appDelegate.hasOpenedDocument) return;
    [self mouseMoved:event];

    if (self.currentNodeAtSelectionPtIdx < 0) return;
    PCNodeManager *spriteKitNodeManager = [[AppDelegate appDelegate] nodeManager];

    [self enabledSnapping];

    if (self.currentMouseTransform == kCCBTransformHandleDownInside) {
        SKNode *clickedNode = self.nodesAtSelectionPt[(NSUInteger)self.currentNodeAtSelectionPtIdx];

        BOOL selectedNodeUnderClickPt = NO;
        for (SKNode *eachSelectedNode in self.appDelegate.selectedSpriteKitNodes) {
            if ([self.nodesAtSelectionPt containsObject:eachSelectedNode]) {
                selectedNodeUnderClickPt = YES;
                break;
            }
        }

        if ([event modifierFlags] & NSShiftKeyMask) {
            // Add to selection
            NSMutableArray *modifiedSelection = [self.appDelegate.selectedSpriteKitNodes mutableCopy];

            if (![modifiedSelection containsObject:clickedNode]) {
                [modifiedSelection addObject:clickedNode];
            }
            self.appDelegate.selectedSpriteKitNodes = modifiedSelection;
        }
        else if (![self.appDelegate.selectedSpriteKitNodes containsObject:clickedNode]
            && !selectedNodeUnderClickPt) {
            // Replace selection
            [self.appDelegate setSelectedNode:clickedNode];
        }

        for (SKNode *selectedNode in self.appDelegate.selectedSpriteKitNodes) {
            if (selectedNode.locked) continue;
            selectedNode.transformStartPosition = selectedNode.position;
        }

        BOOL rootNodeIsSelected = (self.appDelegate.selectedSpriteKitNode == self.rootNode);
        BOOL selectedNodeIsLayoutNode = NO;
        if (!rootNodeIsSelected && !selectedNodeIsLayoutNode) {
            self.currentMouseTransform = kCCBTransformHandleMove;
        }
    }

    if (self.currentMouseTransform == kCCBTransformHandleMove) {
        for (SKNode *selectedNode in self.appDelegate.selectedSpriteKitNodes) {
            if (selectedNode.locked || ![selectedNode allowsUserPositioning]) continue;
            
            CGPoint localPos = [selectedNode.parent convertPoint:mousePositionInContentLayer fromNode:self.contentLayer];
            CGPoint localDownPos = [selectedNode.parent convertPoint:self.mouseDownPos fromNode:self.contentLayer];
            
            CGPoint deltaLocal = pc_CGPointSubtract(localPos, localDownPos);

            CGFloat xDelta = deltaLocal.x;
            CGFloat yDelta = deltaLocal.y;

            // Handle shift key (straight drags)
            if ([event modifierFlags] & NSShiftKeyMask) {
                if (fabs(xDelta) > fabs(yDelta)) {
                    yDelta = 0;
                }
                else {
                    xDelta = 0;
                }
            }

            CGPoint newPosition = CGPointMake(selectedNode.transformStartPosition.x + xDelta, selectedNode.transformStartPosition.y + yDelta);
            
            if ([selectedNode conformsToProtocol:@protocol(PCFrameConstrainingNode)]) {
                CGRect frame = (CGRect){ newPosition, selectedNode.size };
                frame = [(id<PCFrameConstrainingNode>)selectedNode constrainFrameInPoints:frame];
                newPosition = frame.origin;
            }
            
            selectedNode.position = pc_CGPointIntegral(newPosition);
            [PositionPropertySetter addPositionKeyframeForSpriteKitNode:selectedNode];

            [self.appDelegate saveUndoStateDidChangeProperty:@"position"];
            [self.snapNode mouseDraggedWithCornerId:(CCBCornerId) PCTransformEdgeHandleNone lockAspectRatio:NO];
        }
        [self.appDelegate refreshProperty:@"position"];
    }
    else if (self.currentMouseTransform == kCCBTransformHandleScale
             || self.currentMouseTransform == kCCBTransformHandleScaleY
             || self.currentMouseTransform == kCCBTransformHandleScaleX
             || self.currentMouseTransform == kCCBTransformHandleContentSize
             || self.currentMouseTransform == kCCBTransformHandleContentSizeX
             || self.currentMouseTransform == kCCBTransformHandleContentSizeY) {

        // Mouse down on a scale/size handle selects only that one node
        SKNode *node = spriteKitNodeManager.managedNodes.firstObject;

        BOOL shouldLockAspectRatio = [event modifierFlags] & NSShiftKeyMask ? YES : NO;

        switch ([node editorResizeBehaviour]) {
            case PCEditorResizeBehaviourScale: {
                NodeInfo *nodeInfo = node.userObject;
                CGPoint mousePositionInNodeParent = [node.parent convertPoint:mousePositionInContentLayer fromNode:self.contentLayer];
                CGVector newScale = [node pc_scaleFromMousePosition:mousePositionInNodeParent cornerIndex:self.cornerIndex];
                shouldLockAspectRatio |= [nodeInfo.extraProps[@"scaleLock"] boolValue];
                if (shouldLockAspectRatio) {
                    newScale = [SKNode pc_lockAspectRatioOfScale:newScale cornerIndex:self.cornerIndex];
                }
                node.position = pc_CGPointIntegral([node pc_positionWhenScaledToNewScale:newScale cornerIndex:self.cornerIndex]);
                node.xScale = newScale.dx;
                node.yScale = newScale.dy;

                if (node.transformStartScaleX == 0 && node.xScale != 0) {
                    node.transformStartScaleX = node.xScale;
                }
                if(node.transformStartScaleY == 0 && node.yScale != 0) {
                    node.transformStartScaleY = node.yScale;
                }

                [self.appDelegate saveUndoStateDidChangeProperty:@"scale"];

                break;
            }
            case PCEditorResizeBehaviourContentSize: {
                CGPoint mousePositionInNodeParent = [node.parent convertPoint:mousePositionInContentLayer fromNode:self.contentLayer];
                CGSize newContentSize = [node pc_sizeFromMousePosition:mousePositionInNodeParent cornerIndex:self.cornerIndex];
                if (shouldLockAspectRatio) {
                    newContentSize = [node pc_lockAspectRatioOfSize:newContentSize cornerIndex:self.cornerIndex];
                }
                CGPoint newPosition = [node pc_positionWhenContentSizeSetToSize:newContentSize cornerIndex:self.cornerIndex];

                // Constrain new frame if necessary
                if ([self.transformScalingNode conformsToProtocol:@protocol(PCFrameConstrainingNode)]) {
                    CGRect frame = (CGRect){ newPosition, newContentSize };
                    frame = [(id <PCFrameConstrainingNode>)self.transformScalingNode constrainFrameInPoints:frame];
                    newPosition = frame.origin;
                    newContentSize = frame.size;
                }

                if ([node conformsToProtocol:@protocol(PCFrameConstrainingNode)]) {
                    CGRect frame = (CGRect){ newPosition, newContentSize };
                    frame = [(id <PCFrameConstrainingNode>)node constrainFrameInPoints:frame];
                    newPosition = frame.origin;
                    newContentSize = frame.size;
                }

                //No interim state during a flip with content size (as size cannot be negative), so we have to update which handle the user is dragging when they cross over.
                if (pc_sign(newContentSize.width) != pc_sign(node.xScale)) {
                    self.cornerIndex = CCBOppositeHorizontalCorner(self.cornerIndex);
                }
                if (pc_sign(newContentSize.height) != pc_sign(node.yScale)) {
                    self.cornerIndex = CCBOppositeVerticalCorner(self.cornerIndex);
                }

                [PositionPropertySetter setPosition:newPosition forSpriteKitNode:node prop:@"position"];
                [PositionPropertySetter setSize:NSMakeSize(fabs(newContentSize.width / node.xScale), fabs(newContentSize.height / node.yScale)) forSpriteKitNode:node prop:@"contentSize"];
                [self.appDelegate saveUndoStateDidChangeProperty:@"contentSize"];
                break;
            }
        }

        CCBCornerId cornerId = (CCBCornerId) self.cornerIndex;
        [self.snapNode mouseDraggedWithCornerId:cornerId lockAspectRatio:shouldLockAspectRatio];

        [self.appDelegate refreshProperty:@"scale"];
        [self.appDelegate refreshProperty:@"contentSize"];
        [self.appDelegate refreshProperty:@"position"];

        CGPoint orientationMouseTrackingPoint = self.mouseDownPos; // Track start position for edges and current position for corners.
        if (self.currentMouseTransform != kCCBTransformHandleScaleX
            && self.currentMouseTransform != kCCBTransformHandleScaleY
            && self.currentMouseTransform != kCCBTransformHandleContentSizeX
            && self.currentMouseTransform != kCCBTransformHandleContentSizeY) {
            orientationMouseTrackingPoint = mousePositionInContentLayer;
        }

        // Update the scale tool cursor
        CGPoint centerPosition = [self.transformScalingNode.parent convertPoint:CGPointMake(CGRectGetMidX(self.transformScalingNode.frame), CGRectGetMidY(self.transformScalingNode.frame)) toNode:self.contentLayer];
        CGPoint orientationPoint = pc_CGPointSubtract(centerPosition, orientationMouseTrackingPoint);
        self.cornerOrientation = pc_CGPointNormalize(orientationPoint);
        self.currentTool = kCCBToolScale; // Force it to update by setting it
    }
    else if (self.currentMouseTransform == kCCBTransformHandleRotate) {
        CGPoint nodePosition = [self.transformScalingNode.parent convertPoint:self.transformScalingNode.position toNode:self.contentLayer];
        
        CGPoint handleAngleVectorStart = pc_CGPointSubtract(nodePosition, self.mouseDownPos);
        CGPoint handleAngleVectorCurrent = pc_CGPointSubtract(nodePosition, mousePositionInContentLayer);

        CGFloat handleAngleInRadiansStart = atan2(handleAngleVectorStart.y, handleAngleVectorStart.x);
        CGFloat handleAngleInRadiansCurrent = atan2(handleAngleVectorCurrent.y, handleAngleVectorCurrent.x);

        CGFloat deltaRotationInRadians = handleAngleInRadiansCurrent - handleAngleInRadiansStart;

        if ([self isLocalCoordinateSystemFlipped:self.transformScalingNode.parent]) {
            deltaRotationInRadians = -deltaRotationInRadians;
        }

        while (deltaRotationInRadians > M_PI) {
            deltaRotationInRadians -= M_PI * 2.0;
        }
        while (deltaRotationInRadians < -M_PI) {
            deltaRotationInRadians += M_PI * 2.0;
        }

        for (SKNode *node in self.appDelegate.selectedSpriteKitNodes) {
            CGFloat newRotationInRadians = node.transformStartRotation + deltaRotationInRadians;
            // Handle shift key (fixed rotation angles)
            if ([event modifierFlags] & NSShiftKeyMask) {
                newRotationInRadians = round(newRotationInRadians / CCBRotationShiftLockMinimumAngleInRadians) * CCBRotationShiftLockMinimumAngleInRadians;
            }
            
            node.rotation = RADIANS_TO_DEGREES(newRotationInRadians);
        }
        
        [self.appDelegate refreshProperty:@"rotation"];
        [self.appDelegate saveUndoStateDidChangeProperty:@"rotation"];
        
        // Update the rotation tool
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(self.transformScalingNode.transformStartRotation + deltaRotationInRadians);
        // CGPointApplyAffineTransform "concatenates" transforms if we pass cornerOrientation
        // Passing a normalized point instead so we only rotate the cursor with the current angle
        CGPoint cornerTransformPoint = CGPointZero;
        switch (self.cornerIndex) {
            case 0:
                cornerTransformPoint = CGPointMake(-1, -1);
                break;
            case 1:
                cornerTransformPoint = CGPointMake(1, -1);
                break;
            case 2:
                cornerTransformPoint = CGPointMake(1, 1);
                break;
            case 3:
                cornerTransformPoint = CGPointMake(-1, 1);
                break;
            default:
                break;
        }
        self.cornerOrientation = CGPointApplyAffineTransform(cornerTransformPoint, rotationTransform);
        self.currentTool = kCCBToolRotate; //Force it to update.
    }
    else if (self.currentMouseTransform == kCCBTransformHandleAnchorPoint) {
        CGPoint localPos = [self.transformScalingNode.parent convertPoint:mousePositionInContentLayer fromNode:self.contentLayer];
        CGPoint localDownPos = [self.transformScalingNode.parent convertPoint:self.mouseDownPos fromNode:self.contentLayer];
        
        CGPoint deltaLocal = pc_CGPointSubtract(localPos, localDownPos);
        
        CGPoint deltaAnchorPoint = ({
            CGPoint deltaAnchorPoint = deltaLocal;
            
            // First rotate
            CGAffineTransform transform = CGAffineTransformIdentity;
            transform = CGAffineTransformRotate(transform, self.transformScalingNode.zRotation);
            deltaAnchorPoint = CGPointApplyAffineTransform(deltaAnchorPoint, CGAffineTransformInvert(transform));
            
            // Then scale by content size
            CGPoint sizePoint = CGPointMake(self.transformScalingNode.contentSize.width, self.transformScalingNode.contentSize.height);
            deltaAnchorPoint = CGPointMake(deltaAnchorPoint.x / sizePoint.x, deltaAnchorPoint.y / sizePoint.y);
            
            // Then scale
            transform = CGAffineTransformMakeScale(self.transformScalingNode.xScale, self.transformScalingNode.yScale);
            deltaAnchorPoint = CGPointApplyAffineTransform(deltaAnchorPoint, CGAffineTransformInvert(transform));
            
            deltaAnchorPoint;
        });
        
        CGPoint newAnchorPoint = pc_CGPointAdd(self.transformScalingNode.transformStartAnchorPoint, deltaAnchorPoint);
        
        CGPoint positionDelta = deltaLocal;
        CGPoint newPosition = pc_CGPointAdd(self.transformScalingNode.transformStartPosition, positionDelta);
        CGPoint childOffset = CGPointMake(self.transformScalingNode.contentSize.width * deltaAnchorPoint.x, self.transformScalingNode.contentSize.height * deltaAnchorPoint.y);
        
        [self.transformScalingNode setAnchorPointSafely:newAnchorPoint];
        self.transformScalingNode.position = pc_CGPointIntegral(newPosition);
        
        for (SKNode *childNode in self.transformScalingNode.children) {
            childNode.position = pc_CGPointSubtract(childNode.transformStartPosition, childOffset);
        }
        
        [self.appDelegate refreshProperty:@"anchorPoint"];
        [self.appDelegate refreshProperty:@"position"];
        [self.appDelegate saveUndoStateDidChangeProperty:@"anchorPoint"];
    }
    else if (self.isPanning) {
        CGPoint delta = pc_CGPointSubtract(mousePositionInContentLayer, self.mouseDownPos);
        self.scrollOffset = pc_CGPointAdd(self.panningStartScrollOffset, delta);
    }
    
    self.previousDragMousePos = mousePositionInContentLayer;

    return;
}

- (void)selectNodeForMouseInput:(SKNode *)node {
    [self.nodesAtSelectionPt addObject:node];
    self.currentNodeAtSelectionPtIdx = self.nodesAtSelectionPt.count - 1;
}

- (BOOL)handleKeyDown:(NSEvent *)theEvent {
    if ([theEvent modifierFlags] & NSShiftKeyMask && [theEvent modifierFlags] & NSAlternateKeyMask) {
        switch( [theEvent keyCode] ) {
            case 126:       // up arrow
                [SKNode pc_alignNodes:[AppDelegate appDelegate].selectedSpriteKitNodes withAlignment:PCAlignmentTop];
                return YES;
            case 125:       // down arrow
                [SKNode pc_alignNodes:[AppDelegate appDelegate].selectedSpriteKitNodes withAlignment:PCAlignmentBottom];
                return YES;
            case 124:       // right arrow
                [SKNode pc_alignNodes:[AppDelegate appDelegate].selectedSpriteKitNodes withAlignment:PCAlignmentRight];
                return YES;
            case 123:       // left arrow
                [SKNode pc_alignNodes:[AppDelegate appDelegate].selectedSpriteKitNodes withAlignment:PCAlignmentLeft];
                return YES;
        }
    }
    
    if ([theEvent modifierFlags] & NSShiftKeyMask) {
        switch( [theEvent keyCode] ) {
            case 126:       // up arrow
                [SKNode pc_moveNodes:[AppDelegate appDelegate].selectedSpriteKitNodes inDirection:PCMoveDirectionUp];
                return YES;
            case 125:       // down arrow
                [SKNode pc_moveNodes:[AppDelegate appDelegate].selectedSpriteKitNodes inDirection:PCMoveDirectionDown];
                return YES;
            case 124:       // right arrow
                [SKNode pc_moveNodes:[AppDelegate appDelegate].selectedSpriteKitNodes inDirection:PCMoveDirectionRight];
                return YES;
            case 123:       // left arrow
                [SKNode pc_moveNodes:[AppDelegate appDelegate].selectedSpriteKitNodes inDirection:PCMoveDirectionLeft];
                return YES;
        }
    }
    
    switch( [theEvent keyCode] ) {
        case 126:       // up arrow
            [SKNode pc_nudgeNodes:[AppDelegate appDelegate].selectedSpriteKitNodes inDirection:PCMoveDirectionUp];
            return YES;
        case 125:       // down arrow
            [SKNode pc_nudgeNodes:[AppDelegate appDelegate].selectedSpriteKitNodes inDirection:PCMoveDirectionDown];
            return YES;
        case 124:       // right arrow
            [SKNode pc_nudgeNodes:[AppDelegate appDelegate].selectedSpriteKitNodes inDirection:PCMoveDirectionRight];
            return YES;
        case 123:       // left arrow
            [SKNode pc_nudgeNodes:[AppDelegate appDelegate].selectedSpriteKitNodes inDirection:PCMoveDirectionLeft];
            return YES;
    }
    return NO;
}

- (void)makeNodeIntegral:(SKNode *)node {
    [node pc_makeFrameIntegral];
    [self.appDelegate refreshProperty:@"position"];
    [self.appDelegate refreshProperty:@"contentSize"];
    [self.appDelegate refreshProperty:@"scale"];
}

- (void)mouseUp:(NSEvent *)event {
    [self.marqueeSelectionNode removeFromParent];
    if (!self.appDelegate.hasOpenedDocument) return;

    [[PCUndoManager sharedPCUndoManager] endBatchChanges];
    CGPoint pos = [event locationInNode:self.contentLayer];

    for (SKNode *node in self.appDelegate.selectedSpriteKitNodes) {
        if ([self.appDelegate.physicsHandler mouseUp:[self.contentLayer pc_convertToWorldSpace:pos] event:event]) return;

        if (self.currentMouseTransform != kCCBTransformHandleNone) {
            if (self.currentMouseTransform == kCCBTransformHandleRotate) {
                [node updateAnimateablePropertyValue: @(node.rotation) propName:@"rotation" andCreateKeyFrameIfNone:YES withType:kCCBKeyframeTypeDegrees];
                [self.appDelegate saveUndoStateDidChangeProperty:@"rotation"];
            }
            else if (self.currentMouseTransform == kCCBTransformHandleScale
                     || self.currentMouseTransform == kCCBTransformHandleScaleX
                     || self.currentMouseTransform == kCCBTransformHandleScaleY
                     || self.currentMouseTransform == kCCBTransformHandleContentSize
                     || self.currentMouseTransform == kCCBTransformHandleContentSizeX
                     || self.currentMouseTransform == kCCBTransformHandleContentSizeY) {

                [self makeNodeIntegral:node];
                if ([node editorResizeBehaviour] == PCEditorResizeBehaviourScale) {
                    [node updateAnimateablePropertyValue:@[ @(node.xScale), @(node.yScale) ] propName:@"scale" andCreateKeyFrameIfNone:YES withType:kCCBKeyframeTypeScaleLock];
                }
                else if (self.transformScalingNode == self.rootNode) {
                    self.stageBgLayer.alpha = 1.0f;
                    [self fitStageToRootNodeIfNecessary];
                    self.transformScalingNode.position = CGPointZero;
                }
                [node updateAnimateablePropertyValue:@[ @(node.position.x), @(node.position.y) ] propName:@"position" andCreateKeyFrameIfNone:YES withType:kCCBKeyframeTypePosition];

                if (self.currentMouseTransform == kCCBTransformHandleContentSize
                    || self.currentMouseTransform == kCCBTransformHandleContentSizeX
                    || self.currentMouseTransform == kCCBTransformHandleContentSizeY) {
                    [node finishResizing];
                    [self.appDelegate saveUndoStateDidChangeProperty:@"contentSize"];
                } else {
                    [self.appDelegate saveUndoStateDidChangeProperty:@"scale"];
                }
            }
            else if (self.currentMouseTransform == kCCBTransformHandleMove) {
                [self makeNodeIntegral:node];
                [node updateAnimateablePropertyValue:@[ @(node.position.x), @(node.position.y) ] propName:@"position" andCreateKeyFrameIfNone:YES withType:kCCBKeyframeTypePosition];
                [self.appDelegate saveUndoStateDidChangeProperty:@"position"];
            }
            else if (self.currentMouseTransform == kCCBTransformHandleAnchorPoint) {
                [node.children makeObjectsPerformSelector:@selector(pc_makeFrameIntegral)];
                [self makeNodeIntegral:node];
                for (SKNode *nodeToUpdate in [node.children arrayByAddingObject:node]) {
                    CGPoint nodeTranslation = pc_CGPointSubtract(nodeToUpdate.position, nodeToUpdate.transformStartPosition);
                    [nodeToUpdate translateAllKeyframesBy:nodeTranslation];
                }

                [node updateAnimateablePropertyValue:@[ @(node.position.x), @(node.position.y) ] propName:@"position" andCreateKeyFrameIfNone:YES withType:kCCBKeyframeTypePosition];
                [self.appDelegate saveUndoStateDidChangeProperty:@"anchorPoint"];
            }
        }
    }

    if ([self.guideLayer mouseUp:[self.contentLayer pc_convertToWorldSpace:pos] event:event]) return;
    [self.snapNode mouseUp:event];

    self.isMouseTransforming = NO;

    if (self.isPanning) {
        self.currentTool = kCCBToolSelection;
        self.isPanning = NO;
    }

    if ([self.appDelegate.selectedSpriteKitNodes count] == 1) {
        SKNode *selectedNode = self.appDelegate.selectedSpriteKitNodes[0];
        if (event.clickCount == 2) {
            if (![self focusNodeIfFocusable:selectedNode]) {
                [self doubleClickNodeIfDoubleClickable:selectedNode];
            }
        }
    }

    self.currentMouseTransform = kCCBTransformHandleNone;
    return;
}

- (void)mouseMoved:(NSEvent *)event {
    if (!self.appDelegate.hasOpenedDocument) return;
    CGPoint pos = [event locationInNode:self.contentLayer];

    [self.guideLayer mouseMoved:event];

    self.mousePos = pos;
}

- (void)mouseEntered:(NSEvent *)event {
    self.mouseInside = YES;

    if (!self.appDelegate.hasOpenedDocument) return;

    [self.rulerLayer mouseEntered:event];
}

- (void)mouseExited:(NSEvent *)event {
    self.mouseInside = NO;

    if (!self.appDelegate.hasOpenedDocument) return;

    [self.rulerLayer mouseExited:event];
}

- (void)cursorUpdate:(NSEvent *)event {
    if (!self.appDelegate.hasOpenedDocument) return;
}

- (void)flagsChanged:(NSEvent *)event {
    if (!self.appDelegate.hasOpenedDocument) return;
    [self.guideLayer flagsChanged:event];

    BOOL commandKeyPressed = (NSCommandKeyMask & [NSEvent modifierFlags]) == NSCommandKeyMask;
    [self enableAnchorPoint:commandKeyPressed];

    [self enabledSnapping];
}

- (void)enabledSnapping {
    BOOL commandKeyIsDown = (NSCommandKeyMask & [NSEvent modifierFlags]) == NSCommandKeyMask ?:NO;
    self.snapNode.snappingToGuidesEnabled = [self.appDelegate guideSnappingEnabled] ^ commandKeyIsDown;
    self.snapNode.snappingToObjectsEnabled = [self.appDelegate objectSnappingEnabled] ^ commandKeyIsDown;
}

- (void)setCurrentTool:(CCBTool)currentTool {
    //First pop any non-selection tools.
    if (self.currentTool != kCCBToolSelection) {
        [NSCursor pop];
    }

    _currentTool = currentTool;

    if (_currentTool == kCCBToolGrab) {
        [[NSCursor closedHandCursor] push];
    }
    else if (_currentTool == kCCBToolAnchor) {
        NSImage *cursorImage = [NSImage imageNamed:@"select-crosshair"];
        CGPoint centerPoint = CGPointMake(cursorImage.size.width / 2, cursorImage.size.height / 2);
        NSCursor *cursor = [[NSCursor alloc] initWithImage:cursorImage hotSpot:centerPoint];
        [cursor push];
    }
    else if (_currentTool == kCCBToolRotate) {
        CGFloat rotation = atan2(self.cornerOrientation.y, self.cornerOrientation.x) - M_PI / 4.0f;
        NSImage *cursorImage = [[NSImage imageNamed:@"select-rotation"] imageRotatedByRadians:rotation];
        CGPoint centerPoint = CGPointMake(cursorImage.size.width / 2, cursorImage.size.height / 2);
        NSCursor *cursor = [[NSCursor alloc] initWithImage:cursorImage hotSpot:centerPoint];
        [cursor push];
    }
    else if (_currentTool == kCCBToolScale) {
        CGFloat rotation = atan2(self.cornerOrientation.y, self.cornerOrientation.x) + M_PI / 2.0f;
        NSImage *cursorImage = [[NSImage imageNamed:@"select-scale"] imageRotatedByRadians:rotation];
        CGPoint centerPoint = CGPointMake(cursorImage.size.width / 2, cursorImage.size.height / 2);
        NSCursor *cursor = [[NSCursor alloc] initWithImage:cursorImage hotSpot:centerPoint];
        [cursor push];
    }
    else if (_currentTool == kCCBToolTranslate) {
        NSImage *image = [NSImage imageNamed:@"select-move"];
        CGPoint centerPoint = CGPointMake(image.size.width / 2, image.size.height / 2);
        NSCursor *cursor = [[NSCursor alloc] initWithImage:image hotSpot:centerPoint];
        [cursor push];
    }
}

- (void)setScrollOffset:(CGPoint)offset {
    if (!self.appDelegate.window.isKeyWindow) return;
    if (self.isMouseTransforming || self.isPanning || self.currentMouseTransform != kCCBTransformHandleNone) return;
    if (!self.appDelegate.hasOpenedDocument) return;
    
    CGRect accumulatedFrame = [self.contentLayer calculateAccumulatedFrame];
    
    CGFloat scale = [[AppDelegate appDelegate].window backingScaleFactor];
    CGPoint maxDistanceFromContent = CGPointMake([self viewSize].width / scale - PCScrollMinimumVisibleContent.x,
                                                 [self viewSize].height / scale - PCScrollMinimumVisibleContent.y);
    CGPoint scrollOffsetAtTopCorner = pc_CGPointMultiply(CGPointMake(CGRectGetMaxX(accumulatedFrame), CGRectGetMaxY(accumulatedFrame)), -1);
    CGPoint minimumScrollOffset = pc_CGPointSubtract(scrollOffsetAtTopCorner, maxDistanceFromContent);
    CGPoint maximumScrollOffset = pc_CGPointAdd(pc_CGPointMultiply(accumulatedFrame.origin, -1), maxDistanceFromContent);
    _scrollOffset = CGPointMake(MAX(minimumScrollOffset.x, MIN(maximumScrollOffset.x, offset.x)),
                                MAX(minimumScrollOffset.y, MIN(maximumScrollOffset.y, offset.y)));
}

- (void)forceRedraw {
    [self update:0];
}

- (void)update:(NSTimeInterval)currentTime {
    // --- From http://www.raywenderlich.com/42699/spritekit-tutorial-for-beginners
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        self.lastUpdateTimeInterval = currentTime;
    }
    // --- End RW code

    // Recenter the content layer
    self.winSize = pc_CGSizeIntegral([self viewSize]);
    CGPoint stageBottomLeft = pc_CGPointIntegral(CGPointMake((self.winSize.width / 2 + self.scrollOffset.x), (self.winSize.height / 2 + self.scrollOffset.y)));

    self.size = self.winSize;

    self.stageBgLayer.position = pc_CGPointIntegral(stageBottomLeft);

    // Update selection & physics editor
    [self.selectionLayer removeAllChildren];
    [self.physicsLayer removeAllChildren];
    [[PCOverlayView overlayView].physicsHandlesView removeAllPhysicsHandles];
    if (self.appDelegate.physicsHandler.editingPhysicsBody) {
        [self.appDelegate.physicsHandler updateSpriteKitPhysicsEditor:self.physicsLayer];
    }
    else {
        [self updateSelection];
    }

    // Setup border layer
    CGRect bounds = CGRectIntegral(self.stageBgLayer.frame);

    self.borderBottom.position = CGPointZero;
    self.borderBottom.size = CGSizeMake(self.winSize.width, bounds.origin.y);

    self.borderTop.position = CGPointMake(0, bounds.size.height + bounds.origin.y);
    self.borderTop.size = CGSizeMake(self.winSize.width, self.winSize.height - bounds.size.height - bounds.origin.y);

    self.borderLeft.position = CGPointMake(0, bounds.origin.y);
    self.borderLeft.size = CGSizeMake(bounds.origin.x, bounds.size.height);

    self.borderRight.position = CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y);
    self.borderRight.size = CGSizeMake(self.winSize.width - bounds.origin.x - bounds.size.width, bounds.size.height);

    CGPoint center = pc_CGPointIntegral(CGPointMake(bounds.origin.x + bounds.size.width / 2, bounds.origin.y + bounds.size.height / 2));
    self.borderDevice.position = center;

    // Update rulers
    self.origin = pc_CGPointIntegral(pc_CGPointAdd(stageBottomLeft, pc_CGPointMultiply(self.contentLayer.position, _stageZoom)));

    [self.rulerLayer updateWithSize:self.winSize stageOrigin:self.origin zoom:_stageZoom];
    [self.rulerLayer updateMousePos:self.mousePos];

    // Update guides
    [self.guideLayer updateWithSize:self.winSize stageOrigin:self.origin zoom:_stageZoom];

    [[PCOverlayView overlayView] layout];
}

#pragma mark - Marquee

- (NSArray *)marqueeSelectNodesWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    SKNode *container = [self marqueeSelectionContainer];
    return Underscore.array(container.children).filter(^BOOL(SKNode *child) {
        return [child pc_hitTestWithWorldRect:startPoint endPoint:endPoint] && child.userSelectable;
    }).unwrap;
}

- (SKNode *)marqueeSelectionContainer {
    SKNode *container = [self.focusedNodes lastObject] ?: self.rootNode;
    container = [container childInsertionNode];
    return container;
}

- (BOOL)canStartMarqueeSelectionFromClickOnNode:(SKNode *)node {
    return node && (node == self.rootNode || [node isKindOfClass:NSClassFromString(@"PCSKMultiViewCellNode")]);
}

#pragma mark Document previews

- (void)savePreviewToFile:(NSString *)path completion:(dispatch_block_t)completion {
    CGSize thumbnailSize = [self thumbnailSize];
    CGSize previewSize = self.contentLayer.contentSize;
    NSImage *snapshotImage;
    
    // New method in 10.10
    if ([self.view respondsToSelector:@selector(textureFromNode:crop:)] && self.rootNode.visible) {
        [self hideAllNodesForPreview:YES withRootNode:self.rootNode];

        SKTexture *sceneTexture = [self captureSceneTextureAtSize:previewSize];
        if (!sceneTexture) {
            if (completion) completion();
            return;
        }
        
        if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:pc_ElCapitanOperatingSystemVersion]) {
            snapshotImage = [[NSImage alloc] initWithCGImage:sceneTexture.CGImage size:previewSize];
        } else {
        
            // This is a private method on SKTexture
            // There's currently *no* way to get an image out of SpriteKit though, so here we are
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            [sceneTexture performSelector:@selector(_savePngFromGLCache:) withObject:path];
#pragma clang diagnostic pop
            snapshotImage = [[NSImage alloc] initWithContentsOfFile:path];
        }
        
        [self hideAllNodesForPreview:NO withRootNode:self.rootNode];
    }
    
    // <= 10.9
    // Since we won't be supporting < 10.10 at launch we're just making all-white previews as a placeholder
    else {
        snapshotImage = [[NSImage alloc] initWithSize:previewSize];
        [snapshotImage lockFocus];
        [[NSColor whiteColor] drawSwatchInRect:NSMakeRect(0, 0, previewSize.width, previewSize.height)];
        [snapshotImage unlockFocus];
        [[snapshotImage PNGRepresentation] writeToFile:path atomically:NO];
    }

    NSImage *overlayImage = [[PCOverlayView overlayView] pc_snapshot];

    // Add overlay and save to full size file
    [self saveImage:snapshotImage withOverlayImage:overlayImage withSize:previewSize toPath:path completion:^{
        // Save thumbnail
        NSString *extension = [path pathExtension];
        NSString *thumbPath = [[[path stringByDeletingPathExtension] stringByAppendingString:PCSlideThumbnailSuffix] stringByAppendingPathExtension:extension];
        [self saveImage:snapshotImage withOverlayImage:overlayImage withSize:thumbnailSize toPath:thumbPath completion:completion];
    }];
}

- (SKTexture *)captureSceneTextureAtSize:(CGSize)previewSize {
    
    if (NSAppKitVersionNumber >= NSAppKitVersionNumber10_11 && NSAppKitVersionNumber <= NSAppKitVersionNumber10_11_3) {
        //`-[SKTexture textureFromNode:crop]` always returns nil as of 10.11. To work around, we just get the full texture using `-[SKTexture textureFromNode:]` and then crop it ourselves.
        SKTexture *fullTexture = [self.view textureFromNode:self.rootNode];
        CGRect accumulatedFrame = [self.rootNode calculateAccumulatedFrame];
        CGRect cropRect = CGRectMake(-accumulatedFrame.origin.x / fullTexture.size.width,
                                     -accumulatedFrame.origin.y / fullTexture.size.height,
                                     previewSize.width / fullTexture.size.width,
                                     previewSize.height / fullTexture.size.height);
        return [SKTexture textureWithRect:cropRect inTexture:fullTexture];
    } else {
        CGRect cropRect = CGRectMake(0, 0, previewSize.width, previewSize.height);
        return [self.view textureFromNode:self.rootNode crop:cropRect];
    }

}

- (void)saveImage:(NSImage *)image withOverlayImage:(NSImage *)overlayImage withSize:(CGSize)size toPath:(NSString *)path completion:(dispatch_block_t)completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGImageRef imageRef = [image CGImageForProposedRect:NULL context:[NSGraphicsContext currentContext] hints:nil];
        CGImageRef overlayImageRef = [overlayImage CGImageForProposedRect:NULL context:[NSGraphicsContext currentContext] hints:nil];
        // Create image
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), imageRef);
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), overlayImageRef);
        CGImageRef finalImageRef = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);

        // Save file
        CFURLRef URL = (__bridge CFURLRef)[NSURL fileURLWithPath:path];
        CGImageDestinationRef destinationRef = CGImageDestinationCreateWithURL(URL, kUTTypePNG, 1, NULL);
        CGImageDestinationAddImage(destinationRef, finalImageRef, nil);
        CGImageDestinationFinalize(destinationRef);
        CFRelease(destinationRef);
        CGImageRelease(finalImageRef);

        if (completion) {
            dispatch_async(dispatch_get_main_queue(), completion);
        }
    });
}

- (void)hideAllNodesForPreview:(BOOL)shouldHide withRootNode:(SKNode *)node {
    if ([node conformsToProtocol:@protocol(PCCustomPreviewNode)]) {
        id<PCCustomPreviewNode> customPreviewNode = (id<PCCustomPreviewNode>)node;
        if (shouldHide) {
            [customPreviewNode previewWillBegin];
        } else {
            [customPreviewNode previewDidFinish];
        }
    }
    
    for (SKNode *child in node.children) {
        [self hideAllNodesForPreview:shouldHide withRootNode:child];
    }
}

- (CGSize)thumbnailSize {
    PCDeviceTargetType deviceTarget = self.appDelegate.currentProjectSettings.deviceResolutionSettings.deviceTarget;
    PCDeviceTargetOrientation orientation = self.appDelegate.currentProjectSettings.deviceResolutionSettings.deviceOrientation;

    switch (deviceTarget) {
        case PCDeviceTargetTypePhone:
            if (orientation == PCDeviceTargetOrientationPortrait) {
                return CGSizeMake(207, 368);
            } else {
                return CGSizeMake(368, 207);
            }
        case PCDeviceTargetTypeTablet:
        default:
            if (orientation == PCDeviceTargetOrientationPortrait) {
                return CGSizeMake(300, 400);
            } else {
                return CGSizeMake(400, 300);
            }
    }
}

#pragma mark - Focus

- (BOOL)focusNodeIfFocusable:(SKNode *)node {
    if (![node conformsToProtocol:@protocol(PCFocusableNode)]) return NO;

    [self focusNode:(id)node];
    return YES;
}

- (void)focusNode:(SKNode <PCFocusableNode>*)node {
    while ([self.focusedNodes count] > 0 && ![node hasParent:[self.focusedNodes lastObject]]) {
        [self popFocusedNode];
    }
    
    SKNode<PCFocusableNode> *oldFocusedNode = [self.focusedNodes lastObject];
    if ([oldFocusedNode respondsToSelector:@selector(setMainFocus:)]) [oldFocusedNode setMainFocus:NO];
    
    [self.focusedNodes addObject:node];
    [node focus];
    if ([node respondsToSelector:@selector(setEndFocusHandler:)]) {
        __weak typeof(self) _self = self;
        [node setEndFocusHandler:^{
            [_self popFocusedNode];
        }];
    }
}

- (void)popFocusedNode {
    SKNode <PCFocusableNode>*node = [self.focusedNodes lastObject];
    if ([node respondsToSelector:@selector(setEndFocusHandler:)]) {
        [node setEndFocusHandler:nil];
    }
    [node endFocus];
    [self.focusedNodes removeLastObject];
    
    node = [self.focusedNodes lastObject];
    if ([node respondsToSelector:@selector(setMainFocus:)]) [node setMainFocus:YES];
}

- (void)endFocusedNode {
    while ([[self focusedNodes] count] > 0) {
        [self popFocusedNode];
    }
}

- (void)conditionallyEndFocusedNodeBasedOnSelectedNodes:(NSArray *)nodes {
    if (PCIsEmpty(nodes)) {
        [self endFocusedNode];
        return;
    }
    while ([[self.focusedNodes lastObject] selectionOfNodesShouldEndFocus:nodes]) {
        [self popFocusedNode];
    }
}

#pragma mark - Double Click

- (void)doubleClickNodeIfDoubleClickable:(SKNode *)node {
    if ([node conformsToProtocol:@protocol(PCDoubleClickableNode)]) {
        [(SKNode<PCDoubleClickableNode>*)node nodeReceivedDoubleClick];
    }
}

#pragma mark - Nodes

- (NSArray *)allNodesOfClass:(Class)klass {
    return [[self rootNode] recursiveChildrenOfClass:klass];
}

#pragma mark Debug

- (CGRect)stageUIFrame {
    SKNode *node = self.stageBgLayer;
    CGPoint origin = [self convertPoint:node.frame.origin fromNode:node.parent];
    CGPoint sizePoint = [self convertPoint:CGPointMake(node.frame.size.width, node.frame.size.height) fromNode:node.parent];
    origin = [self convertToViewSpace:origin];
    sizePoint = [self convertToViewSpace:sizePoint];
    return CGRectIntegral((CGRect){ origin, CGSizeMake(sizePoint.x, sizePoint.y) });
}

#pragma mark - PCResourceManagerObserver

- (void)resourceListUpdated {
    [self.contentLayer.allNodes makeObjectsPerformSelector:@selector(showMissingResourceImageIfResourceMissing)];
}

@end
