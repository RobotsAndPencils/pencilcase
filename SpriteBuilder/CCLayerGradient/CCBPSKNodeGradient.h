//
//  CCBPSKNodeGradient.h
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-06-23.
//
//

#import <SpriteKit/SpriteKit.h>

@interface CCBPSKNodeGradient : SKSpriteNode

@property (nonatomic, strong) NSColor *startColor;
@property (nonatomic, strong) NSColor *endColor;
@property (nonatomic, assign) CGPoint vector;

@end
