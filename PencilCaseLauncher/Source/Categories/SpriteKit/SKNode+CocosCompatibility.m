//
//  SKNode+CocosCompatability.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-18.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "SKNode+CocosCompatibility.h"
#import <objc/runtime.h>

@implementation SKNode (CocosCompatability)

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

- (id)userObject {
    return objc_getAssociatedObject(self, @selector(userObject));
}

- (void)setUserObject:(id)userObject {
    objc_setAssociatedObject(self, @selector(userObject), userObject, OBJC_ASSOCIATION_RETAIN);
}

- (void)setContentSize:(CGSize)contentSize {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") && (self.xScale < 0 || self.yScale < 0)) {
        self.size = contentSize;
    }
    else {
        self.size = CGSizeMake(contentSize.width * (self.xScale ?: 1), contentSize.height * (self.yScale ?: 1));
    }
}

- (CGSize)contentSize {
    return CGSizeMake(self.size.width / (self.xScale ?: 1), self.size.height / (self.yScale ?: 1));
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

@end
