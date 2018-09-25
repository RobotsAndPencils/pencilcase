//
//  PhysicsInspector.h
//  SpriteBuilder
//
//  Created by Quinn Thomson on 2014-07-15.
//
//

#import <Foundation/Foundation.h>

@interface PhysicsInspector : NSObject

@property (strong, nonatomic) NSFont *bodyShapeFont;
@property (strong, nonatomic) NSFont *radiusFont;
@property (strong, nonatomic) NSFont *densityFont;
@property (strong, nonatomic) NSFont *frictionFont;
@property (strong, nonatomic) NSFont *elasticityFont;

@property (strong, nonatomic) NSColor *bodyShapeFontColor;
@property (strong, nonatomic) NSColor *radiusFontColor;
@property (strong, nonatomic) NSColor *densityFontColor;
@property (strong, nonatomic) NSColor *frictionFontColor;
@property (strong, nonatomic) NSColor *elasticityFontColor;

- (void)updatePhysicsInspectorFontsWithMixedState:(NSMutableDictionary *)isMixedStateDict;

@end
