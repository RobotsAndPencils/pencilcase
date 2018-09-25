//
//  UIColor+JSExport.m
//  PencilCaseJSDemo
//
//  Created by Brandon on 1/6/2014.
//  Copyright (c) 2014 RobotsAndPencils. All rights reserved.
//

#import "UIImage+JSExport.h"
#import "CCFileUtils.h"

@implementation UIImage (JSExport)

+ (instancetype)imageWithUUID:(NSString *)uuid {
    return [[CCFileUtils sharedFileUtils] UIImageForSpriteUUID:uuid];
}

+ (instancetype)imageWithRelativeImagePath:(NSString *)relativePath {
    return [[CCFileUtils sharedFileUtils] UIImageForSpriteFile:[@"resources" stringByAppendingPathComponent:relativePath]];
}

@end
