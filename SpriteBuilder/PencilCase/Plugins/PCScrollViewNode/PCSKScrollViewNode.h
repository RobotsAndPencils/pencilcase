//
//  PCSKScrollViewNode.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-11.
//
//

#import <SpriteKit/SpriteKit.h>
#import "PCNodeChildrenManagement.h"
#import "PCOverlayView.h"
#import "PCFocusableNode.h"
#import "SKNode+CropNodeNesting.h"

@interface PCSKScrollViewNode : SKSpriteNode <PCNodeChildInsertion, PCNodeChildExport, PCOverlayNode, PCFocusableNode, PCNestedCropNodeContainer>

- (CGPoint)editingOffset;

@end
