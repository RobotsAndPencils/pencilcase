/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2013 Apportable Inc
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

#define kCCBPhysicsMinimumDefaultCircleRadius 16

typedef NS_ENUM(NSInteger, PCPhysicsBodyShape) {
    PCPhysicsBodyShapePolygon = 0,
    PCPhysicsBodyShapeCircle,
    PCPhysicsBodyShapeTexture,
};

@interface NodePhysicsBody : NSObject

// Shape
@property (nonatomic,assign) int bodyShape;
@property (nonatomic,assign) float radius;
@property (nonatomic,strong) NSArray* points;

// Basic physic props
@property (nonatomic,assign) BOOL dynamic;
@property (nonatomic,assign) BOOL affectedByGravity;
@property (nonatomic,assign) BOOL allowsRotation;
@property (nonatomic,assign) BOOL allowsUserDragging;

@property (nonatomic,assign) float density;
@property (nonatomic,assign) float friction;
@property (nonatomic,assign) float elasticity;

// Init and serialization
- (id) initWithSpriteKitNode:(SKNode*) node;
- (id) initWithSerialization:(id)ser observingNode:(SKNode *)node;

- (id) serialization;

- (void) setupDefaultPolygonForSpriteKitNode:(SKNode*) node;
- (void) setupDefaultCircleForSpriteKitNode:(SKNode*) node;

@end
