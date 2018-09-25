//
//  PCRulersLayer.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-08-06.
//
//

#import <SpriteKit/SpriteKit.h>

@interface PCRulersNode : SKNode


- (void)setup;

- (void)updateWithSize:(CGSize)winSize stageOrigin:(CGPoint)stageOrigin zoom:(CGFloat)zoom;

- (void)mouseEntered:(NSEvent *)event;

- (void)mouseExited:(NSEvent *)event;

- (void)updateMousePos:(CGPoint)pos;

@end
