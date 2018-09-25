//
//  SKShapeNode+YosemiteBackport.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-06-30.
//
//

#import "SKShapeNode+YosemiteBackport.h"

@implementation SKShapeNode (YosemiteBackport)

+ (instancetype)pc_shapeNodeWithRect:(CGRect)rect {
    if ([self respondsToSelector:@selector(shapeNodeWithRect:)]) {
        return [self shapeNodeWithRect:rect];
    }
    
    CGPathRef path = CGPathCreateWithRect(rect, NULL);
    SKShapeNode *shapeNode = [[self alloc] init];
    shapeNode.path = path;
    CGPathRelease(path);
    return shapeNode;
}

@end
