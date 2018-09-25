//
//  asdf.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-04.
//
//

#import <SpriteKit/SKNode.h>

NSArray *pc_pointsOfPath(NSBezierPath *path);

@interface SKNode (HitTest)

- (BOOL)pc_hitTestWithWorldRect:(CGPoint)startPoint endPoint:(CGPoint)endPoint;
- (BOOL)pc_hitTestWithWorldPoint:(CGPoint)point;
- (NSBezierPath *)pc_bezierPathFromRect:(NSRect)rect withAnchorPoint:(CGPoint)anchorPoint andRotationInDegrees:(CGFloat)rotation;
- (CGRect)pc_smallestRectFromPath:(NSBezierPath *)path;

@end
