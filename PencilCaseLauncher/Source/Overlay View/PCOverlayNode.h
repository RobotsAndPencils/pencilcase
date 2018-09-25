//
//  PCOverlayNode.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-06-29.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PCOverlayNode <NSObject>

/**
 The view will will be inserted into the overlay view and track the node. Child nodes that conform to PCOverlayNode will be inserted as children of this tracking view. To have children inserted into another view implement `childrenContainerView`. By default the view will track exactly the nodes frame. An alternative frame can be used by implementing `trackingFrame`.
 
 @return The view which will track the node.
 */
- (UIView *)trackingView;

@optional

/**
 Called every update after the tracking view has been updated to give the node a chance to make any updates it needs.
 
 @param frameChanged YES if the tracking views frame was changed this update.
 */
- (void)viewUpdated:(BOOL)frameChanged;

/**
 Optionally return an alternative NSView that children should insert into. This allows children to be inserted into a child of your tracking view.
 
 @return An alternative view which children will be inserted into.
 */
- (UIView *)childrenContainerView;

@end
