//
//  PCNodeGradient.m
//  PCPlayer
//
//  Created by Brandon Evans on 2014-06-23.
//
//

#import "PCNodeGradient.h"
#import "SKTexture+Gradient.h"

@implementation PCNodeGradient

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _startColor = [UIColor whiteColor];
    _endColor = [UIColor whiteColor];
    
    return self;
}

#pragma mark Properties

- (void)setStartColor:(UIColor *)startColor {
    _startColor = startColor;
    [self updateTexture];
}

- (void)setEndColor:(UIColor *)endColor {
    _endColor = endColor;
    [self updateTexture];
}

#pragma mark Private

- (void)updateTexture {
    UIColor *startColor = self.startColor;
    UIColor *endColor = self.endColor;
    if (!startColor || !endColor) return;
    
    SKTexture *newTexture = [SKTexture gradientWithSize:self.size colors:@[ startColor, endColor ]];
    self.texture = newTexture;
}

@end
