//
//  PCMultiDragHandler.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-29.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCMultiDragTouch;

/**
 Tracks touches and allows dragging, dropping, throwing nodes with dynamic physics bodies.
 */
@interface PCMultiDragHandler : NSObject

- (instancetype)initWithRootNode:(SKNode *)root;
/**
 Tear down the handler and it's recognizers.
 */
- (void)teardown;

- (void)update:(NSTimeInterval)currentTime;

@end
