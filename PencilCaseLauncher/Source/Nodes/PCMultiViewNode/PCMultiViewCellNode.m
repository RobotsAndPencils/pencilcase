//
//  PCMultiViewCellNode.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-06-19.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCMultiViewCellNode.h"
#import "SKNode+LifeCycle.h"
#import "SKNode+CocosCompatibility.h"
#import "SKCropNode+Nesting.h"
#import "SKNode+CropNodeNesting.h"

@interface PCMultiViewCellNode () <PCNestedCropNodeContainer>

@property (strong, nonatomic) SKCropNode *cropNode;

@end

@implementation PCMultiViewCellNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cropNode = [SKCropNode node];
        self.cropNode.maskNode = [SKSpriteNode node];
        self.cropNode.position = CGPointZero;
        self.contentnode = [SKNode node];
        [self.cropNode addChild:self.contentnode];
        [self addChild:self.cropNode];
    }
    return self;
}

- (void)addChild:(SKNode *)node {
    if (node == self.cropNode) {
        [super addChild:node];
    } else {
        [self.contentnode addChild:node];
    }
}

- (void)pc_didMoveToParent {
    [super pc_didMoveToParent];
    [self updateCropNode];
}

- (void)pc_didEnterScene {
    [super pc_didEnterScene];
    [self updateCropNode];
}

- (void)pc_presentationDidStart {
    [super pc_presentationDidStart];
    [self updateCropNode];
}

- (void)updateCropNode {
    SKSpriteNode *maskNode = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:self.contentSize];
    maskNode.position = CGPointZero;
    maskNode.anchorPoint = CGPointZero;
    self.cropNode.maskNode = [self.cropNode constrainMaskToParentCropNodes:maskNode inScene:self.pc_scene];
    self.cropNode.position = CGPointZero;
    [self alertChildrenToUpdateCropNode];
}

- (void)setSize:(CGSize)size {
    [super setSize:size];
    [self updateCropNode];
}

@end
