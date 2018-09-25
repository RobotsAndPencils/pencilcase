//
//  PCSKShapeNode.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-14.
//
//

#import <SpriteKit/SpriteKit.h>
#import "PCShapeView.h"
#import "CustomShapePhysicsBody.h"
#import "PCOverlayView.h"

@interface PCSKShapeNode : SKSpriteNode <CustomShapePhysicsBody, PCOverlayNode>

@property (copy, nonatomic) NSMutableDictionary *shapeInfo;

- (void)setShapeType:(PCShapeType)shapeType;

@end
