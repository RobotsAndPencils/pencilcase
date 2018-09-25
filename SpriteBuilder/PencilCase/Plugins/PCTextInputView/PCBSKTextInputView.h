//
//  PCBSKTextInputView.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-08-10.
//
//

#import <SpriteKit/SpriteKit.h>
#import "PCFontConsuming.h"

@interface PCBSKTextInputView : SKSpriteNode <PCFontConsuming>

@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSString *fontName;
@property (assign, nonatomic) CGFloat fontSize;
@property (strong, nonatomic) SKTexture *backgroundSpriteFrame;

@end
