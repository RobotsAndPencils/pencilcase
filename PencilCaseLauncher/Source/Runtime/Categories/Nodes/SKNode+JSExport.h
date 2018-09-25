//
//  SKNode+JSExport.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-20.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "NSObject+JSDataBinding.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+Template.h"
#import "SKNode+LifeCycle.h"

@protocol SKNodeExport <JSExport, NSObjectJSDataBindingExport>

@property (nonatomic, readonly) CGRect frame;
- (CGRect)calculateAccumulatedFrame;
@property (nonatomic) CGPoint position;
@property (nonatomic) CGFloat zPosition;
@property (nonatomic) CGFloat zRotation;
@property (nonatomic) CGFloat xScale;
@property (nonatomic) CGFloat yScale;
@property (nonatomic) CGFloat speed;
@property (nonatomic) CGFloat alpha;
@property (nonatomic, getter = isPaused) BOOL paused;
@property (nonatomic, getter = isHidden) BOOL hidden;
@property (nonatomic, getter=isUserInteractionEnabled) BOOL userInteractionEnabled;
@property (nonatomic, readonly) SKNode *parent;
@property (nonatomic, readonly) NSArray *children;
@property (nonatomic, copy) NSString *name;

// +LifeCycle
@property (strong, nonatomic) NSDate *addedAt;

- (instancetype)init;
- (void)addChild:(SKNode *)node;
- (void)insertChild:(SKNode *)node atIndex:(NSInteger)index;

- (void)removeFromParent;
- (void)removeChildrenInArray:(NSArray *)nodes;
- (void)removeAllChildren;

- (SKNode *)childNodeWithName:(NSString *)name;
- (NSArray *)objectForKeyedSubscript:(NSString *)name NS_AVAILABLE(10_10, 8_0);
- (BOOL)inParentHierarchy:(SKNode *)parent;
- (void)runAction:(SKAction *)action;
- (void)runAction:(SKAction *)action completion:(void (^)())block;
- (void)runAction:(SKAction *)action withKey:(NSString *)key;
- (BOOL)hasActions;
- (SKAction *)actionForKey:(NSString *)key;
- (void)removeActionForKey:(NSString *)key;
- (void)removeAllActions;
- (BOOL)containsPoint:(CGPoint)p;
- (SKNode *)nodeAtPoint:(CGPoint)p;
- (NSArray *)nodesAtPoint:(CGPoint)p;
- (CGPoint)convertPoint:(CGPoint)point fromNode:(SKNode *)node;
- (CGPoint)convertPoint:(CGPoint)point toNode:(SKNode *)node;
- (BOOL)intersectsNode:(SKNode *)node;

- (SKTexture *)__pc_createTexture;

// From CocosCompatability
@property (nonatomic, strong) id userObject;
@property (nonatomic, assign) CGFloat opacity;
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, assign) CGFloat scaleX;
@property (nonatomic, assign) CGFloat scaleY;
@property (nonatomic, assign) CGPoint scalePoint;
@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, assign) CGFloat skewX;
@property (nonatomic, assign) CGFloat skewY;
@property (nonatomic, assign, readonly) BOOL flipX;
@property (nonatomic, assign, readonly) BOOL flipY;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) CGPoint anchorPoint;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) BOOL physicsEnabled;

// SKNode+Template
- (void)applyTemplateNamed:(NSString *)name;

@end

@interface SKNode (JSExport) <SKNodeExport>

@end
