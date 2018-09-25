//
//  PhysicsInspector.m
//  SpriteBuilder
//
//  Created by Quinn Thomson on 2014-07-15.
//
//

#import "PhysicsInspector.h"
#import "PCAppearanceManager.h"

@implementation PhysicsInspector

- (void)updatePhysicsInspectorFontsWithMixedState:(NSMutableDictionary *)isMixedStateDict {
    PCAppearanceManager *appearanceManager = [PCAppearanceManager sharedAppearanceManager];
    
    self.bodyShapeFont = [appearanceManager inspectorFontForMixedState:[isMixedStateDict[@"bodyShape"] boolValue]];
    self.bodyShapeFontColor = [appearanceManager inspectorColorForMixedState:[isMixedStateDict[@"bodyShape"] boolValue]];
    
    self.radiusFont = [appearanceManager inspectorFontForMixedState:[isMixedStateDict[@"cornerRadius"] boolValue]];
    self.radiusFontColor = [appearanceManager inspectorColorForMixedState:[isMixedStateDict[@"cornerRadius"] boolValue]];
    
    self.densityFont = [appearanceManager inspectorFontForMixedState:[isMixedStateDict[@"density"] boolValue]];
    self.densityFontColor = [appearanceManager inspectorColorForMixedState:[isMixedStateDict[@"density"] boolValue]];
    
    self.frictionFont = [appearanceManager inspectorFontForMixedState:[isMixedStateDict[@"friction"] boolValue]];
    self.frictionFontColor = [appearanceManager inspectorColorForMixedState:[isMixedStateDict[@"friction"] boolValue]];
    
    self.elasticityFont = [appearanceManager inspectorFontForMixedState:[isMixedStateDict[@"elasticity"] boolValue]];
    self.elasticityFontColor = [appearanceManager inspectorColorForMixedState:[isMixedStateDict[@"elasticity"] boolValue]];
}

@end
