//
//  PCGradientNode+___VARIABLE_productName:identifier___.h
//  PencilCaseLauncherDemo
//
//  Created by Brandon Evans on 15-01-15.
//
//

@import JavaScriptCore;
#import "PCNodeGradient.h"

@protocol PCNodeGradientExport <JSExport>

@property (nonatomic, strong) UIColor *startColor;
@property (nonatomic, strong) UIColor *endColor;
@property (nonatomic, assign) CGPoint vector;

@end

@interface PCNodeGradient (JSExport) <PCNodeGradientExport>

@end
