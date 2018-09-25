//
//  PCSprite+JSExport.m
//  PCPlayer
//
//  Created by Brandon on 2014-02-25.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <objc/runtime.h>
#import "PCSprite+JSExport.h"
#import "CCFileUtils.h"

@implementation PCSprite (JSExport)

+ (id)spriteWithImage:(NSString *)name {
    NSString *fullPath = [NSString stringWithFormat:@"resources/%@.png", name];
    SKTexture *texture = [[CCFileUtils sharedFileUtils] textureForSpriteFile:fullPath];
    if (!texture) return nil;
    return [[self class] spriteNodeWithTexture:texture];
}

@end
