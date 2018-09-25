//
//  PCNodeCollisionHandler.h
//  
//
//  Created by Brandon Evans on 2014-09-17.
//
//

@import JavaScriptCore;
@import SpriteKit;

@interface PCNodeCollisionHandler : NSObject

@property (nonatomic, strong, readonly) SKNode *node;
@property (nonatomic, strong, readonly) SKNode *otherNode;
@property (nonatomic, strong, readonly) JSValue *handler;

- (instancetype)initWithNode:(SKNode *)node otherNode:(SKNode *)otherNode handler:(JSValue *)handler;

@end
