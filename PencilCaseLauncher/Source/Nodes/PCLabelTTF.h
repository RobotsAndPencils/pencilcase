//
//  PCLabelTTF.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-21.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "CCBTypes.h"

@interface PCLabelTTF : SKSpriteNode

@property (nonatomic, copy) NSString *string;
@property (nonatomic, strong) SKColor *fontColor;
@property (nonatomic, copy) NSString *fontName;
@property (nonatomic) CGFloat fontSize;

//Backwards compatibility
@property (nonatomic, assign) CCTextAlignment horizontalAlignment;
@property (nonatomic, assign) CCVerticalTextAlignment verticalAlignment;

@end
