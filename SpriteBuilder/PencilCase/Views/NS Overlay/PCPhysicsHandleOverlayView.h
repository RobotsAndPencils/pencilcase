//
//  PCPhysicsHandleOverlayView.h
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-12-18.
//
//

#import <Cocoa/Cocoa.h>
#import <SpriteKit/SpriteKit.h>
#import "PCView.h"
#import "NodePhysicsBody.h"

@interface PCPhysicsHandleOverlayView : NSView

@property (strong, nonatomic) NSMutableArray *physicsHandles;

- (id)initWithFrame:(NSRect)frameRect;

- (void)removeAllPhysicsHandles;
- (void)drawPhysicsHandleForNode:(SKNode *)node withPoints:(NSMutableArray *)points physicsShape:(PCPhysicsBodyShape)physicsShape;
@end

