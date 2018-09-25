//
//  PCDrag.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-30.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCMultiDragTouch;

/**
 Represents a single finger dragging a single node
 */
@interface PCDrag : NSObject

@property (strong, nonatomic) PCMultiDragTouch *touch;
@property (strong, nonatomic) SKNode *draggingNode;
@property (strong, nonatomic) SKNode *fingerTrackingNode;
@property (strong, nonatomic) SKPhysicsJoint *joint;

@end
