//
//  SKNode+CropNodeNesting.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-08-13.
//
//

#import <SpriteKit/SpriteKit.h>

@protocol PCNestedCropNodeContainer

/**
 Updates the crop node, usually this means searching for a parent crop node and clipping the mask based on the parent mask. 
 It is expected that [self alertChildrenToUpdateCropNode] should be called in the implementation of this method.
 */
- (void)updateCropNode;

@end

@interface SKNode(CropNodeNesting)

/**
 Finds all children of this node and informs the top-layer crop nodes nested beneath it to update their crop node. NOTE: In updateCropNode, this method
 should be called, and this method assumes as such. Once it hits a PCNestedCropNodeContainer, it does not navigate further down that branch of the node tree.
 Because updateCropNode should call this method on the children of that node, the full tree should be navigated.
 */
- (void)alertChildrenToUpdateCropNode;

@end
