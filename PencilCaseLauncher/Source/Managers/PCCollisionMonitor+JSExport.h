//
//  PCCollisionMonitor+JSExport.h
//  
//
//  Created by Stephen Gazzard on 2015-02-06.
//
//

@import JavaScriptCore;

#import "PCCollisionMonitor.h"

@protocol PCCollisionMonitorExport <JSExport>

JSExportAs(monitorCollisions,
- (void)monitorCollisionsBetween:(SKNode *)node and:(SKNode *)node
);

@end

@interface PCCollisionMonitor (JSExport) <PCCollisionMonitorExport>

@end
