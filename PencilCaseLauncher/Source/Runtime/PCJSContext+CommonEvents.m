//
//  PCJSContext+CommonEvents.m
//  
//
//  Created by Stephen Gazzard on 2015-02-10.
//
//

#import "PCJSContext+CommonEvents.h"
#import "SKNode+Javascript.h"

const BOOL PCCollisionAndCardUpdateTriggerLoggingEnabled = NO;

@implementation PCJSContext (CommonEvents)

- (void)triggerCollisionEventBetweenNode:(SKNode *)nodeA andNode:(SKNode *)nodeB {
    NSString *nodeAUUIDRepresentation = [NSString stringWithFormat:@"Creation.nodeWithUUID('%@')", nodeA.uuid];
    NSString *nodeBUUIDRepresentation = [NSString stringWithFormat:@"Creation.nodeWithUUID('%@')", nodeB.uuid];
    [self triggerEventOnJavaScriptRepresentation:nodeAUUIDRepresentation eventName:@"collision" arguments:@[ nodeA, nodeB ] loggingEnabled:PCCollisionAndCardUpdateTriggerLoggingEnabled];
    [self triggerEventOnJavaScriptRepresentation:nodeBUUIDRepresentation eventName:@"collision" arguments:@[ nodeB, nodeA ] loggingEnabled:PCCollisionAndCardUpdateTriggerLoggingEnabled];
}

@end
