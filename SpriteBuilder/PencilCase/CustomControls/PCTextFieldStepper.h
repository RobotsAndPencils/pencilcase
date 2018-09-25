//
//  PCTextFieldStepper.h
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-06-18.
//
//

#import <Cocoa/Cocoa.h>

extern const CGFloat PCDefaultTextStepAmount;
extern const CGFloat PCUseDefaultTextStepAmount;

@interface PCTextFieldStepper : NSTextField

@property (assign, nonatomic) CGFloat stepAmount;

+ (void)setFormatterFor:(CGFloat)maximum inspectorValue:(InspectorValue *)inspectorValue multiplier:(CGFloat)multiplier stepAmount:(CGFloat)stepAmount minimum:(CGFloat)minimum;

@end
