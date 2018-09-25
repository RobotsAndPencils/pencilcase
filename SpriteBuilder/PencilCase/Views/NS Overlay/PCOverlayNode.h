//
//  PCOverlayNode.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-06-29.
//
//

#import <Foundation/Foundation.h>

@protocol PCOverlayTrackingView;

@protocol PCOverlayNode <NSObject>

/**
 The view will will be inserted into the overlay view and track the node. Child nodes that conform to PCOverlayNode will be inserted as children of this tracking view. To have children inserted into another view implement `childrenContainerView`. By default the view will track exactly the nodes frame. An alternative frame can be used by implementing `trackingFrame`.
 
 @return The view which will track the node.
 */
- (NSView<PCOverlayTrackingView> *)trackingView;

@optional

/**
 Called every update after the tracking view has been updated to give the node a chance to make any updates it needs.
 
 @param frameChanged YES if the tracking views frame was changed this update.
 */
- (void)viewUpdated:(BOOL)frameChanged;

/**
 Optionally return an alternative frame to use for the tracking view. By default the nodes frame will be used.
 
 @return A rect to use for the tracking view in node space.
 */
- (CGRect)trackingFrame;

@end