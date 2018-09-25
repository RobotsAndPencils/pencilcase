//
//  SKTexture+Gradient.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-06-23.
//
//

#import "SKTexture+Gradient.h"

@implementation SKTexture (Gradient)

+ (SKTexture *)gradientWithSize:(const CGSize)size colors:(NSArray *)colors {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    NSAssert(context, @"Failed to create a CGContext in order to render sprite gradient.");
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, size.width, size.height);
    
    NSMutableArray* convertedcolors = [NSMutableArray array];
    for (UIColor *color in colors) {
        [convertedcolors addObject:(id)color.CGColor];
    }
    gradient.colors = convertedcolors;
    [gradient renderInContext:context];
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    SKTexture *texture = [SKTexture textureWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return texture;
}

@end
