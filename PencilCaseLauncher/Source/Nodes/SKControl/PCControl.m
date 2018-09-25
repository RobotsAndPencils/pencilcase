//
//  PCControl.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-22.
//
//

#import "PCControl.h"
#import "PCControlSubclass.h"
#import <objc/message.h>
#import "PCScene.h"

#import "SKNode+LifeCycle.h"
#import "SKNode+HitTest.h"
#import "SKNode+GeneralHelpers.h"
#import "PCJSContext.h"

@interface PCControl () <PCUpdateNode>

@property (assign, nonatomic) BOOL needsLayout;

@end

@implementation PCControl

#pragma mark Initializers

- (id)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

#pragma mark Action handling

- (void)setTarget:(id)target selector:(SEL)selector {
    __weak typeof(target) weakTarget = target;
    [self setBlock:^(id sender) {
        void (*objc_msgSendTyped)(id self, SEL _cmd, id argument) = (void *)objc_msgSend;
        objc_msgSendTyped(weakTarget, selector, sender);
    }];
}

- (void)triggerAction {
    if (!self.enabled) return;
    if (_block) _block(self);
}

#pragma mark Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchBegan:touches.anyObject withEvent:event];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchMoved:touches.anyObject withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchEnded:touches.anyObject withEvent:event];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchCancelled:touches.anyObject withEvent:event];
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    _tracking = YES;
    _touchInside = YES;

    [self touchEntered:touch withEvent:event];
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    if ([self hitTestWithWorldPoint:[touch locationInNode:self.pc_scene]]) {
        if (!_touchInside) {
            [self touchEntered:touch withEvent:event];
            _touchInside = YES;
        }
    } else {
        if (_touchInside) {
            [self touchExited:touch withEvent:event];
            _touchInside = NO;
        }
    }
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if (_touchInside) {
        [self touchUpInside:touch withEvent:event];
    } else {
        [self touchUpOutside:touch withEvent:event];
    }

    _touchInside = NO;
    _tracking = NO;
}

- (void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    if (_touchInside) {
        [self touchUpOutside:touch withEvent:event];
        [self touchExited:touch withEvent:event];
    }

    _touchInside = NO;
    _tracking = NO;
}

- (void)touchEntered:(UITouch *)touch withEvent:(UIEvent *)event {}

- (void)touchExited:(UITouch *)touch withEvent:(UIEvent *)event {}

- (void)touchUpInside:(UITouch *)touch withEvent:(UIEvent *)event {}

- (void)touchUpOutside:(UITouch *)touch withEvent:(UIEvent *)event {}

#pragma mark State properties

- (BOOL)enabled {
    return !(_state & PCControlStateDisabled);
}

- (void)setEnabled:(BOOL)enabled {
    if (self.enabled == enabled)
        return;

    BOOL disabled = !enabled;

    if (disabled) {
        _state |= PCControlStateDisabled;
    } else {
        _state &= ~PCControlStateDisabled;
    }

    [self stateChanged];
}

- (BOOL)selected {
    if (_state & PCControlStateSelected)
        return YES;
    else
        return NO;
}

- (void)setSelected:(BOOL)selected {
    if (self.selected == selected)
        return;

    if (selected) {
        _state |= PCControlStateSelected;
    } else {
        _state &= ~PCControlStateSelected;
    }

    [self stateChanged];
}

- (BOOL)highlighted {
    if (_state & PCControlStateHighlighted)
        return YES;
    else
        return NO;
}

- (void)setHighlighted:(BOOL)highlighted {
    if (self.highlighted == highlighted)
        return;

    if (highlighted) {
        _state |= PCControlStateHighlighted;
    } else {
        _state &= ~PCControlStateHighlighted;
    }

    [self stateChanged];
}

#pragma mark Layout and state changes

- (void)layout {
    self.needsLayout = NO;
}

- (void)setNeedsLayout {
    self.needsLayout = YES;
}

- (void)stateChanged {
    [self setNeedsLayout];
}

- (void)pc_didMoveToParent {
    [self setNeedsLayout];
    [super pc_didMoveToParent];
}

- (void)pc_didEnterScene {
    [super pc_didEnterScene];
    [self.pc_PCScene registerForUpdates:self];
    [self layout];
}

- (void)pc_willExitScene {
    [super pc_willExitScene];
    [self.pc_PCScene unregisterForUpdates:self];
}

- (void)setPreferredSize:(CGSize)preferredSize {
    _preferredSize = preferredSize;
    [self setNeedsLayout];
}

- (void)setMaxSize:(CGSize)maxSize {
    _maxSize = maxSize;
    [self setNeedsLayout];
}

- (void)setAnchorPoint:(CGPoint)anchorPoint {
    [super setAnchorPoint:anchorPoint];
    [self setNeedsLayout];
}

#pragma mark Setting properties for control states by name

- (PCControlState)controlStateFromString:(NSString *)stateName {
    PCControlState state = PCControlStateNormal;
    if ([stateName isEqualToString:@"Normal"])
        state = PCControlStateNormal;
    else if ([stateName isEqualToString:@"Highlighted"])
        state = PCControlStateHighlighted;
    else if ([stateName isEqualToString:@"Disabled"])
        state = PCControlStateDisabled;
    else if ([stateName isEqualToString:@"Selected"])
        state = PCControlStateSelected;

    return state;
}

- (void)setValue:(id)value forKey:(NSString *)key state:(PCControlState)state {
}

- (id)valueForKey:(NSString *)key state:(PCControlState)state {
    return nil;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    NSRange separatorRange = [key rangeOfString:@"|"];
    NSUInteger separatorLoc = separatorRange.location;

    if (separatorLoc == NSNotFound) {
        [super setValue:value forKey:key];
        return;
    }

    NSString *propName = [key substringToIndex:separatorLoc];
    NSString *stateName = [key substringFromIndex:separatorLoc + 1];

    PCControlState state = [self controlStateFromString:stateName];

    [self setValue:value forKey:propName state:state];
}

- (id)valueForKey:(NSString *)key {
    NSRange separatorRange = [key rangeOfString:@"|"];
    NSUInteger separatorLoc = separatorRange.location;

    if (separatorLoc == NSNotFound) {
        return [super valueForKey:key];
    }

    NSString *propName = [key substringToIndex:separatorLoc];
    NSString *stateName = [key substringFromIndex:separatorLoc + 1];

    PCControlState state = [self controlStateFromString:stateName];

    return [self valueForKey:propName state:state];
}

#pragma mark - PCUpdateNode

- (void)update:(NSTimeInterval)timeInterval {
    if (self.needsLayout) {
        [self layout];
        self.needsLayout = NO;
    }
}

@end
