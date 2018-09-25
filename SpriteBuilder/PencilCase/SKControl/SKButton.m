//
//  SKButton.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-29.
//
//

#import "SKButton.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+CoordinateConversion.h"
#import "PCMathUtilities.h"

@interface SKButton ()

@property (strong, nonatomic) NSMutableDictionary *backgroundColors;
@property (strong, nonatomic) NSMutableDictionary *backgroundOpacities;
@property (strong, nonatomic) NSMutableDictionary *backgroundTextures;
@property (strong, nonatomic) NSMutableDictionary *labelColors;
@property (strong, nonatomic) NSMutableDictionary *labelOpacities;

@property (assign, nonatomic) CGPoint originalScale;
@property (assign, nonatomic) CGFloat hitAreaExpansion;

@end

@implementation SKButton

- (id)init {
    return [self initWithTitle:@"" texture:nil];
}

- (id)initWithTitle:(NSString *)title texture:(SKTexture *)texture {
    self = [self initWithTitle:title texture:texture highlightedTexture:nil disabledTexture:nil];
    if (self) {
        // Setup default colors for when only one frame is used
        [self setBackgroundColor:[NSColor colorWithWhite:0.7 alpha:1] forState:SKControlStateHighlighted];
        [self setLabelColor:[NSColor colorWithWhite:0.7 alpha:1] forState:SKControlStateHighlighted];
        
        [self setBackgroundOpacity:0.5f forState:SKControlStateDisabled];
        [self setLabelOpacity:0.5f forState:SKControlStateDisabled];
        [super setColor:[NSColor clearColor]];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title texture:(SKTexture *)texture highlightedTexture:(SKTexture *)highlightedTexture disabledTexture:(SKTexture *)disabledTexture {
    self = [super init];
    if (self) {
        self.anchorPoint = CGPointMake(0.5, 0.5);
        
        // Setup holders for properties
        _backgroundColors = [NSMutableDictionary dictionary];
        _backgroundOpacities = [NSMutableDictionary dictionary];
        _backgroundTextures = [NSMutableDictionary dictionary];
        
        _labelColors = [NSMutableDictionary dictionary];
        _labelOpacities = [NSMutableDictionary dictionary];
        
        // Setup background image
        _background = [SKSpriteNode node];
        if (texture) {
            _background = [SKSpriteNode node];
            [self setBackgroundTexture:texture forState:SKControlStateNormal];
            self.preferredSize = texture.size;
        }
        _background.centerRect = CGRectMake(0.45, 0.45, .1, .1);
        _background.colorBlendFactor = 1;
        
        if (highlightedTexture) {
            [self setBackgroundTexture:highlightedTexture forState:SKControlStateHighlighted];
            [self setBackgroundTexture:highlightedTexture forState:SKControlStateSelected];
        }
        
        if (disabledTexture) {
            [self setBackgroundTexture:disabledTexture forState:SKControlStateDisabled];
        }
        
        [self addChild:_background];
        
        // Setup label
        _label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
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
    
    [self.background pc_centerInParent];
    [self.label pc_centerInParent];
}

- (void)mouseDownEntered:(NSEvent *)event {
    if (!self.enabled) {
        return;
    }
    self.highlighted = YES;
}

- (void)mouseDownExited:(NSEvent *)event {
    self.highlighted = NO;
}

- (void)mouseUpInside:(NSEvent *)event {
    if (self.enabled) {
        [self triggerAction];
    }
    self.highlighted = NO;
}

- (void)mouseUpOutside:(NSEvent *)event {
    self.highlighted = NO;
}

- (void)triggerAction {
    // Handle toggle buttons
    if (self.togglesSelectedState) {
        self.selected = !self.selected;
    }
    
    [super triggerAction];
}

- (void)updatePropertiesForState:(SKControlState)state {
    // Update background
    self.background.texture = [self backgroundTextureFrameForState:state];
    self.background.contentSize = self.background.texture.size;
    self.background.color = [self backgroundColorForState:state];
    self.background.opacity = fmax(self.background.texture ? 0.f : 0.01f, [self backgroundOpacityForState:state]);
    
    // Update label
    self.label.fontColor = [self labelColorForState:state];
    self.label.color = [self labelColorForState:state];
    self.label.opacity = [self labelOpacityForState:state];
    
    [self setNeedsLayout];
}

- (void)stateChanged {
    if (self.enabled) {
        // Button is enabled
        if (self.highlighted) {
            [self updatePropertiesForState:SKControlStateHighlighted];
        } else {
            if (self.selected) {
                [self updatePropertiesForState:SKControlStateSelected];
            } else {
                [self updatePropertiesForState:SKControlStateNormal];
            }
        }
    } else {
        // Button is disabled
        [self updatePropertiesForState:SKControlStateDisabled];
    }
}

#pragma mark Properties

- (void)setColor:(NSColor *)color {
    [self setLabelColor:color forState:SKControlStateNormal];
}

- (void)setLabelColor:(NSColor *)color forState:(SKControlState)state {
    [self.labelColors setObject:color forKey:@(state)];
    [self stateChanged];
}

- (NSColor *)labelColorForState:(SKControlState)state {
    NSColor *color = [self.labelColors objectForKey:@(state)];
    if (!color)
        color = [NSColor whiteColor];
    return color;
}

- (void)setLabelOpacity:(CGFloat)opacity forState:(SKControlState)state {
    [self.labelOpacities setObject:@(opacity) forKey:@(state)];
    [self stateChanged];
}

- (CGFloat)labelOpacityForState:(SKControlState)state {
    NSNumber *val = [self.labelOpacities objectForKey:@(state)];
    if (!val) return 1;
    return [val floatValue];
}

- (void)setBackgroundColor:(NSColor *)color forState:(SKControlState)state {
    [self.backgroundColors setObject:color forKey:@(state)];
    [self stateChanged];
}

- (NSColor *)backgroundColorForState:(SKControlState)state {
    NSColor *color = [self.backgroundColors objectForKey:@(state)];
    if (!color) color = [NSColor whiteColor];
    if (color.alphaComponent < 0.01) {
        color = [color colorWithAlphaComponent:0.01];
    }
    return color;
}

- (void)setBackgroundOpacity:(CGFloat)opacity forState:(SKControlState)state {
    [self.backgroundOpacities setObject:@(opacity) forKey:@(state)];
    [self stateChanged];
}

- (CGFloat)backgroundOpacityForState:(SKControlState)state {
    NSNumber *val = [self.backgroundOpacities objectForKey:@(state)];
    if (!val) return 1;
    return [val floatValue];
}

- (void)matchSizeIfNecessaryToTexture:(SKTexture *)texture forState:(SKControlState)state oldTexture:(SKTexture *)oldTexture {
    if (!texture || state != SKControlStateNormal) return;
    if (!oldTexture && !CGSizeEqualToSize(self.preferredSize, PCPreferredSizeUnset)) return;
    //If the user is using the default size, resize their button, but if they have resized it manually assume that this is the size they want
    if (oldTexture && !CGSizeEqualToSize(self.preferredSize, oldTexture.size)) return;

    self.preferredSize = texture.size;
}

- (void)setBackgroundTexture:(SKTexture *)texture forState:(SKControlState)state {
    [self matchSizeIfNecessaryToTexture:texture forState:state oldTexture:[self backgroundTextureFrameForState:state]];
    if (texture) {
        [self.backgroundTextures setObject:texture forKey:@(state)];
    } else {
        [self.backgroundTextures removeObjectForKey:@(state)];
    }
    [self stateChanged];
}

- (SKTexture *)backgroundTextureFrameForState:(SKControlState)state {
    return [self.backgroundTextures objectForKey:@(state)];
}

- (void)setTitle:(NSString *)title {
    self.label.text = title;
    // The special case where the title is nil, but we want the frame to resize as if it is an empty space
    if (PCIsEmpty(title)) self.label.text = @" ";
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

- (void)setValue:(id)value forKey:(NSString *)key state:(SKControlState)state {
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

- (id)valueForKey:(NSString *)key state:(SKControlState)state {
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
