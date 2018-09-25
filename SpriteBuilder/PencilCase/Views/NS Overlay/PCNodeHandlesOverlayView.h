//
//  PCNodeHandlesOverlayView.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-03-10.
//
//

#import <Cocoa/Cocoa.h>

@class SKNode;

/**
  This class handles drawing node information for overlay views. For starters, it will only handle the anchor point handle, but should we desire to draw the general selection handles, that would go here as well.
 */
@interface PCNodeHandlesOverlayView : NSView

/**
 Removes all anchor point handles that are being rendered in the view
 */
- (void)removeAnchorPoints;

/**
 Adds an anchor point handle to the view at the given position.
 @param position The position that the anchor point should be added, in space local to this view.
 */
- (void)showAnchorPointAtPosition:(CGPoint)position;

@end
