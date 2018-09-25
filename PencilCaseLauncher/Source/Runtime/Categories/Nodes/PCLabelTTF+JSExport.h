//
//  PCLabelTTF+JSExport.h
//  PCPlayer
//
//  Created by Brandon on 2014-03-17.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCLabelTTF.h"
#import "NSObject+JSDataBinding.h"

@protocol PCLabelTTFExport <JSExport, NSObjectJSDataBindingExport>

@property (nonatomic, assign) CCTextAlignment horizontalAlignment;
@property (nonatomic, assign) CCVerticalTextAlignment verticalAlignment;
@property (nonatomic, copy) NSString *string;
@property (nonatomic, assign, readonly) CGPoint anchorPoint;

// From SKLabelNode
@property (nonatomic, copy) NSString *fontName;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic, retain) SKColor *fontColor;

@end

@interface PCLabelTTF (JSExport) <PCLabelTTFExport>

@end
