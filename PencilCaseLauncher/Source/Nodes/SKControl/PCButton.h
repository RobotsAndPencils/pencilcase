//
//  SKButton.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-29.
//
//

#import "PCControl.h"
#import "PCControlSubclass.h"

@class CCSpriteFrame;

@interface PCButton : PCControl

@property (strong, nonatomic, readonly) SKSpriteNode *background;
@property (strong, nonatomic, readonly) SKLabelNode *label;
@property (assign, nonatomic) BOOL zoomWhenHighlighted;
@property (assign, nonatomic) float horizontalPadding;
@property (assign, nonatomic) float verticalPadding;
@property (copy, nonatomic) NSString *title;
@property (assign, nonatomic) BOOL togglesSelectedState;

- (void)setBackgroundTexture:(SKTexture *)texture forState:(PCControlState)state;

@end
