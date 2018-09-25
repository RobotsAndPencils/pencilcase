//
//  PCForceNode.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-03-18.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@interface PCForceNode : SKSpriteNode

@property (assign, nonatomic) BOOL enabled;
@property (assign, nonatomic) BOOL drawArrow;

- (void)applyForceToNodes:(NSArray *)nodes delta:(NSTimeInterval)delta;

@end
