//
//  CCSKControl.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-22.
//
//

#import "SKControl.h"
#import "SKControlSubclass.h"
#import <objc/message.h>

#import "SKNode+CocosCompatibility.h"
#import "SKNode+LifeCycle.h"
#import "SKNode+HitTest.h"
#import "SKNode+CoordinateConversion.h"

@interface SKControl ()

@property (assign, nonatomic) BOOL needsLayout;

@end

@implementation SKControl

#pragma mark Initializers

- (id)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        self.preferredSize = PCPreferredSizeUnset;
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
    if (self.enabled && _block) {
        _block(self);
    }
}

#pragma mark Touch handling

- (void)mouseDown:(NSEvent *)event {
    _tracking = YES;
    _touchInside = YES;

    [self mouseDownEntered:event];
}

- (void)mouseDragged:(NSEvent *)event {
    if ([self pc_hitTestWithWorldPoint:[event locationInNode:self.scene]]) {
        if (!_touchInside) {
            [self mouseDownEntered:event];
            _touchInside = YES;
        }
    } else {
        if (_touchInside) {
            [self mouseDownExited:event];
            _touchInside = NO;
        }
    }
}

- (void)mouseUp:(NSEvent *)event {
    if (_touchInside) {
        [self mouseUpInside:event];
    } else {
        [self mouseUpOutside:event];
    }

    _touchInside = NO;
    _tracking = NO;
}

- (void)mouseDownEntered:(NSEvent *)event {
}

- (void)mouseDownExited:(NSEvent *)event {
}

- (void)mouseUpInside:(NSEvent *)event {
}

- (void)mouseUpOutside:(NSEvent *)event {
}

#pragma mark State properties

- (BOOL)enabled {
    if (!(_state & SKControlStateDisabled))
        return YES;
    else
        return NO;
}

- (void)setEnabled:(BOOL)enabled {
    if (self.enabled == enabled)
        return;

    BOOL disabled = !enabled;

    if (disabled) {
        _state |= SKControlStateDisabled;
    } else {
        _state &= ~SKControlStateDisabled;
    }

    [self stateChanged];
}

- (BOOL)selected {
    if (_state & SKControlStateSelected)
        return YES;
    else
        return NO;
}

- (void)setSelected:(BOOL)selected {
    if (self.selected == selected)
        return;

    if (selected) {
        _state |= SKControlStateSelected;
    } else {
        _state &= ~SKControlStateSelected;
    }

    [self stateChanged];
}

- (BOOL)highlighted {
    if (_state & SKControlStateHighlighted)
        return YES;
    else
        return NO;
}

- (void)setHighlighted:(BOOL)highlighted {
    if (self.highlighted == highlighted)
        return;

    if (highlighted) {
        _state |= SKControlStateHighlighted;
    } else {
        _state &= ~SKControlStateHighlighted;
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

- (CGSize)contentSize {
    if (_needsLayout) [self layout];
    return [super contentSize];
}

- (void)pc_didMoveToParent {
    [self setNeedsLayout];
    [super pc_didMoveToParent];
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

- (SKControlState)controlStateFromString:(NSString *)stateName {
    SKControlState state = 0;
    if ([stateName isEqualToString:@"Normal"])
        state = SKControlStateNormal;
    else if ([stateName isEqualToString:@"Highlighted"])
        state = SKControlStateHighlighted;
    else if ([stateName isEqualToString:@"Disabled"])
        state = SKControlStateDisabled;
    else if ([stateName isEqualToString:@"Selected"])
        state = SKControlStateSelected;

    return state;
}

- (void)setValue:(id)value forKey:(NSString *)key state:(SKControlState)state {
}

- (id)valueForKey:(NSString *)key state:(SKControlState)state {
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

    SKControlState state = [self controlStateFromString:stateName];

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

    SKControlState state = [self controlStateFromString:stateName];

    return [self valueForKey:propName state:state];
}

@end
