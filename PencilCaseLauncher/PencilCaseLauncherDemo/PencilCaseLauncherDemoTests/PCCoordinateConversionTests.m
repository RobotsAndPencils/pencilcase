//
//  PCCoordinateConversionTests.m
//  PencilCaseLauncherDemo
//
//  Created by Stephen Gazzard on 2015-06-24.
//  Copyright (c) 2015 Robots & Pencils. All rights reserved.
//


#import <XCTest/XCTest.h>
#import <SpriteKit/SpriteKit.h>
#import "SKNode+CoordinateConversion.h"

#define RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) / (CGFloat)M_PI * 180.0f)
#define DEGREES_TO_RADIANS(__ANGLE__) ((CGFloat)M_PI * (__ANGLE__) / 180.0f)

static inline CGFloat randomFloat(CGFloat max) {
    return (CGFloat)rand() / RAND_MAX * max;
}

@interface PCCoordinateConversionTests : XCTestCase

@end

@implementation PCCoordinateConversionTests

- (void)testNodeToWorldTransform {
    // Create leaf node
    SKNode *child = [SKNode node];
    child.position = CGPointMake(randomFloat(100), randomFloat(100));
    child.zRotation = randomFloat(M_PI * 2.0);
    child.scale = randomFloat(5.0);

    SKNode *leafChild = child;
    SKNode *parent;

    CGFloat compoundScale = child.xScale;
    CGFloat compoundRotation = child.zRotation;

    // Create a bunch of parents with random positions/scales/rotations to generate a node graph
    NSUInteger numberOfParents = arc4random_uniform(5) + 5;
    do {
        parent = [SKNode node];
        parent.position = CGPointMake(randomFloat(100), randomFloat(100));
        parent.zRotation = randomFloat(M_PI * 2.0);
        parent.scale = randomFloat(5.0);
        [parent addChild:child];

        compoundScale *= parent.xScale;
        compoundRotation += parent.zRotation;

        child = parent;
    } while ((numberOfParents -= 1) > 0);

    // Get the transform scale and rotation
    CGAffineTransform transform = [leafChild pc_nodeToWorldTransform];
    CGFloat transformScale = sqrt(pow(transform.a, 2) + pow(transform.c, 2));
    // From CGAffineTransform docs: "In OS X, a positive value specifies clockwise rotation and a negative value specifies counterclockwise rotation."
    // This is the opposite behaviour to SpriteKit on OS X so we change the sign here
    CGFloat transformRotation = atan2(transform.b, transform.a);

    // Need to make sure that both the transform and compound rotation values are in 0 <= theta <= 2pi
    while (compoundRotation > M_PI * 2.0) {
        compoundRotation -= M_PI * 2.0;
    }
    while (transformRotation < 0) {
        transformRotation += M_PI * 2.0;
    }

    XCTAssertEqualWithAccuracy(transformScale, compoundScale, 0.001, @"nodeToWorldTransform fails when scaled");
    XCTAssertEqualWithAccuracy(transformRotation, compoundRotation, 0.001, @"nodeToWorldTransform fails when rotated");
}

@end
