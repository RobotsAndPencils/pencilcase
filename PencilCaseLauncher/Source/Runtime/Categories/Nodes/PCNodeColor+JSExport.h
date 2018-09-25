//
//  PCNodeColor+JSExport.h
//  PCPlayer
//
//  Created by Brandon on 2/4/2014.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

@import JavaScriptCore;
#import "PCNodeColor.h"
#import "NSObject+JSDataBinding.h"

@protocol PCNodeColorExport <JSExport, NSObjectJSDataBindingExport>

@property (nonatomic) CGFloat colorBlendFactor;
@property (nonatomic, retain) SKColor *color;
@property (nonatomic) SKBlendMode blendMode;
@property (nonatomic) CGPoint anchorPoint;
@property (nonatomic) CGSize size;

@end

@interface PCNodeColor (JSExport) <PCNodeColorExport>

@end
