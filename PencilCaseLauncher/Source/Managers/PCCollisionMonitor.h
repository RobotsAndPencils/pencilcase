//
//  PCCollisionMonitor.h
//  
//
//  Created by Stephen Gazzard on 2015-02-06.
//
//

#import <Foundation/Foundation.h>

@class PCJSContext;

@interface PCCollisionMonitor : NSObject

/**
 Call this method to register that we should begin monitoring collision events between the two specified nodes. This should always be called if we want collision monitoring - it will just defer to the physics implementation if both nodes are physics nodes.
 @param firstNode the first node to monitor collisions between.
 @param secondNode the second node to monitor collisions between.
 */
- (void)monitorCollisionsBetween:(SKNode *)firstNode and:(SKNode *)secondNode;

/**
 Checks for collisions and fires notifications to the javascript engine if any collisions are detected
 @param context The Javascript context the event(s) will be fired in
 */
- (void)notifyJavascriptIfAnyCollisionsAreOccurring:(PCJSContext *)context;


@end
