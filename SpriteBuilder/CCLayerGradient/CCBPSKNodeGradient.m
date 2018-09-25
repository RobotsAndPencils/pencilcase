//
//  CCBPSKNodeGradient.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-06-23.
//
//

#import "CCBPSKNodeGradient.h"
#import "SKTexture+Gradient.h"
#import "AppDelegate.h"
#import "SKNode+CocosCompatibility.h"

@implementation CCBPSKNodeGradient

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _startColor = [NSColor whiteColor];
    _endColor = [NSColor whiteColor];
    
    return self;
}

- (PCEditorResizeBehaviour)editorResizeBehaviour {
    return PCEditorResizeBehaviourContentSize;
}

#pragma mark Properties

- (void)setStartColor:(NSColor *)startColor {
    _startColor = startColor;
    [self updateTexture];
}

- (void)setEndColor:(NSColor *)endColor {
    _endColor = endColor;
    [self updateTexture];
}

#pragma mark Private

- (void)updateTexture {
    NSColor *startColor = self.startColor;
    NSColor *endColor = self.endColor;
    if (!startColor || !endColor) return;
    
    SKTexture *newTexture = [SKTexture gradientWithSize:self.size colors:@[ startColor, endColor ]];
    self.texture = newTexture;
}

@end
