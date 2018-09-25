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

typedef NS_ENUM(NSUInteger, CCPhysicsPanelItem)
{
    CCPhysicsEnablePhysics,
    CCPhysicsBodyShapePolygon,
    CCPhysicsBodyShapeCircle,
    CCPhysicsRadius,
    CCPhysicsDynamic,
    CCPhysicsAffectedByGravity,
    CCPhysicsAllowsRotation,
    CCPhysicsDensity,
    CCPhysicsFriction,
    CCPhysicsElasticity,
    CCPhysicsAllowsUserDragging,
    CCPhysicsBodyShapeTexture,
};

@class NodePhysicsBody;
@class PhysicsInspector;

@interface PhysicsHandler : NSObject

@property (assign, nonatomic) BOOL editingPhysicsBody;
@property (assign, nonatomic) NSCellStateValue selectedNodePhysicsEnabled;
@property (assign, nonatomic) BOOL physicsInspectorElementsEnabled;
@property (assign, nonatomic) BOOL physicsInspectorCanEnablePhysics;
@property (assign, nonatomic) BOOL physicsInspectorCanSelectTextureShape;
@property (assign, nonatomic) BOOL bodyShapeSupportsRadius;
@property (nonatomic,strong) NodePhysicsBody* selectedNodePhysicsBody;


// Shape
@property (assign, nonatomic) NSInteger bodyShape;
@property (assign, nonatomic) NSString *bodyShapeString;
@property (assign, nonatomic) float radius;
@property (assign, nonatomic) BOOL supportsTextureBodyShape;

// Basic physic props
@property (assign, nonatomic) NSCellStateValue dynamic;
@property (assign, nonatomic) NSCellStateValue staticRadioState;
@property (assign, nonatomic) NSCellStateValue affectedByGravity;
@property (assign, nonatomic) NSCellStateValue allowsRotation;
@property (assign, nonatomic) NSCellStateValue allowsUserDragging;

@property (assign, nonatomic) float density;
@property (assign, nonatomic) float friction;
@property (assign, nonatomic) float elasticity;

@property (strong, nonatomic) NSMutableDictionary *isMixedStateDict;
@property (strong, nonatomic) PhysicsInspector *physicsInspector;

- (void)willChangeSelection;
- (void)didChangeSelection;

- (void)loadSelectedNodesData;

- (void)togglePhysicsProperty:(id)panelItemSender;
- (void)updateSpriteKitPhysicsEditor:(SKNode *)editorView;
- (void)updatePhysicsMixedState;

/**
 Updates the state of the PhysicsHandler such that it is not referring to nodes, etc. from the old scene
 */
- (void)didReloadScene;

#pragma mark - Mouse Input

- (BOOL)mouseDown:(CGPoint)pos event:(NSEvent*)event;
- (BOOL)mouseDragged:(CGPoint)pos event:(NSEvent*)event;
- (BOOL)mouseUp:(CGPoint)pos event:(NSEvent*)event;



@end
