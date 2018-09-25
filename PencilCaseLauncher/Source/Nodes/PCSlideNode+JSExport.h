//
//  PCSlideNode+JSExport.h
//  
//
//  Created by Stephen Gazzard on 2015-02-06.
//
//


@import JavaScriptCore;

#import "PCSlideNode.h"
#import "PCCollisionMonitor.h"

@protocol PCSlideNodeExport <JSExport>

@property (strong, nonatomic, readonly) PCCollisionMonitor *collisionMonitor;
@property (assign, nonatomic) CGPoint gravity;

JSExportAs(objectWithUUID,
- (SKNode *)nodeWithUUID:(NSString *)uuid
);

JSExportAs(objectNamed,
- (SKNode *)nodeNamed:(NSString *)name
);

#pragma mark - Timelines

JSExportAs(playTimelineWithName,
- (void)playTimelineWithName:(NSString *)timelineName jsCallback:(JSValue *)completionCallback
);
- (void)stopTimelineWithName:(NSString *)timelineName;

@end

@interface PCSlideNode (JSExport) <PCSlideNodeExport>

// Wraps the implementation that takes a normal block so we can have the best of both worlds
- (void)playTimelineWithName:(NSString *)timelineName jsCallback:(JSValue *)jsCallback;

@end
