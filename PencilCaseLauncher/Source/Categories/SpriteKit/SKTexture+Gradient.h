//
//  SKTexture+Gradient.h
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-06-23.
//
//

#import <SpriteKit/SpriteKit.h>

@interface SKTexture (Gradient)

+ (SKTexture *)gradientWithSize:(const CGSize)size colors:(NSArray *)colors;

@end
