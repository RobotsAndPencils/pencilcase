//
//  PCPhysicsHandleInfo.h
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-12-18.
//
//

#import <Foundation/Foundation.h>
#import "NodePhysicsBody.h"

@interface PCPhysicsHandleInfo : NSObject

@property (strong, nonatomic) NSMutableArray *physicsBodyPoints;
@property (assign, nonatomic) PCPhysicsBodyShape shapeType;

- (id)initWithPoints:(NSMutableArray *)points andShapeType:(PCPhysicsBodyShape)shape;
- (NSBezierPath *)bezierPathForHandleInfo;

@end

