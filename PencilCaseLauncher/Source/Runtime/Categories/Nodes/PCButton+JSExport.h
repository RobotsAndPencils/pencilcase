//
//  PCButton+JSExport.h
//  PCPlayer
//
//  Created by Brandon on 2014-03-25.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "NSObject+JSDataBinding.h"
#import "PCButton.h"

@protocol PCButtonExport <JSExport, NSObjectJSDataBindingExport>

@property (strong, nonatomic, readonly) SKSpriteNode *background;
@property (strong, nonatomic, readonly) SKLabelNode *label;
@property (assign, nonatomic) BOOL zoomWhenHighlighted;
@property (assign, nonatomic) float horizontalPadding;
@property (assign, nonatomic) float verticalPadding;
@property (copy, nonatomic) NSString *title;
@property (assign, nonatomic) BOOL togglesSelectedState;

- (void)setBackgroundTexture:(SKTexture *)texture forState:(PCControlState)state;

@end

@interface PCButton (JSExport) <PCButtonExport>

@end
