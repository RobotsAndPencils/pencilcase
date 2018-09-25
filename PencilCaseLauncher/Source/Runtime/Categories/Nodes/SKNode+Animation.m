//
//  SKNode+Animation.m
//  PencilCaseLauncherDemo
//
//  Created by Brandon Evans on 15-02-03.
//
//

#import <objc/runtime.h>
#import "SKNode+Animation.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+PhysicsExport.h"

@implementation SKNode (Animation)

#pragma mark - Properties

- (void)setOriginalDynamicism:(BOOL)originalDynamicism {
    objc_setAssociatedObject(self, @selector(originalDynamicism), @(originalDynamicism), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)originalDynamicism {
    return [objc_getAssociatedObject(self, @selector(originalDynamicism)) boolValue];
}

- (void)setPositionActionCount:(NSInteger)positionActionCount {
    objc_setAssociatedObject(self, @selector(positionActionCount), @(positionActionCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)positionActionCount {
    return [objc_getAssociatedObject(self, @selector(positionActionCount)) unsignedIntegerValue];
}

- (void)positionActionStarted {
    if (0 == self.positionActionCount) {
        self.originalDynamicism = self.physicsBodyDynamic;
        self.physicsBodyDynamic = NO;
    }
    self.positionActionCount++;
}

- (void)positionAnimationEnded {
    --self.positionActionCount;
    NSAssert(self.positionActionCount >= 0, @"Position action decremented too many times");
    if (0 == self.positionActionCount) {
        self.physicsBodyDynamic = self.originalDynamicism;
    }
}

#pragma mark - Public Methods

- (void)pc_animateProperty:(NSString *)propertyName value:(id)value duration:(CGFloat)duration completion:(JSValue *)completion {
    // Some properties have specific actions for animation, so lets use them.
    // For properties that don't, we need to interpolate the values ourselves and assign in a custom action.
    // In the case where we're unable to properly interpolate a value (or some other failure case),
    // the target value should still be set and the completion block called after the full duration
    // If a target value is invalid then nothing should occur.

    SKAction *animationAction;

    // When the animation completes, call the JS completion callback.
    // This is likely used to delay subsequent evaluation while a generator is yielding to this method.
    SKAction *completionAction = [SKAction runBlock:^{
        [completion callWithArguments:@[]];
    }];

    if ([propertyName isEqualToString:@"visible"]) {
        animationAction = [self visibleActionToValue:value duration:duration];
    }
    else if ([propertyName isEqualToString:@"position"]) {
        animationAction = [self positionActionToValue:value duration:duration];
    }
    else if ([propertyName isEqualToString:@"rotation"]) {
        animationAction = [self rotationActionToValue:value duration:duration];
    }
    else if ([propertyName isEqualToString:@"xRotation3D"] || [propertyName isEqualToString:@"yRotation3D"] || [propertyName isEqualToString:@"zRotation3D"]) {
        animationAction = [self pc_animateKey:propertyName toFloat:[value floatValue] duration:duration];
    }
    else if ([propertyName isEqualToString:@"scale"] || [propertyName isEqualToString:@"scalePoint"]) {
        animationAction = [self scaleActionToValue:value duration:duration];
    }
    else if ([propertyName isEqualToString:@"opacity"]) {
        animationAction = [self fadeActionToValue:value duration:duration];
    }
    else if ([propertyName isEqualToString:@"contentSize"]) {
        animationAction = [self contentSizeActionToValue:value duration:duration];
    }
    else if ([propertyName isEqualToString:@"spriteFrame"]) {
        animationAction = [self spriteFrameActionToValue:value duration:duration];
    }
    // colorRGBA is the Cocos compatibility property for tint color
    else if ([propertyName isEqualToString:@"color"] || [propertyName isEqualToString:@"colorRGBA"]) {
        animationAction = [self colorActionToValue:value duration:duration];
    }
    else {
        // This currently does nothing except wait for the set duration
        animationAction = [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime) {}];
    }
    animationAction.timingMode = SKActionTimingEaseInEaseOut;

    SKAction *sequencedActions = [SKAction sequence:@[ animationAction, completionAction ]];
    [self runAction:sequencedActions];
}

#pragma mark - Action Creation

/**
 *  Creates an action that changes the node's visibility immediately, but will wait for the full duration until completing
 *
 *  @param value    An NSNumber-wrapped boolean to set the visibility to
 *  @param duration The duration of the action
 *
 *  @return An action that changes the visibility of the node
 */
- (SKAction *)visibleActionToValue:(id)value duration:(CGFloat)duration {
    BOOL targetVisibility = self.visible;
    if ([value isKindOfClass:[NSNumber class]]) {
        targetVisibility = ((NSNumber *)value).boolValue;
    }
    SKAction *animationAction = targetVisibility ? [SKAction unhide] : [SKAction hide];
    return [SKAction sequence:@[ animationAction, [SKAction waitForDuration:duration] ]];
}

/**
 *  Creates an action that changes the node's scale to a given value over a given duration
 *
 *  @param value    A dictionary in the form of { x: , y: }, or an NSNumber-wrapped number
 *  @param duration The duration of the action
 *
 *  @return An action that changes the scale of the node
 */
- (SKAction *)scaleActionToValue:(id)value duration:(CGFloat)duration {
    CGFloat targetXScale = self.xScale;
    CGFloat targetYScale = self.yScale;
    SKAction *animationAction = [SKAction scaleTo:targetXScale duration:duration];

    // This could potentially take an object {x: , y: } (change x and y independently) or a number (change both)
    // The UI will likely only allow one method of these, but programmatically we can support both
    if ([value isKindOfClass:[NSDictionary class]]) {
        CGPoint targetPoint = [self pointFromDictionary:(NSDictionary *)value];
        targetXScale = targetPoint.x;
        targetYScale = targetPoint.y;

        SKAction *xAction = [SKAction scaleXTo:targetXScale duration:duration];
        SKAction *yAction = [SKAction scaleYTo:targetYScale duration:duration];
        animationAction = [SKAction group:@[ xAction, yAction ]];
    }
    else if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber *valueNumber = (NSNumber *)value;
        targetXScale = targetYScale = valueNumber.floatValue;
        animationAction = [SKAction scaleTo:targetXScale duration:duration];
    }

    return animationAction;
}

/**
 *  Creates an action that changes the node's rotation to a given value over a given duration
 *
 *  @param value    An NSNumber-wrapped number for the desired rotation in degrees
 *  @param duration The duration of the action
 *
 *  @return An action that changes the rotation of the node
 */
- (SKAction *)rotationActionToValue:(id)value duration:(CGFloat)duration {
    CGFloat targetAngle = self.rotation; // degrees
    if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber *angleValue = (NSNumber *)value;
        targetAngle = angleValue.floatValue;
    }
    // SpriteKit operates in radians, but the UI and Cocos compatibility properties are in degrees
    targetAngle = DEGREES_TO_RADIANS(targetAngle);
    SKAction *animationAction = [SKAction rotateToAngle:targetAngle duration:duration];
    return animationAction;
}

/**
 *  Creates an action that changes a node's property from it's current value to a given value over a given duration
 *
 *  @param key       The property key to animate
 *  @param toValue   The desired final value of the property
 *  @param duration  The duration of the animation action
 *
 *  @return An action that changes the rotation of the node
 */
- (SKAction *)pc_animateKey:(NSString *)key toFloat:(CGFloat)toValue duration:(CGFloat)duration {
    __block CGFloat originalValue = CGFLOAT_MAX;
    return [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        if (elapsedTime == 0) return;
        if (CGFLOAT_MAX == originalValue) {
            originalValue = [[node valueForKey:key] floatValue];
        }
        CGFloat newValue = originalValue + (toValue - originalValue) * (elapsedTime / duration);
        [node setValue:@(newValue) forKey:key];
    }];
}

/**
 *  Creates an action that changes the node's position to a given point and over a given duration
 *
 *  @param value    The point to move to, as either a NSValue-wrapped CGPoint or a dictionary with "x" and "y" keys and NSNumber values
 *  @param duration The duration of the action
 *  @return An action that changes the rotation of the node
 */
- (SKAction *)positionActionToValue:(id)value duration:(CGFloat)duration {
    CGPoint targetPosition = self.position;
    if ([value isKindOfClass:[NSValue class]]) {
        NSValue *positionValue = (NSValue *)value;
        targetPosition = positionValue.CGPointValue;
    }
    else if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *valueDictionary = (NSDictionary *)value;
        targetPosition = [self pointFromDictionary:valueDictionary];
    }

    if (self.positionActionCount == 0) {
        self.originalDynamicism = self.physicsBodyDynamic;
    }

    SKAction *staticAction = [SKAction runBlock:^{
        self.positionActionCount += 1;
        self.physicsBodyDynamic = NO;
    }];
    SKAction *moveAction = [SKAction moveTo:targetPosition duration:duration];
    SKAction *dynamicAction = [SKAction runBlock:^{
        self.positionActionCount -= 1;

        if (self.positionActionCount == 0) {
            self.physicsBodyDynamic = self.originalDynamicism;
        }
    }];

    return [SKAction sequence:@[ staticAction, moveAction, dynamicAction ]];
}

/**
 *  Creates an action that changes the node's background color or tint color over a given duration
 *
 *  @param value    The color to set, as a SKColor
 *  @param duration The duration of the action
 *
 *  @return An action that changes the background color or tint color
 */
- (SKAction *)colorActionToValue:(id)value duration:(CGFloat)duration {
    if (![self respondsToSelector:@selector(color)]) return [SKAction runBlock:nil]; // Noop

    SKColor *targetColor = [self valueForKey:@"color"];
    if ([value isKindOfClass:[SKColor class]]) {
        targetColor = (SKColor *)value;
    }
    SKAction *animationAction = [SKAction colorizeWithColor:targetColor colorBlendFactor:1.0 duration:duration];

    return animationAction;
}

/**
 *  Creates an action that changes the node's sprite frame (texture) immediately, but completes only after the full duration
 *
 *  @param value    The SKTexture to set the sprite to
 *  @param duration The duration of the action
 *
 *  @return An action that changes the sprite frame
 */
- (SKAction *)spriteFrameActionToValue:(id)value duration:(CGFloat)duration {
    if (![self respondsToSelector:@selector(spriteFrame)]) return [SKAction runBlock:nil]; // Noop
    SKAction *animationAction = [SKAction runBlock:nil];

    if ([value isKindOfClass:[SKTexture class]]) {
        SKTexture *targetTexture = (SKTexture *)value;
        // The default SKAction that changes the texture does it immediately
        // Here we replicate that but with the spriteFrame property
        animationAction = [SKAction runBlock:^{
            [self setValue:targetTexture forKey:@"spriteFrame"];
        }];
    }

    return [SKAction sequence:@[ animationAction, [SKAction waitForDuration:duration] ]];
}

/**
 *  Creates an actio that changes the node's content size to a given size over a given duration
 *
 *  @param value    A dictionary of the form { width: , height } to set the size to
 *  @param duration The duration of the action
 *
 *  @return An action that changes the content size
 */
- (SKAction *)contentSizeActionToValue:(id)value duration:(CGFloat)duration {
    CGSize targetSize = self.contentSize;
    if ([value isKindOfClass:[NSValue class]]) {
        NSValue *valueValue = (NSValue *)value;
        targetSize = valueValue.CGSizeValue;
    }
    else if ([value isKindOfClass:[NSDictionary class]]) {
        targetSize = [self sizeFromDictionary:(NSDictionary *)value];
    }
    SKAction *animationAction = [SKAction resizeToWidth:targetSize.width height:targetSize.height duration:duration];

    return animationAction;
}

/**
 *  Creates an action that changes the node's opacity to a given value over a given duration
 *
 *  @param value    An NSNumber-wrapped value to change the opacity to
 *  @param duration The duration of the action
 *
 *  @return An action that changes the opacity
 */
- (SKAction *)fadeActionToValue:(id)value duration:(CGFloat)duration {
    CGFloat targetAlpha = self.alpha;
    if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber *valueNumber = (NSNumber *)value;
        targetAlpha = valueNumber.floatValue;
    }
    SKAction *animationAction = [SKAction fadeAlphaTo:targetAlpha duration:duration];
    return animationAction;
}

#pragma mark - Helpers

- (CGPoint)pointFromDictionary:(NSDictionary *)dictionary {
    CGPoint point = CGPointZero;
    point = CGPointMake([dictionary[@"x"] floatValue], [dictionary[@"y"] floatValue]);
    return point;
}

- (CGSize)sizeFromDictionary:(NSDictionary *)dictionary {
    CGSize size = CGSizeZero;
    size = CGSizeMake([dictionary[@"width"] floatValue], [dictionary[@"height"] floatValue]);
    return size;
}

@end
