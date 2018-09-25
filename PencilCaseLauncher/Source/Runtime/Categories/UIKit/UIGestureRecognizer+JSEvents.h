//
//  UIGestureRecognizer+JSEvents
//  PCPlayer
//
//  Created by brandon on 2014-02-25.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import SpriteKit;

@interface UIGestureRecognizer (JSEvents)

@property (nonatomic, weak, readonly) SKNode *pc_node;

- (instancetype)initWithJSEventHandlers;

@end
