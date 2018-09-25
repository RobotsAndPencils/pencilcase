//
//  SKNode+CropNodeNesting.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-08-13.
//
//

#import "SKNode+CropNodeNesting.h"

@implementation SKNode(CropNodeNesting)

- (void)alertChildrenToUpdateCropNode {
    for (SKNode *child in self.children) {
        if ([child conformsToProtocol:@protocol(PCNestedCropNodeContainer)]) {
            SKNode<PCNestedCropNodeContainer> *cropNodeContainer  = (SKNode<PCNestedCropNodeContainer> *)child;
            [cropNodeContainer updateCropNode];
        } else {
            [child alertChildrenToUpdateCropNode];
        }
    }
}

@end
