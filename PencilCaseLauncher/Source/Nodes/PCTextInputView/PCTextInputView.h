//
//  PCTextInputView.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-04-24.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCOverlayNode.h"

@interface PCTextInputView : SKSpriteNode <PCOverlayNode>

@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSString *fontName;
@property (assign, nonatomic) CGFloat fontSize;
@property (strong, nonatomic) SKTexture *backgroundSpriteFrame;

@end
