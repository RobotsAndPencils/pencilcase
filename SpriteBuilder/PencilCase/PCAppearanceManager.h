//
//  PCAppearanceManager.h
//  SpriteBuilder
//
//  Created by Quinn Thomson on 2014-07-15.
//
//

#import <Foundation/Foundation.h>

@interface PCAppearanceManager : NSObject

@property (assign, nonatomic) NSInteger inspectorFontSize;
@property (assign, nonatomic) NSInteger inspectorFontWeight;
@property (strong, nonatomic) NSString *inspectorFont;
@property (assign, nonatomic) NSFontTraitMask inspectorMixedFontTraitMask;
@property (assign, nonatomic) NSFontTraitMask inspectorUnMixedFontTraitMask;
@property (strong, nonatomic) NSColor *inspectorMixedFontColor;
@property (strong, nonatomic) NSColor *inspectorUnMixedFontColor;

+ (instancetype)sharedAppearanceManager;
- (NSFont *)inspectorFontForMixedState:(BOOL)isMixedState;
- (NSColor *)inspectorColorForMixedState:(BOOL)isMixedState;

@end
