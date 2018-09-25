//
//  SKNode+GeneralHelpers.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-06-19.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "SKNode+GeneralHelpers.h"
#import "SKNode+JavaScript.h"
#import "SKNode+LifeCycle.h"
#import "PCScene.h"
#import "PCOverlayNode.h"
#import "UIView+Snapshot.h"
#import "SKTexture+JSExport.h"
#import "PCSlideNode.h"

@implementation SKNode (GeneralHelpers)

- (BOOL)anyParentNotVisible {
    if (self.hidden) return YES;
    return [self.parent anyParentNotVisible];
}

- (SKNode *)nodeWithUUID:(NSString *)uuid {
    if ([self.uuid isEqualToString:uuid]) return self;
    for (SKNode *child in self.children) {
        SKNode *node = [child nodeWithUUID:uuid];
        if (node) return node;
    }
    return nil;
}

- (SKNode *)nodeWithClass:(Class)class {
    if ([self isKindOfClass:class]) return self;
    for (SKNode *child in self.children) {
        SKNode *node = [child nodeWithClass:class];
        if (node) return node;
    }
    return nil;
}

- (SKNode *)nodeNamed:(NSString *)name {
    if ([self.name isEqualToString:name]) return self;
    for (SKNode *child in self.children) {
        SKNode *node = [child nodeNamed:name];
        if (node) return node;
    }
    return nil;
}

- (PCScene *)pc_PCScene {
    if ([self.pc_scene isKindOfClass:[PCScene class]]) {
        return (PCScene *)self.pc_scene;
    }
    return nil;
}

- (SKTexture *)__pc_createTexture {
    SKView *view = self.scene.view;
    if (!view) return nil;

    // Remove rotation - necessary so we can match with UIKit
    CGFloat savedRotation = self.zRotation;
    self.zRotation = 0;
    SKTexture *texture = [view textureFromNode:self crop:self.frame];
    self.zRotation = savedRotation;

    CGRect rect = CGRectMake(0, 0, texture.size.width, texture.size.height);
    UIGraphicsBeginImageContext(rect.size);
    [[texture __pc_UIImage] drawInRect:rect];

    [self pc_drawOverlayContentForNode:self inRect:rect];

    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return [SKTexture textureWithImage:finalImage];
}

- (void)pc_drawOverlayContentForNode:(SKNode *)node inRect:(CGRect)rect {
    if ([node conformsToProtocol:@protocol(PCOverlayNode)]) {
        SKNode<PCOverlayNode> *overlayNode = node;
        UIView *view = [overlayNode trackingView];
        UIImage *image = [view pc_snapshotAfterScreenUpdates:NO];
        [image drawInRect:rect];
    }
    // else we should be rendering children UIKit
    // I can't figure this out right now and need to move on.
}

- (PCSlideNode *)slideNode {
    return [self.pc_scene nodeWithClass:[PCSlideNode class]];
}

@end
