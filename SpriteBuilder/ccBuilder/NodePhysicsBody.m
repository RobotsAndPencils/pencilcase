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

#import "NodePhysicsBody.h"
#import "AppDelegate.h"
#import "PCSKShapeNode.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+SizeChangeBlock.h"

@interface NodePhysicsBody()

@property (copy, nonatomic) PCNodeSizeChangeBlock nodeSizeChangeBlock;

@end

@implementation NodePhysicsBody

- (id)initWithSpriteKitNode:(SKNode *)node {
    self = [super init];
    if (self) {
        if (![self setupDefaultCustomPhysicsBodyForSpriteKitNode:node]) {
            [self setupDefaultPolygonForSpriteKitNode:node];
        }

        _dynamic = YES;
        _affectedByGravity = YES;
        _allowsRotation = YES;
        _allowsUserDragging = YES;

        _density = 1.0f;
        _friction = 0.3f;
        _elasticity = 0.3f;

        [self observeSizeChangesForNode:node];
    }
    
    return self;
}

- (id)initWithSerialization:(id)ser observingNode:(SKNode *)node {
    self = [super init];
    if (!self) return NULL;
    
    // Shape
    _bodyShape = [ser[@"bodyShape"] intValue];
    _radius = [ser[@"radius"] ?: ser[@"cornerRadius"] floatValue];
    
    // Points
    NSArray* serPoints = [ser objectForKey:@"points"];
    NSMutableArray* points = [NSMutableArray array];
    for (NSArray* serPt in serPoints)
    {
        CGPoint pt = CGPointZero;
        pt.x = [[serPt objectAtIndex:0] floatValue];
        pt.y = [[serPt objectAtIndex:1] floatValue];
        [points addObject:[NSValue valueWithPoint:pt]];
    }
    
    self.points = points;
    
    // Basic physics props
    _dynamic = [[ser objectForKey:@"dynamic"] boolValue];
    _affectedByGravity = [[ser objectForKey:@"affectedByGravity"] boolValue];
    _allowsRotation = [[ser objectForKey:@"allowsRotation"] boolValue];
    _allowsUserDragging = [[ser objectForKey:@"allowsUserDragging"] boolValue];
    
    _density = [[ser objectForKey:@"density"] floatValue];
    _friction = [[ser objectForKey:@"friction"] floatValue];
    _elasticity = [[ser objectForKey:@"elasticity"] floatValue];

    [self observeSizeChangesForNode:node];

    return self;
}

- (void)observeSizeChangesForNode:(SKNode *)node {
    __weak typeof(self) _self = self;
    self.nodeSizeChangeBlock = ^(CGSize oldSize, CGSize newSize) {
        [_self updateWithChangeFromSize:oldSize toSize:newSize];
    };
    [node pc_registerSizeChangeBlock:self.nodeSizeChangeBlock];
}

- (void)dealloc {
    self.points = NULL;
}

- (id) serialization
{
    NSMutableDictionary* ser = [NSMutableDictionary dictionary];
    
    // Shape
    ser[@"bodyShape"] = @(_bodyShape);
    ser[@"radius"] = @(_radius);
    
    // Points
    NSMutableArray* serPoints = [NSMutableArray array];
    for (NSValue* val in _points)
    {
        CGPoint pt = [val pointValue];
        NSArray* serPt = [NSArray arrayWithObjects:
                       [NSNumber numberWithFloat:pt.x],
                       [NSNumber numberWithFloat:pt.y],
                       nil];
        [serPoints addObject:serPt];
    }
    [ser setObject:serPoints forKey:@"points"];
    
    // Basic physics props
    [ser setObject:[NSNumber numberWithBool:_dynamic] forKey:@"dynamic"];
    [ser setObject:[NSNumber numberWithBool:_affectedByGravity] forKey:@"affectedByGravity"];
    [ser setObject:[NSNumber numberWithBool:_allowsRotation] forKey:@"allowsRotation"];
    [ser setObject:[NSNumber numberWithBool:_allowsUserDragging] forKey:@"allowsUserDragging"];
    
    [ser setObject:[NSNumber numberWithFloat:_density] forKey:@"density"];
    [ser setObject:[NSNumber numberWithFloat:_friction] forKey:@"friction"];
    [ser setObject:[NSNumber numberWithFloat:_elasticity] forKey:@"elasticity"];
    
    return ser;
}

- (BOOL)setupDefaultCustomPhysicsBodyForSpriteKitNode:(SKNode *)node {
    if (![node conformsToProtocol:@protocol(CustomShapePhysicsBody)]) return NO;

    id<CustomShapePhysicsBody> customShapePhysicsBodyNode = (id<CustomShapePhysicsBody>)node;
    [customShapePhysicsBodyNode setDefaultPhysicsBodyParametersOn:self];
    return YES;
}

- (void)setupDefaultPolygonForSpriteKitNode:(SKNode *)node {
    _bodyShape = PCPhysicsBodyShapePolygon;
    self.radius = 0;
    
    float w = node.contentSize.width != 0 ? node.contentSize.width : 32;
    float h = node.contentSize.height != 0 ? node.contentSize.height : 32;
    
    // Calculate corners
    CGPoint a = CGPointMake(0, 0);
    CGPoint b = CGPointMake(0, h);
    CGPoint c = CGPointMake(w, h);
    CGPoint d = CGPointMake(w, 0);
    
    self.points = [NSArray arrayWithObjects:
                   [NSValue valueWithPoint:a],
                   [NSValue valueWithPoint:b],
                   [NSValue valueWithPoint:c],
                   [NSValue valueWithPoint:d],
                   nil];
}

- (void) setupDefaultCircleForSpriteKitNode:(SKNode*) node
{
    _bodyShape = PCPhysicsBodyShapeCircle;
    
    float radius = MAX(node.contentSize.width/2, node.contentSize.height/2);
    if (radius < kCCBPhysicsMinimumDefaultCircleRadius) radius = kCCBPhysicsMinimumDefaultCircleRadius;
    
    self.radius = radius;
    
    float w = node.contentSize.width;
    float h = node.contentSize.height;
    
    self.points = [NSArray arrayWithObject:[NSValue valueWithPoint:CGPointMake(w/2, h/2)]];
}


- (void) setBodyShape:(int)bodyShape
{
    if (bodyShape == _bodyShape) return;
    
    _bodyShape = bodyShape;
    
    if (bodyShape == PCPhysicsBodyShapePolygon)
    {
        [self setupDefaultPolygonForSpriteKitNode:[AppDelegate appDelegate].selectedSpriteKitNode];
    }
    else if (bodyShape == PCPhysicsBodyShapeCircle)
    {
        [self setupDefaultCircleForSpriteKitNode:[AppDelegate appDelegate].selectedSpriteKitNode];
    }
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*P*bodyShape"];
}

- (void) setRadius:(float)radius
{
    _radius = radius;
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*P*radius"];
}

- (void) setPoints:(NSArray *)points
{
    if (points == _points) return;
    _points = points;
}

- (void) setDynamic:(BOOL)dynamic
{
    _dynamic = dynamic;
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*P*dynamic"];
}

- (void) setAffectedByGravity:(BOOL)affectedByGravity
{
    _affectedByGravity = affectedByGravity;
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*P*affectedByGravity"];
}

- (void) setAllowsRotation:(BOOL)allowsRotation
{
    _allowsRotation = allowsRotation;
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*P*allowsRotation"];
}

- (void)setAllowsUserDragging:(BOOL)allowsUserDragging {
    _allowsUserDragging = allowsUserDragging;
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*P*allowsUserDragging"];
}

- (void) setDensity:(float)density
{
    _density = density;
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*P*density"];
}

- (void) setFriction:(float)friction
{
    _friction = friction;
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*P*friction"];
}

- (void) setElasticity:(float)elasticity
{
    _elasticity = elasticity;
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*P*elasticity"];    
}

- (void)updateWithChangeFromSize:(CGSize)oldSize toSize:(CGSize)newSize {
    if (CGSizeEqualToSize(newSize, oldSize)) return;
    
    CGFloat xScaleChange = newSize.width / oldSize.width;
    CGFloat yScaleChange = newSize.height / oldSize.height;
    
    NSMutableArray *newPoints = [NSMutableArray array];
    for (NSValue *pointValue in self.points) {
        CGPoint point = [pointValue pointValue];
        point.x *= xScaleChange;
        point.y *= yScaleChange;
        [newPoints addObject:[NSValue valueWithPoint:point]];
    }
    self.points = [newPoints copy];
    
    if (PCPhysicsBodyShapeCircle == _bodyShape) {
        CGFloat oldXRatio = oldSize.width / _radius;
        CGFloat oldYRatio = oldSize.height / _radius;
        CGFloat biggerRatio = MAX(oldXRatio, oldYRatio) / 2; //adjust from length to radius
        
        CGFloat largerSide = MAX(newSize.width, newSize.height) / 2;
        _radius = largerSide * biggerRatio;
    }
}


@end

