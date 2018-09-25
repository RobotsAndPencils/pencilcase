//
//  PCPhysicsWrapperNode.m
//  
//
//  Created by Stephen Gazzard on 2015-02-03.
//
//

#import "PCPhysicsWrapperNode.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+LifeCycle.h"
#import "SKNode+PhysicsExport.h"
#import "PCScene.h"
#import "SKPhysicsBody+State.h"
#import "SKNode+PhysicsBody.h"

CGFloat const PCPhysicsWrapperChangeTolerance = 0.01;

@interface PCPhysicsWrapperNode()

@property (weak, nonatomic, readwrite) SKNode *controlledNode;
@property (strong, nonatomic) PCPhysicsBodyParameters *physicsBodyParameters;
@property (assign, nonatomic) CGSize originalSize;

@end

@implementation PCPhysicsWrapperNode

- (id)initWithNode:(SKNode *)node physicsBodyParameters:(PCPhysicsBodyParameters *)physicsBodyParameters {
    CGSize size = CGSizeMake(ABS(node.size.width), ABS(node.size.height));
    if (!(self = [super initWithColor:[UIColor clearColor] size:size])) return nil;

    _enabled = YES;
    
    self.originalSize = self.size;
    self.controlledNode = node;
    self.controlledNode.pc_physicsWrapperNode = self;
    self.physicsBodyParameters = physicsBodyParameters;

    [self setupInitialNodeState];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFromNodeState) name:PCDidEvaluateActionsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateControlledNode) name:PCDidSimulatePhysicsNotification object:nil];

    return self;
}

- (void)dealloc {
    self.controlledNode.pc_proxiedPhysicsBody = nil;
    self.controlledNode.pc_physicsWrapperNode = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)pc_willExitScene {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupInitialNodeState {
    self.opacity = 0;
    self.name = [NSString stringWithFormat:@"%@-PhysicsWrapper", self.controlledNode.name];
    self.anchorPoint = [self wrapperAnchorPoint];
    self.position = [self calculateWrapperPosition];
    self.rotation = self.controlledNode.rotation;
    self.texture = [self.controlledNode pc_textureForPhysicsBody];
    self.physicsBody = [self.physicsBodyParameters createPhysicsBodyForNode:self];
    self.allowsUserDragging = self.physicsBodyParameters.allowsUserDragging;
}

- (void)updateFromNodeState {
    self.position = [self calculateWrapperPosition];
    self.rotation = self.controlledNode.rotation;

    if ([self anchorPointChanged]) {
        self.anchorPoint = [self wrapperAnchorPoint];
        self.position = [self calculateWrapperPosition];
        [self updatePhysicsBody];
    }

    if ([self sizeChanged]) {
        self.xScale = fabsf(self.controlledNode.size.width / self.originalSize.width);
        self.yScale = fabsf(self.controlledNode.size.height / self.originalSize.height);
        self.anchorPoint = [self wrapperAnchorPoint];
        self.position = [self calculateWrapperPosition];
        [self updatePhysicsBody];
    }

    if (self.physicsBodyParameters.bodyShape == 2) {
        SKTexture *texture = [self.controlledNode pc_textureForPhysicsBody];
        if (texture != self.texture) {
            self.texture = texture;
            [self updatePhysicsBody];
        }
    }
}

- (BOOL)sizeChanged {
    return (ABS(self.size.width - self.controlledNode.size.width) >= PCPhysicsWrapperChangeTolerance
            || ABS(self.size.height - self.controlledNode.size.height) >= PCPhysicsWrapperChangeTolerance);
}

- (BOOL)anchorPointChanged {
    CGPoint wrapperAnchorPoint = [self wrapperAnchorPoint];
    return (ABS(self.anchorPoint.x - wrapperAnchorPoint.x) >= PCPhysicsWrapperChangeTolerance
            || ABS(self.anchorPoint.y - wrapperAnchorPoint.y) >= PCPhysicsWrapperChangeTolerance);
}

- (CGPoint)wrapperAnchorPoint {
    if (self.physicsBodyParameters.bodyShape == 2) return CGPointMake(0.5, 0.5);

    return CGPointMake(self.controlledNode.xScale >= 0 ? self.controlledNode.anchorPoint.x : 1 - self.controlledNode.anchorPoint.x,
                                      self.controlledNode.yScale >= 0 ? self.controlledNode.anchorPoint.y : 1 - self.controlledNode.anchorPoint.y);
}

/** Convert our controlled nodes position to our equivalent. See Stephen math:
 Node -> Wrapper
 node position + (wrapper anchor - node anchor) * size
                [ ---------- rotate this --------------]
 */
- (CGPoint)calculateWrapperPosition {
    CGPoint position = pc_CGPointSubtract(self.anchorPoint, self.controlledNode.anchorPoint);
    position = pc_CGPointMultiplyByPoint(position, CGPointMake(self.size.width, self.size.height));
    position = CGPointApplyAffineTransform(position, CGAffineTransformMakeRotation(self.zRotation));
    position = pc_CGPointAdd(position, self.controlledNode.position);
    return position;
}

/** Convert our position to our controlled nodes equivalent. See Stephen math:
 Wrapper -> Node
 wrapper position + (node anchor - wrapper anchor) * size
                    [ ----------- rotate this -----------]
 */
- (CGPoint)calculateNodePosition {
    CGPoint position = pc_CGPointSubtract(self.controlledNode.anchorPoint, self.anchorPoint);
    position = pc_CGPointMultiplyByPoint(position, CGPointMake(self.size.width, self.size.height));
    position = CGPointApplyAffineTransform(position, CGAffineTransformMakeRotation(self.zRotation));
    position = pc_CGPointAdd(position, self.position);
    return position;
}

- (void)updateControlledNode {
    self.controlledNode.position = [self calculateNodePosition];
    self.controlledNode.rotation = self.rotation;
}

- (void)updatePhysicsBody {
    SKPhysicsBody *newPhysicsBody = [self.physicsBodyParameters createPhysicsBodyForNode:self];
    [SKPhysicsBody copyStateFrom:self.physicsBody to:newPhysicsBody];
    self.physicsBody = newPhysicsBody;
}

- (SKTexture *)pc_textureForPhysicsBody {
    return self.texture;
}

#pragma mark - Properties

- (void)setPhysicsBody:(SKPhysicsBody *)physicsBody {
    [super setPhysicsBody:physicsBody];
    self.controlledNode.pc_proxiedPhysicsBody = physicsBody;
}

- (void)setEnabled:(BOOL)enabled {
    if (_enabled == enabled) return;

    _enabled = enabled;

    if (_enabled) {
        [self setupInitialNodeState];
    }
    else {
        self.physicsBody = nil;
    }
}

@end
