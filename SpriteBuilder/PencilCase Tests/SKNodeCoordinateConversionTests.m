//
//  SKNodeCoordinateConversionTests.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-08-01.
//
//

#import <SpriteKit/SpriteKit.h>
#import <XCTest/XCTest.h>
#import <tgmath.h>

#import "SKNode+CoordinateConversion.h"

#define RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) / (CGFloat)M_PI * 180.0f)
#define DEGREES_TO_RADIANS(__ANGLE__) ((CGFloat)M_PI * (__ANGLE__) / 180.0f)

CGFloat const PCTestFloatAccuracy = 0.001;

static inline CGFloat randomFloat(CGFloat max) {
    return (CGFloat)rand() / RAND_MAX * max;
}

@interface SKNode (Tests)

- (CGFloat)pc_convertRotationInDegreesToWorldSpace:(CGFloat)rotation;
- (CGFloat)pc_convertRotationInDegreesToNodeSpace:(CGFloat)rotation;

@end

@interface SKNodeCoordinateConversionTests : XCTestCase

@end

@implementation SKNodeCoordinateConversionTests

- (void)testNodeToParentTransform {
    SKNode *child = [SKNode node];
    child.position = CGPointMake(randomFloat(100), randomFloat(100));
    child.zRotation = randomFloat(M_PI * 2.0);
    child.scale = randomFloat(5.0);
    
    SKNode *parent = [SKNode node];
    [parent addChild:child];
    child.position = CGPointMake(randomFloat(100), randomFloat(100));
    child.zRotation = randomFloat(M_PI * 2.0);
    child.scale = randomFloat(5.0);
    
    CGAffineTransform transform = [child pc_nodeToParentTransform];
    CGFloat transformScale = sqrt(pow(transform.a, 2) + pow(transform.c, 2));
    CGFloat transformRotation = atan2(transform.b, transform.a);

    while (transformRotation < 0) {
        transformRotation += M_PI * 2.0;
    }
    while (transformRotation > M_PI * 2.0) {
        transformRotation -= M_PI * 2.0;
    }

    XCTAssertEqualWithAccuracy(transformScale, child.xScale, PCTestFloatAccuracy, @"nodeToParentTransform fails when scaled");
    XCTAssertEqualWithAccuracy(transformRotation, child.zRotation, PCTestFloatAccuracy, @"nodeToParentTransform fails when rotated");
}

- (void)testConvertRotationInDegreesToWorldSpace {
    SKNode *child = [SKNode node];
    child.position = CGPointMake(randomFloat(100), randomFloat(100));
    child.zRotation = randomFloat(M_PI * 2.0);
    child.scale = randomFloat(5.0);
    
    SKNode *leafChild = child;
    SKNode *parent;

    CGFloat compoundRotation = child.zRotation;
    
    // Create a bunch of parents with random positions/scales/rotations to generate a node graph
    NSUInteger numberOfParents = arc4random_uniform(5) + 5;
    do {
        parent = [SKNode node];
        parent.position = CGPointMake(randomFloat(100), randomFloat(100));
        parent.zRotation = randomFloat(M_PI * 2.0);
        parent.scale = randomFloat(5.0);
        [parent addChild:child];

        compoundRotation += parent.zRotation;
        
        child = parent;
    } while ((numberOfParents -= 1) > 0);
    
    CGFloat convertedRotation = [leafChild.parent pc_convertRotationInDegreesToWorldSpace:RADIANS_TO_DEGREES(leafChild.zRotation)];
    compoundRotation = RADIANS_TO_DEGREES(compoundRotation);
    
    XCTAssertEqualWithAccuracy(convertedRotation, compoundRotation, PCTestFloatAccuracy, @"pc_convertRotationInDegreesToWorldSpace: fails when rotated");
}

- (void)testConvertRotationInDegreesToNodeSpace {
    SKNode *child = [SKNode node];
    child.position = CGPointMake(randomFloat(100), randomFloat(100));
    child.zRotation = randomFloat(M_PI * 2.0);
    child.scale = randomFloat(5.0);
    
    SKNode *leafChild = child;
    SKNode *parent;
    
    CGFloat compoundRotation = child.zRotation;
    
    // Create a bunch of parents with random positions/scales/rotations to generate a node graph
    NSUInteger numberOfParents = arc4random_uniform(5) + 5;
    do {
        parent = [SKNode node];
        parent.position = CGPointMake(randomFloat(100), randomFloat(100));
        parent.zRotation = randomFloat(M_PI * 2.0);
        parent.scale = randomFloat(5.0);
        [parent addChild:child];
        
        compoundRotation += parent.zRotation;
        
        child = parent;
    } while ((numberOfParents -= 1) > 0);
    
    CGFloat preConversionRotation = RADIANS_TO_DEGREES(leafChild.zRotation);
    
    CGFloat worldSpaceRotation = [leafChild.parent pc_convertRotationInDegreesToWorldSpace:RADIANS_TO_DEGREES(leafChild.zRotation)];
    CGFloat nodeSpaceRotation = [leafChild.parent pc_convertRotationInDegreesToNodeSpace:worldSpaceRotation];
    
    XCTAssertEqualWithAccuracy(preConversionRotation, nodeSpaceRotation, PCTestFloatAccuracy, @"pc_convertRotationInDegreesToNodeSpace: fails when rotated");
}

@end
