//
//  PC3DNode+JSExport.h
//  PencilCase
//
//  Created by Michael Beauregard on 02/27/2015.
//  Copyright (c) 2015 Robots and Pencils. All rights reserved.
//

@import JavaScriptCore;
#import "PC3DAnimation.h"
#import "NSObject+JSDataBinding.h"

@protocol PC3DAnimationExport <JSExport, NSObjectJSDataBindingExport>

@property (strong, nonatomic) NSString *skeletonName;
@property (assign, nonatomic) NSUInteger repeatCount;
@property (assign, nonatomic) CGFloat fadeInDuration;
@property (assign, nonatomic) CGFloat fadeOutDuration;
@property (assign, nonatomic) BOOL repeatForever;

@end

@interface PC3DAnimation (JSExport) <PC3DAnimationExport>

@end
