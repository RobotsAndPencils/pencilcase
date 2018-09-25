//
//  PCNodeGradient.h
//  PCPlayer
//
//  Created by Brandon Evans on 2014-06-23.
//
//

#import <SpriteKit/SpriteKit.h>

@interface PCNodeGradient : SKSpriteNode

@property (nonatomic, strong) UIColor *startColor;
@property (nonatomic, strong) UIColor *endColor;
@property (nonatomic, assign) CGPoint vector;

@end
