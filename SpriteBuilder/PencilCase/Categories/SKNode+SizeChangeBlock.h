//
//  SKNode+SizeChangeBlock.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-10-23.
//
//

#import <SpriteKit/SpriteKit.h>

typedef void(^PCNodeSizeChangeBlock)(CGSize oldSize, CGSize newSize);

@interface SKNode (SizeChangeBlock)

- (void)pc_registerSizeChangeBlock:(PCNodeSizeChangeBlock)block;

@end
