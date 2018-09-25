//
//  PCContextData.h
//  Pods
//
//  Created by Stephen Gazzard on 2015-05-12.
//
//

#import "RPJSCoreModule.h"

@interface PCContextData : NSObject <RPJSCoreModule>

/**
 @discussion Should be called when a card changes, to ensure that our data monitors are not still monitoring with callbacks into a card that doesn't exist anymore.
 */
+ (void)cleanupDataMonitoring;

@end
