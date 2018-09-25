//
//  asdf.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-04.
//
//

#import <SpriteKit/SKNode.h>

@interface SKNode (HitTest)

- (BOOL)hitTestWithWorldRect:(CGPoint)startPoint endPoint:(CGPoint)endPoint;
- (BOOL)hitTestWithWorldPoint:(CGPoint)point;

/**
 Checks if the nodes rects overlap (does not check physics body shape)
 @param node The other node to compare against
 @returns YES if the nodes overlap, NO if they do not
 */
- (BOOL)pc_hitTestWithNode:(SKNode *)node;

@end
