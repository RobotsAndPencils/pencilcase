//
//  PCSKMultiViewCellNode.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-09.
//
//

#import <SpriteKit/SpriteKit.h>
#import "PCNodeChildrenManagement.h"


@interface PCSKMultiViewCellNode : SKSpriteNode <PCNodeChildInsertion, PCNodeChildExport>

- (void)updateCropNode;

@end
