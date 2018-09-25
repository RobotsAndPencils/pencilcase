//
//  PCJSContext+CommonEvents.h
//  
//
//  Created by Stephen Gazzard on 2015-02-10.
//
//

#import "PCJSContext.h"

extern const BOOL PCCollisionAndCardUpdateTriggerLoggingEnabled;

@interface PCJSContext (CommonEvents)

/**
 Triggers the necessary collision events between the specified nodes. Will trigger events on both nodes, not just whichever node is specified first.
 @param nodeA One of the two nodes to be involved in the collision events
 @param nodeB One of the two nodes to be involved in the collision events
 */
- (void)triggerCollisionEventBetweenNode:(SKNode *)nodeA andNode:(SKNode *)nodeB;

@end
