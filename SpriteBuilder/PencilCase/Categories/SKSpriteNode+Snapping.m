//
//  SKSpriteNode+Snapping.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-06-25.
//
//

#import "SKSpriteNode+Snapping.h"

@implementation SKSpriteNode(Snapping)

- (void)setLeft:(CGFloat)left {
    self.position = CGPointMake(left + self.frame.size.width * self.anchorPoint.x, self.position.y);
}

- (void)setRight:(CGFloat)right {
    self.position = CGPointMake(right - self.frame.size.width * (1 - self.anchorPoint.x), self.position.y);
}

- (void)setCenterX:(CGFloat)centerX {
    self.position = CGPointMake(centerX - self.frame.size.width * (0.5f - self.anchorPoint.x), self.position.y);
}

- (void)setTop:(CGFloat)top {
    self.position = CGPointMake(self.position.x,  top - self.frame.size.height * (1 - self.anchorPoint.y));
}

- (void)setBottom:(CGFloat)bottom {
    self.position = CGPointMake(self.position.x,  bottom + self.frame.size.height * self.anchorPoint.y);
}

- (void)setCenterY:(CGFloat)centerY {
    self.position = CGPointMake(self.position.x,  centerY - self.frame.size.height * (0.5f - self.anchorPoint.y));
}

@end
