//
//  SKNode(CocosCompatibility) 
//  SpriteBuilder
//
//  Created by brandon on 14-06-12.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "SKNode+CocosCompatibility.h"
#import "SKNode+JavaScript.h"
#import "SKNode+NodeInfo.h"
#import "NodePhysicsBody.h"
#import "PCStageScene.h"
#import "PCMathUtilities.h"

static  NSString *const PCInternalContentSizeKey = @"PCInternalContentSize";

@implementation SKNode (CocosCompatibility)

#pragma mark Properties

- (CGFloat)opacity {
    return self.alpha;
}

- (void)setOpacity:(CGFloat)opacity {
    self.alpha = opacity;
}

- (BOOL)visible {
    return !self.hidden;
}

- (void)setVisible:(BOOL)visible {
    self.hidden = !visible;
}

- (CGFloat)scaleX {
    return self.xScale;
}

- (void)setScaleX:(CGFloat)scaleX {
    self.xScale = scaleX;
}

- (CGFloat)scaleY {
    return self.yScale;
}

- (void)setScaleY:(CGFloat)scaleY {
    self.yScale = scaleY;
}

- (CGFloat)rotation {
    return RADIANS_TO_DEGREES(self.zRotation);
}

- (void)setRotation:(CGFloat)rotation {
    self.zRotation = DEGREES_TO_RADIANS(rotation);
}

- (CGFloat)skewX {
    return 0;
}

- (void)setSkewX:(CGFloat)skewX {
}

- (CGFloat)skewY {
    return 0;
}

- (void)setSkewY:(CGFloat)skewY {
}

- (void)setUserObject:(id)userObject {
    if (!self.userData) {
        self.userData = [NSMutableDictionary dictionary];
    }
    if (!userObject) {
        [self.userData removeObjectForKey:@"userObject"];
        return;
    }
    self.userData[@"userObject"] = userObject;
}

- (id)userObject {
    if (!self.userData) {
        self.userData = [NSMutableDictionary dictionary];
    }
    return self.userData[@"userObject"];
}

- (void)setContentSize:(CGSize)contentSize {
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:pc_ElCapitanOperatingSystemVersion] && (self.xScale < 0 || self.yScale < 0)) {
        self.size = contentSize;
    } else {
        self.size = CGSizeMake(contentSize.width * (self.xScale ?: 1), contentSize.height * (self.yScale ?: 1));
    }

    if (self.xScale != 0 && self.yScale != 0) {
        [self setExtraProp:[NSValue valueWithSize:contentSize] forKey:PCInternalContentSizeKey];
    }
}

- (CGSize)contentSize {
    return CGSizeMake(self.xScale != 0 ? fabs(self.size.width / self.xScale) : [[self extraPropForKey:PCInternalContentSizeKey] sizeValue].width,
                      self.yScale != 0 ? fabs(self.size.height / self.yScale) : [[self extraPropForKey:PCInternalContentSizeKey] sizeValue].height);
}

- (BOOL)seqExpanded {
    return [self.userData[@"seqExpanded"] boolValue];
}

- (void)setSeqExpanded:(BOOL)seqExpanded {
    self.userData[@"seqExpanded"] = @(seqExpanded);
}

- (NSMutableArray *)customProperties {
    return self.userData[@"customProperties"];
}

- (void)setCustomProperties:(NSMutableArray *)customProperties {
    if (!customProperties) {
        [self.userData removeObjectForKey:@"customProperties"];
        return;
    }
    self.userData[@"customProperties"] = customProperties;
}

- (BOOL)usesFlashSkew {
    return [self.userData[@"usesFlashSkew"] boolValue];
}

- (void)setUsesFlashSkew:(BOOL)usesFlashSkew {
    self.userData[@"usesFlashSkew"] = @(usesFlashSkew);
}

- (NSDictionary *)buildIn {
    return self.userData[@"buildIn"];
}

- (void)setBuildIn:(NSDictionary *)buildIn {
    if (!buildIn) {
        [self.userData removeObjectForKey:@"buildIn"];
        return;
    }
    self.userData[@"buildIn"] = buildIn;
}

- (NSDictionary *)buildOut {
    return self.userData[@"buildOut"];
}

- (void)setBuildOut:(NSDictionary *)buildOut {
    self.userData[@"buildOut"] = buildOut;
}

- (BOOL)canParticipateInPhysics {
    // Default, subclasses override
    return YES;
}

- (CGPoint)transformStartPosition {
    return [self.userData[@"transformStartPosition"] pointValue];
}

- (void)setTransformStartPosition:(CGPoint)transformStartPosition {
    self.userData[@"transformStartPosition"] = [NSValue valueWithPoint:transformStartPosition];
}

- (BOOL)shouldDisableProperty:(NSString *)prop {
    // Disable properties on root node
    if (self == [PCStageScene scene].rootNode) {
        if ([prop isEqualToString:@"position"]) return YES;
        else if ([prop isEqualToString:@"scale"]) return YES;
        else if ([prop isEqualToString:@"rotation"]) return YES;
        else if ([prop isEqualToString:@"tag"]) return YES;
        else if ([prop isEqualToString:@"visible"]) return YES;
        else if ([prop isEqualToString:@"skew"]) return YES;
    }
    
    // Disable position property for nodes handled by layouts
    return NO;
}

- (PCEditorResizeBehaviour)editorResizeBehaviour {
    return PCEditorResizeBehaviourScale;
}

- (NSString *)propertyNameForResizeBehaviour {
    switch ([self editorResizeBehaviour]) {
        case PCEditorResizeBehaviourScale:
            return @"scale";
            break;
        case PCEditorResizeBehaviourContentSize:
            return @"contentSize";
            break;
    }
}

- (void)deselect {
    // Override in subclass
}

- (void)doubleClick:(NSEvent *)theEvent {
    // Override in subclass
}

// anchorPoint and size are usually (always?) implemented in SKNode subclasses, but not SKNode itself.
// I'm not really sure why this is, other than really being picky about whether it should have these properties
// e.g. it still has a frame, despite not having these properties
// Implementing these here allows us to always be able to call - [SKNode size] and have it work without needing to check if the node,
// which may or not be be a subclass, will implement it

- (CGPoint)anchorPoint {
    return CGPointMake(0.5, 0.5);
}

- (void)setAnchorPoint:(CGPoint)anchorPoint {
    return;
}

- (CGSize)size {
    return CGSizeZero;
}

- (void)setSize:(CGSize)size {
    return;
}

- (BOOL)flipX {
    return NO;
}

- (BOOL)flipY {
    return NO;
}

- (SKTexture *)spriteFrame {
    return self.userData[@"spriteFrame"];
}

- (void)setSpriteFrame:(SKTexture *)spriteFrame {
    if (!spriteFrame) {
        [self.userData removeObjectForKey:@"spriteFrame"];
        return;
    }
    self.userData[@"spriteFrame"] = spriteFrame;
}

@end
