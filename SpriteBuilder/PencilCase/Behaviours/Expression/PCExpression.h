//
//  PCExpression.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-19.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "Constants.h"
#import "PCToken.h"
#import "PCJavaScriptRepresentable.h"

@class PCTokenString;
@class PCStatement;

/**
 * An expression is a string containing multiple PCToken's. It can also be in basic mode - then it just has a simple value.
 */
@interface PCExpression : MTLModel <PCJavaScriptRepresentable>

/**
 * @discussion Advanced/basic mode. Eventually we want to treat these the same.
 */
@property (assign, nonatomic) BOOL isSimpleExpression;

/**
 * @discussion An array of PCTokenEvaluationType objects (wrapped in NSNumber) that are supported for suggestions
 *             If nil, will return the supported token types
 */
@property (strong, nonatomic) NSArray *suggestedTokenTypes;

/**
 * @discussion An array of PCTokenEvaluationType objects (wrapped in NSNumber) that are validated against
 */
@property (strong, nonatomic) NSArray *supportedTokenTypes;

/**
 * @discussion A token value representing the expresison in simple mode
 */
@property (strong, nonatomic) PCToken *token;

/**
 * @discussion Each element should either be an `NSString` or a `PCToken`
 */
@property (strong, nonatomic) NSArray *advancedChunks;

@property (weak, nonatomic) PCStatement *statement;

/**
 * In simple mode this means we have a `token` set. In advanced it means `advancedChunks` has at least 1 element
 */
- (BOOL)hasValue;

- (void)updateSourceUUIDsWithMapping:(NSDictionary *)mapping;
- (void)updateReferencesToNodeUUID:(NSUUID *)oldUUID toNewUUID:(NSUUID *)newUUID;

// Temporary validation
- (NSAttributedString *)validationErrorMessageForExpressionChunks:(NSArray *)chunks;

- (NSAttributedString *)advancedAttributedStringValueWithDefaultAttributes:(NSDictionary *)attributes highlightInvalid:(BOOL)highlightInvalid;
- (NSAttributedString *)simpleAttributedStringValueWithDefaultAttributes:(NSDictionary *)attributes;

@end
