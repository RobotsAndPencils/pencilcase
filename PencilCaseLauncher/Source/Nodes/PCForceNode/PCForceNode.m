//
//  PCForceNode.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-03-18.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCForceNode.h"
#import "SKNode+LifeCycle.h"
#import "SKNode+CoordinateConversion.h"

@interface PCForceNode ()

@end

@implementation PCForceNode

- (void)pc_didEnterScene {
    [super pc_didEnterScene];
    [self setup];
}

#pragma mark - Public

- (void)applyForceToNodes:(NSArray *)nodes delta:(NSTimeInterval)delta {
    if (!self.enabled) return;
    
    [nodes enumerateObjectsUsingBlock:^(SKNode *node, NSUInteger idx, BOOL *stop) {
        SKPhysicsBody *body = node.physicsBody;
        if (!body) return;
        
        // Calculate distance between nodes using world space (might have different parents)
        CGPoint worldPoint = [self pc_convertToWorldSpace:self.anchorPoint];
        CGPoint nodeWorldPoint = [node.parent pc_convertToWorldSpace:node.position];
        CGFloat distance = MAX(30, sqrtf(pc_CGPointLengthSquare(pc_CGPointSubtract(worldPoint, nodeWorldPoint))));
        
        // Calculate scale for x/y based on rotation
        CGFloat rotation = -self.zRotation;
        CGFloat yRatio = cosf(rotation);
        CGFloat xRatio = sinf(rotation);

        // Force based on our height squared
        CGFloat force = 25000;
        CGFloat scale = 0.5; // Arbitrarily picked to make default arrow size apply an expected ammount of force
        force = force * pow(self.size.height * scale, 2);
        
        // Distance has inverse exponential effect on force
        CGFloat xForce = force * xRatio * pow(distance, -2);
        CGFloat yForce = force * yRatio * pow(distance, -2);
        
        // Arbitrary max force to prevent overflows and divide by 0's
        CGFloat max = 10000 * body.mass;
        xForce = MIN(xForce, max);
        yForce = MIN(yForce, max);

        [body applyForce:CGVectorMake(xForce, yForce)];
    }];
}

#pragma mark - Private

- (void)setup {
    if (self.drawArrow) {
        self.texture = [SKTexture textureWithImageNamed:@"force-arrow"];
    }
}

#pragma mark - Properties

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    self.hidden = !self.enabled;
}

@end
