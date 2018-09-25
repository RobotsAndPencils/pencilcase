//
//  PCSKShapeNode.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-14.
//
//

#import "PCSKShapeNode.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+LifeCycle.h"
#import "SKNode+NodeInfo.h"
#import "NSColor+PCColors.h"

static NSString * const PCSKShapeNodeParameterFill = @"fill";
static NSString * const PCSKShapeNodeParameterStroke = @"stroke";
static NSString * const PCSKShapeNodeParameterFillColor = @"fillColor";
static NSString * const PCSKShapeNodeParameterStrokeColor = @"strokeColor";
static NSString * const PCSKShapeNodeParameterStrokeWidth = @"strokeWidth";
static NSString * const PCSKShapeNodeParameterShapeType = @"shapeType";

static NSString * const PCSKShapeNodeParametersKey = @"parameters";
static NSString * const PCSKShapeNodeInfoKey = @"shapeInfo";

@interface PCSKShapeNode ()

@property (strong, nonatomic) PCView *container;
@property (strong, nonatomic) PCShapeView *shapeView;

@property (assign, nonatomic) PCShapeType shapeType;
@property (assign, nonatomic) CGFloat strokeWidth;
@property (assign, nonatomic) BOOL stroke;
@property (assign, nonatomic) BOOL fill;
@property (strong, nonatomic) NSColor *strokeColor;
@property (strong, nonatomic) NSColor *fillColor;

@property (readonly, nonatomic) NSMutableDictionary *shapeParameters;

@end

@implementation PCSKShapeNode

- (instancetype)init {
    self = [super init];
    if (self) {
        NSRect startFrame = NSMakeRect(0, 0, 100, 100);
        _container = [[PCView alloc] initWithFrame:startFrame];
        
        _shapeView = [[PCShapeView alloc] initWithFrame:_container.bounds];
        _shapeView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
        _shapeView.wantsLayer = YES;
        
        [_container addSubview:_shapeView];
        
        self.shapeView.shapeType = PCShapeEllipse;
    }
    return self;
}

- (BOOL)canParticipateInPhysics {
    return YES;
}

- (PCEditorResizeBehaviour)editorResizeBehaviour {
    return PCEditorResizeBehaviourContentSize;
}

#pragma mark Life Cycle

- (void)pc_didEnterScene {
    [super pc_didEnterScene];
    [[PCOverlayView overlayView] addTrackingNode:self];
}


- (void)pc_willExitScene {
    [super pc_willExitScene];
    [[PCOverlayView overlayView] removeTrackingNode:self];
}

#pragma mark - Properties

- (PCShapeType)shapeType {
    return [self.shapeParameters[PCSKShapeNodeParameterShapeType] intValue];
}

- (void)setShapeType:(PCShapeType)shapeType {
    self.shapeParameters[PCSKShapeNodeParameterShapeType] = @(shapeType);
}

- (CGFloat)strokeWidth {
    return [self.shapeParameters[PCSKShapeNodeParameterStrokeWidth] intValue];
}

- (void)setStrokeWidth:(CGFloat)strokeWidth {
    self.shapeParameters[PCSKShapeNodeParameterStrokeWidth] = @(strokeWidth);
}

- (BOOL)stroke {
    return [self.shapeParameters[PCSKShapeNodeParameterStroke] boolValue];
}

- (void)setStroke:(BOOL)stroke {
    self.shapeParameters[PCSKShapeNodeParameterStroke] = @(stroke);
}

- (BOOL)fill {
    return [self.shapeParameters[PCSKShapeNodeParameterFill] boolValue];
}

- (void)setFill:(BOOL)fill {
    self.shapeParameters[PCSKShapeNodeParameterFill] = @(fill);
}

- (NSColor *)strokeColor {
    return [NSColor pc_colorFromArray:self.shapeParameters[PCSKShapeNodeParameterStrokeColor]];
}

- (void)setStrokeColor:(NSColor *)strokeColor {
    self.shapeParameters[PCSKShapeNodeParameterStrokeColor] = [strokeColor pc_convertToArray];
}

- (NSColor *)fillColor {
    return [NSColor pc_colorFromArray:self.shapeParameters[PCSKShapeNodeParameterFillColor]];
}

- (void)setFillColor:(NSColor *)fillColor {
    self.shapeParameters[PCSKShapeNodeParameterFillColor] = [fillColor pc_convertToArray];
}

- (NSMutableDictionary *)shapeInfo {
    return [self extraPropForKey:PCSKShapeNodeInfoKey];
}

- (void)setShapeInfo:(NSMutableDictionary *)shapeInfo {
    shapeInfo = [shapeInfo mutableCopy];
    shapeInfo[PCSKShapeNodeParametersKey] = [shapeInfo[PCSKShapeNodeParametersKey] mutableCopy];

    [self setExtraProp:shapeInfo forKey:PCSKShapeNodeInfoKey];
    [self setShapeValues];
}

- (NSMutableDictionary *)shapeParameters {
    return [self extraPropForKey:PCSKShapeNodeInfoKey][PCSKShapeNodeParametersKey];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    [self.container setHidden:hidden];
}

- (void)setOpacity:(CGFloat)opacity {
    [super setOpacity:opacity];
    self.container.alphaValue = opacity;
}

#pragma mark - Private

- (void)setShapeValues {
    self.shapeView.shapeType = self.shapeType;
    self.shapeView.fill = self.fill;
    self.shapeView.stroke = self.stroke;
    self.shapeView.strokeWidth = self.shapeView.stroke ? self.strokeWidth : 0;
    if (self.strokeColor) {
        self.shapeView.strokeColor = self.strokeColor;
    }
    if (self.fillColor) {
        self.shapeView.fillColor = self.fillColor;
    }
    [self.shapeView setNeedsDisplay:YES];
}

#pragma customShapePhysicsBody

- (void)setDefaultPhysicsBodyParametersOn:(NodePhysicsBody *)nodePhysicsBody {
    switch (self.shapeView.shapeType) {
        case PCShapeEllipse:
            [self configureCirclePhysicsBody:nodePhysicsBody];
            break;
        case PCShapeTriangle:
            [self configureTrianglePhysicsBody:nodePhysicsBody];
            break;
        case PCShapeRoundedRectangle:
        default:
            [self configureRectanglePhysicsBody:nodePhysicsBody];
            break;
    }
}

- (void)configureCirclePhysicsBody:(NodePhysicsBody *)nodePhysicsBody {
    [nodePhysicsBody setupDefaultCircleForSpriteKitNode:self];
}

- (void)configureTrianglePhysicsBody:(NodePhysicsBody *)nodePhysicsBody {
    nodePhysicsBody.bodyShape = PCPhysicsBodyShapePolygon;
    nodePhysicsBody.radius = 0;
    
    CGFloat width = self.contentSize.width;
    CGFloat height = self.contentSize.height;
    width = MAX(width, 32);
    height = MAX(height, 32);
    
    CGPoint bottomLeft = CGPointMake(0, 0);
    CGPoint top = CGPointMake(width * 0.5, height);
    CGPoint bottomRight = CGPointMake(width, 0);
    
    nodePhysicsBody.points = @[
                               [NSValue valueWithPoint:bottomLeft],
                               [NSValue valueWithPoint:top],
                               [NSValue valueWithPoint:bottomRight]
                               ];
}

-(void)configureRectanglePhysicsBody:(NodePhysicsBody *)nodePhysicsBody {
    nodePhysicsBody.bodyShape = PCPhysicsBodyShapePolygon;
    nodePhysicsBody.radius = 0;
    
    CGFloat width = self.contentSize.width;
    CGFloat height = self.contentSize.height;
    width = MAX(width, 32);
    height = MAX(height, 32);
    
    CGPoint bottomLeft = CGPointMake(0, 0);
    CGPoint topLeft = CGPointMake(0, height);
    CGPoint topRight = CGPointMake(width, height);
    CGPoint bottomRight = CGPointMake(width, 0);
    
    nodePhysicsBody.points = @[
                              [NSValue valueWithPoint:bottomLeft],
                              [NSValue valueWithPoint:topLeft],
                              [NSValue valueWithPoint:topRight],
                              [NSValue valueWithPoint:bottomRight],
                              ];
}

#pragma mark - PCOverlayNode

- (NSView<PCOverlayTrackingView> *)trackingView {
    return self.container;
}

- (void)viewUpdated:(BOOL)frameChanged {
    if (frameChanged) {
        [self setShapeValues];
        self.shapeView.frame = CGRectMake(0, 0, CGRectGetWidth(self.container.frame), CGRectGetHeight(self.container.frame));
    }
}

@end
