//
//  PCExpressionTextView.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-17.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PCToken;
@class PCBehaviourJavaScriptValidator;

APPKIT_EXTERN NSString * const PCTokenPasteboardType;

@interface PCExpressionTextView : NSTextView

@property (copy, nonatomic) void(^tokenSelectedHandler)(PCToken *token);

- (NSArray *)expressionChunks;

@end
