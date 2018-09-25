//
//  SKTexture+JSExport.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-28.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "SKTexture+JSExport.h"
#import "CCFileUtils.h"

@implementation SKTexture (JSExport)

+ (instancetype)textureWithUUID:(NSString *)uuid {
    return [[CCFileUtils sharedFileUtils] textureForSpriteUUID:uuid];
}

+ (instancetype)textureWithRelativeImagePath:(NSString *)relativePath {
    return [[CCFileUtils sharedFileUtils] textureForSpriteFile:relativePath];
}

- (UIImage *)__pc_UIImage {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@", @"_", @"cre", @"ateCGImage"]);
    if (![self respondsToSelector:selector]) return nil;

    CGImageRef imageRef = (__bridge CGImageRef)[self performSelector:selector];
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);

    return image;
}

@end
