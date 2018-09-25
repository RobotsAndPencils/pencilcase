//
//  SKNode+PositionHelper.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-06-24.
//
//

#import <SpriteKit/SpriteKit.h>

@interface SKNode(Snapping)

/**
 @returns A list of all sibling nodes (excluding self), sorted from nearest to furthest.
 */
- (NSArray *)siblingNodesSortedByDistance;

/**
*  Sets the position to integral values by rounding
*  Rounds up from 0.5, down otherwise
*/
- (void)alignToPixels;

@end
