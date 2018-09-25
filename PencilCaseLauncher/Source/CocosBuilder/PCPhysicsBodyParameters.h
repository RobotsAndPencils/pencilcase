//
//  PCPhysicsBodyParameters.h
//  
//
//  Created by Stephen Gazzard on 2015-02-04.
//
//

#import <SpriteKit/SpriteKit.h>

@interface PCPhysicsBodyParameters : NSObject

@property (assign, nonatomic) NSInteger bodyShape;
@property (assign, nonatomic) CGFloat cornerRadius;
@property (assign, nonatomic) CGFloat friction;
@property (assign, nonatomic) CGFloat density;
@property (assign, nonatomic) CGFloat elasticity;
@property (strong, nonatomic) NSArray *points;

@property (assign, nonatomic) BOOL dynamic;
@property (assign, nonatomic) BOOL affectedByGravity;
@property (assign, nonatomic) BOOL allowsRotation;
@property (assign, nonatomic) BOOL allowsUserDragging;

@property (assign, nonatomic) CGPoint originalAnchorPoint;

- (SKPhysicsBody *)createPhysicsBodyForNode:(SKNode *)node;
+ (instancetype)defaultPhysicsParamsForNode:(SKNode *)node;

@end
