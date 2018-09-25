//
//  PCAppearanceManager.m
//  SpriteBuilder
//
//  Created by Quinn Thomson on 2014-07-15.
//
//

#import "PCAppearanceManager.h"

@implementation PCAppearanceManager

+ (instancetype)sharedAppearanceManager {
    static PCAppearanceManager *mySharedAppearanceManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharedAppearanceManager = [[self alloc] init];
    });
    return mySharedAppearanceManager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.inspectorFontSize = 11;
        self.inspectorFontWeight = 5;
        self.inspectorFont = @"Helvetica Neue";
        self.inspectorMixedFontTraitMask = NSItalicFontMask;
        self.inspectorUnMixedFontTraitMask = NSUnitalicFontMask;
        self.inspectorMixedFontColor = [NSColor blackColor];
        self.inspectorUnMixedFontColor = [NSColor blackColor];
    }
    return self;
}

- (NSFont *)inspectorFontForMixedState:(BOOL)isMixedState {
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    
    if (isMixedState) {
        return [fontManager fontWithFamily:self.inspectorFont traits:self.inspectorMixedFontTraitMask weight:self.inspectorFontWeight size:self.inspectorFontSize];
    } else {
        return [fontManager fontWithFamily:self.inspectorFont traits:self.inspectorUnMixedFontTraitMask weight:self.inspectorFontWeight size:self.inspectorFontSize];
    }
}

- (NSColor *)inspectorColorForMixedState:(BOOL)isMixedState {
    if (isMixedState) {
        return self.inspectorMixedFontColor;
    } else {
        return self.inspectorUnMixedFontColor;
    }
}

@end
