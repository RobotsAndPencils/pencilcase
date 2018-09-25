//
//  PCExpressionViewController.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-17.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PCExpression;
@class PCStatement;
@protocol PCExpressionInspector;
@class PCBehaviourJavaScriptValidator;

@interface PCExpressionViewController : NSViewController

@property (strong, nonatomic, readonly) NSViewController<PCExpressionInspector> *simpleInspector;
@property (copy, nonatomic) void(^finishedHandler)(BOOL shouldSave, PCExpression *expression, BOOL isSimple, NSArray *advancedChunks);
@property (copy, nonatomic) void(^didLayouthandler)();

/**
 @returns whether or not this view should be dismissed in response to user action at this time
 */
@property (readonly, nonatomic) BOOL shouldClose;

- (instancetype)initWithExpression:(PCExpression *)expression inspector:(NSViewController<PCExpressionInspector> *)inspector advancedAllowed:(BOOL)advancedAllowed suggestedTokens:(NSArray *)suggestedTokens;

- (NSView *)initialFirstResponder;

- (void)save;
- (void)cleanupUndo;

@end
