//
//  SKButton.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-29.
//
//

#import "PCButton.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+CoordinateConversion.h"
#import "PCMathUtilities.h"
#import "SKNode+LifeCycle.h"
#import "PCHashFixLabelNode.h"
#import "PCJSContext.h"

@interface PCButton ()

@property (strong, nonatomic) NSMutableDictionary *backgroundColors;
@property (strong, nonatomic) NSMutableDictionary *backgroundOpacities;
@property (strong, nonatomic) NSMutableDictionary *backgroundTextures;
@property (strong, nonatomic) NSMutableDictionary *labelColors;
@property (strong, nonatomic) NSMutableDictionary *labelOpacities;

@property (assign, nonatomic) CGPoint originalScale;
@property (assign, nonatomic) CGFloat hitAreaExpansion;

@end

@implementation PCButton

- (id)init {
    return [self initWithTitle:@"" texture:nil];
}

- (id)initWithTitle:(NSString *)title texture:(SKTexture *)texture {
    self = [self initWithTitle:title texture:texture highlightedTexture:nil disabledTexture:nil];
    if (self) {
        // Setup default colors for when only one frame is used
        [self setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:1] forState:PCControlStateHighlighted];
        [self setLabelColor:[UIColor colorWithWhite:0.7 alpha:1] forState:PCControlStateHighlighted];
        
        [self setBackgroundOpacity:0.5f forState:PCControlStateDisabled];
        [self setLabelOpacity:0.5f forState:PCControlStateDisabled];
        [super setColor:[UIColor clearColor]];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title texture:(SKTexture *)texture highlightedTexture:(SKTexture *)highlightedTexture disabledTexture:(SKTexture *)disabledTexture {
    self = [super init];
    if (self) {
        self.anchorPoint = CGPointMake(0.5, 0.5);
        
        if (!title) title = @"";
        self.title = title;
        
        // Setup holders for properties
        _backgroundColors = [NSMutableDictionary dictionary];
        _backgroundOpacities = [NSMutableDictionary dictionary];
        _backgroundTextures = [NSMutableDictionary dictionary];
        
        _labelColors = [NSMutableDictionary dictionary];
        _labelOpacities = [NSMutableDictionary dictionary];
        
        // Setup background image
        _background = [SKSpriteNode node];
        if (texture) {
            _background = [SKSpriteNode spriteNodeWithTexture:texture];
            [self setBackgroundTexture:texture forState:PCControlStateNormal];
            self.preferredSize = texture.size;
        }
        _background.colorBlendFactor = 1;
        
        if (highlightedTexture) {
            [self setBackgroundTexture:highlightedTexture forState:PCControlStateHighlighted];
            [self setBackgroundTexture:highlightedTexture forState:PCControlStateSelected];
        }
        
        if (disabledTexture) {
            [self setBackgroundTexture:disabledTexture forState:PCControlStateDisabled];
        }
        
        [self addChild:_background];
        
        // Setup label
        _label = [PCHashFixLabelNode labelNodeWithFontNamed:@"Helvetica"];
        _label.fontSize = 14;
        _label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _label.colorBlendFactor = 1;
        
        [self addChild:_label];
        
        // Setup original scale
        _originalScale = CGPointMake(1, 1);
        
        [self setNeedsLayout];
        [self stateChanged];
    }
    return self;
}

- (void)layout {
    [super layout];
    if (!self.pc_scene) return;
    
    self.label.xScale = self.label.yScale = 1;
    CGSize originalLabelSize = self.label.frame.size;
    CGSize paddedLabelSize = originalLabelSize;
    paddedLabelSize.width += self.horizontalPadding * 2;
    paddedLabelSize.height += self.verticalPadding * 2;
    
    BOOL shrunkSize = NO;
    CGSize size = self.preferredSize;
    
    CGSize maxSize = self.maxSize;
    
    size.width = MAX(size.width, paddedLabelSize.width);
    size.height = MAX(size.height, paddedLabelSize.height);
    
    if (maxSize.width > 0 && maxSize.width < size.width) {
        size.width = maxSize.width;
        shrunkSize = YES;
    }
    if (maxSize.height > 0 && maxSize.height < size.height) {
        size.height = maxSize.height;
        shrunkSize = YES;
    }
    
    if (shrunkSize) {
        CGSize labelSize = CGSizeMake(pc_clampf(size.width - self.horizontalPadding * 2, 0, originalLabelSize.width),
                                      pc_clampf(size.height - self.verticalPadding * 2, 0, originalLabelSize.height));
        self.label.xScale = labelSize.width / MAX(1, originalLabelSize.width);
        self.label.yScale = labelSize.height / MAX(1, originalLabelSize.height);
    }
    
    self.contentSize = size;
    self.background.xScale = self.contentSize.width / self.background.contentSize.width;
    self.background.yScale = self.contentSize.height / self.background.contentSize.height;

    if (self.state == PCControlStateHighlighted && self.zoomWhenHighlighted) {
        self.background.xScale *= 1.1;
        self.background.yScale *= 1.1;
        self.label.xScale *= 1.1;
        self.label.yScale *= 1.1;
    }
    
    [self.background pc_centerInParent];
    [self.label pc_centerInParent];
}

- (void)touchEntered:(UITouch *)touch withEvent:(UIEvent *)event {
    if (!self.enabled) {
        return;
    }

    if (self.hidden) return;

    // FIXME: claimsUserInteraction
    /*
     if (self.claimsUserInteraction)
     {
     [super setHitAreaExpansion:_originalHitAreaExpansion + SBFatFingerExpansion];
     }
     */
    self.highlighted = YES;
}

- (void)touchExited:(UITouch *)touch withEvent:(UIEvent *)event {
    self.highlighted = NO;
}

- (void)touchUpInside:(UITouch *)touch withEvent:(UIEvent *)event {
    // FIXME: hit area expansion
    //[super setHitAreaExpansion:_originalHitAreaExpansion];

    if (self.hidden) return;

    if (self.enabled) {
        [self triggerAction];
    }

    self.highlighted = NO;
}

- (void)touchUpOutside:(UITouch *)touch withEvent:(UIEvent *)event {
    // FIXME: hit area expansion
    //[super setHitAreaExpansion:_originalHitAreaExpansion];
    self.highlighted = NO;
}

- (void)triggerAction {
    if (self.togglesSelectedState) {
        self.selected = !self.selected;

        // Based on the desired selection state token for whens in the author
        NSString *state = self.selected ? @"on" : @"off";
        [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:self userInfo:@{
            PCJSContextEventNotificationEventNameKey : @"toggled",
            PCJSContextEventNotificationArgumentsKey : @[ self, state ]
        }];
    }

    [super triggerAction];
}

- (void)updatePropertiesForState:(PCControlState)state {
    SKTexture *backgroundTexture = [self backgroundTextureFrameForState:state];
    self.background.texture = backgroundTexture;

    // If there's a background texture, set the color and opacity for it
    if (backgroundTexture) {
        self.background.color = [self backgroundColorForState:state];
        self.background.opacity = [self backgroundOpacityForState:state];

        self.background.contentSize = [backgroundTexture size];
        self.background.centerRect = CGRectMake(0.45, 0.45, .1, .1);
    }
    // Otherwise just hide the sprite and let the label show
    else {
        self.background.color = [UIColor clearColor];
        self.background.centerRect = CGRectMake(0, 0, 1, 1);
    }

    // Update label
    self.label.color = [self labelColorForState:state];
    self.label.opacity = [self labelOpacityForState:state];
    
    [self setNeedsLayout];
}

- (void)stateChanged {
    if (self.enabled) {
        // Button is enabled
        if (self.highlighted) {
            [self updatePropertiesForState:PCControlStateHighlighted];
        } else {
            if (self.selected) {
                [self updatePropertiesForState:PCControlStateSelected];
            } else {
                [self updatePropertiesForState:PCControlStateNormal];
            }
        }
    } else {
        // Button is disabled
        [self updatePropertiesForState:PCControlStateDisabled];
    }
}

#pragma mark Properties

- (void)setColor:(UIColor *)color {
    [self setLabelColor:color forState:PCControlStateNormal];
}

- (void)setLabelColor:(UIColor *)color forState:(PCControlState)state {
    [self.labelColors setObject:color forKey:@(state)];
    [self stateChanged];
}

- (UIColor *)labelColorForState:(PCControlState)state {
    UIColor *color = [self.labelColors objectForKey:@(state)];
    if (!color)
        color = [UIColor whiteColor];
    return color;
}

- (void)setLabelOpacity:(CGFloat)opacity forState:(PCControlState)state {
    [self.labelOpacities setObject:@(opacity) forKey:@(state)];
    [self stateChanged];
}

- (CGFloat)labelOpacityForState:(PCControlState)state {
    NSNumber *val = [self.labelOpacities objectForKey:@(state)];
    if (!val) return 1;
    return [val floatValue];
}

- (void)setBackgroundColor:(UIColor *)color forState:(PCControlState)state {
    [self.backgroundColors setObject:color forKey:@(state)];
    [self stateChanged];
}

- (UIColor *)backgroundColorForState:(PCControlState)state {
    UIColor *color = [self.backgroundColors objectForKey:@(state)];
    if (!color) color = [UIColor whiteColor];
    CGFloat alpha;
    [color getHue:NULL saturation:NULL brightness:NULL alpha:&alpha];
    if (alpha < 0.01) {
        color = [color colorWithAlphaComponent:0.01];
    }
    return color;
}

- (void)setBackgroundOpacity:(CGFloat)opacity forState:(PCControlState)state {
    [self.backgroundOpacities setObject:@(opacity) forKey:@(state)];
    [self stateChanged];
}

- (CGFloat)backgroundOpacityForState:(PCControlState)state {
    NSNumber *val = [self.backgroundOpacities objectForKey:@(state)];
    if (!val) return 1;
    return [val floatValue];
}

- (void)setBackgroundTexture:(SKTexture *)texture forState:(PCControlState)state {
    if (texture) {
        [self.backgroundTextures setObject:texture forKey:@(state)];
    } else {
        [self.backgroundTextures removeObjectForKey:@(state)];
    }
    [self stateChanged];
}

- (SKTexture *)backgroundTextureFrameForState:(PCControlState)state {
    return [self.backgroundTextures objectForKey:@(state)];
}

- (void)setTitle:(NSString *)title {
    self.label.text = title;
    [self setNeedsLayout];
}

- (NSString *)title {
    return self.label.text;
}

- (void)setHorizontalPadding:(float)horizontalPadding {
    _horizontalPadding = horizontalPadding;
    [self setNeedsLayout];
}

- (void)setVerticalPadding:(float)verticalPadding {
    _verticalPadding = verticalPadding;
    [self setNeedsLayout];
}

- (NSArray *)keysForwardedToLabel {
    return @[ @"fontName", @"fontSize", @"color", @"fontColor" ];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([[self keysForwardedToLabel] containsObject:key]) {
        [self.label setValue:value forKey:key];
        [self setNeedsLayout];
        return;
    }
    [super setValue:value forKey:key];
}

- (id)valueForKey:(NSString *)key {
    if ([[self keysForwardedToLabel] containsObject:key]) {
        return [self.label valueForKey:key];
    }
    return [super valueForKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key state:(PCControlState)state {
    if ([key isEqualToString:@"labelOpacity"]) {
        [self setLabelOpacity:[value floatValue] forState:state];
    } else if ([key isEqualToString:@"labelColor"]) {
        [self setLabelColor:value forState:state];
    } else if ([key isEqualToString:@"backgroundOpacity"]) {
        [self setBackgroundOpacity:[value floatValue] forState:state];
    } else if ([key isEqualToString:@"backgroundColor"]) {
        [self setBackgroundColor:value forState:state];
    } else if ([key isEqualToString:@"backgroundSpriteFrame"]) {
        [self setBackgroundTexture:value forState:state];
    }
}

- (id)valueForKey:(NSString *)key state:(PCControlState)state {
    if ([key isEqualToString:@"labelOpacity"]) {
        return @([self labelOpacityForState:state]);
    } else if ([key isEqualToString:@"labelColor"]) {
        return [self labelColorForState:state];
    } else if ([key isEqualToString:@"backgroundOpacity"]) {
        return @([self backgroundOpacityForState:state]);
    } else if ([key isEqualToString:@"backgroundColor"]) {
        return [self backgroundColorForState:state];
    } else if ([key isEqualToString:@"backgroundSpriteFrame"]) {
        return [self backgroundTextureFrameForState:state];
    }
    
    return nil;
}

@end