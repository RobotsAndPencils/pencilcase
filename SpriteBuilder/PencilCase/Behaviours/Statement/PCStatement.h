//
//  PCExpressionString.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-17.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "Constants.h"
#import "PCJavaScriptRepresentable.h"

@class PCTokenAttachmentCell;
@class PCExpression;
@protocol PCExpressionInspector;
@class PCStatement;
@class PCToken;

@protocol PCStatementDelegate <NSObject>

- (NSArray *)statementAvailableTokens:(PCStatement *)statement;
- (void)statementNeedsDisplay:(PCStatement *)statement;

@end

/**
 * This is what a When or Then is made of. A string containing multiple PCExpression spots.
 */
@interface PCStatement : MTLModel <PCJavaScriptRepresentable>

@property (copy, nonatomic, readonly) NSUUID *UUID;

@property (strong, nonatomic, readonly) NSArray *exposedTokens;
/**
 *  Used to determine if, when generating JS representations, the statement's script needs to be wrapped in a Promise in order to evaluate in the correct order when a callback is yielding to an array. Specifically, if this property returns NO (most common), then the representation will be wrapped.
 */
@property (assign, nonatomic, readonly) BOOL evaluatesAsync;
@property (assign, nonatomic, readonly) BOOL canRunWithPrevious;
@property (assign, nonatomic, readonly) BOOL canRunWithNext;
@property (copy, nonatomic, readonly) NSString *javaScriptValidationTemplate;
@property (assign, nonatomic) id<PCStatementDelegate> delegate;
@property (assign, nonatomic, readonly) BOOL validateEvaluatedExpressionType;

+ (NSUUID *)newUUIDFrom:(NSUUID *)uuid mapping:(NSDictionary *)dictionary;

- (instancetype)appendString:(NSString *)string;
- (instancetype)appendEmptyExpression;
- (instancetype)appendEmptyExpressionWithOrder:(NSInteger)order;
- (instancetype)appendExpression:(PCExpression *)expression;
- (instancetype)appendExpression:(PCExpression *)expression withOrder:(NSInteger)order;

- (NSAttributedString *)attributedString;
/**
 * @discussion If you change an expression you need to invalidate this so the `attributedString` property is regenerated.
 */
- (void)invalidateAttributedString;

- (BOOL)validateExpressions;

// Working with links for click events
- (NSRange)rangeOfLink:(NSString *)link;
- (PCExpression *)expressionForLink:(NSString *)link;

- (BOOL)matchesSearch:(NSString *)search;

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression;
- (BOOL)allowAdvancedEntryForExpression:(PCExpression *)expression;
- (NSArray *)availableTokensForExpression:(PCExpression *)expression;
- (NSString *)uniqueTokenNameForName:(NSString *)name;

- (void)updateExpression:(PCExpression *)expression withAdvancedChunks:(NSArray *)chunks isSimpleMode:(BOOL)simpleMode;

- (void)regenerateUUID;
- (void)updateReferencesToNodeUUID:(NSUUID *)oldUUID toNewUUID:(NSUUID *)newUUID;

@end
