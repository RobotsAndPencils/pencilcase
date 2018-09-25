//
//  PCExpressionInspector.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-24.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@class PCExpression;

@protocol PCExpressionInspector <NSObject>

@property (copy, nonatomic) void(^saveHandler)();
- (NSView *)initialFirstResponder;

@end
