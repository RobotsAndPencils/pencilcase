//
//  PCStatement+Subclass.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-28.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCStatement.h"

@class PCToken;
@class PCNumberExpressionInspector;
@class PCExpression;
@class PCPointExpressionInspector;

@interface PCStatement (Subclass)

- (void)updateExpression:(PCExpression *)expression withValue:(PCToken *)value;

/**
 * @discussion Common behaviour to expose a token. Handles undo/redo and notifying of old token dying.
 * @param token The token to expose. If nil, will remove the existing token for a given key.
 * @param key A key that can be used to uniquely identify the token within the statement. Different statements can use the same key. Most statements will only expose one token so the key can be anything. Nil or empty keys will cause this method to no-op.
 */
- (void)exposeToken:(PCToken *)token key:(id<NSCopying>)key;

/**
 * @discussion Shortcut for exposeToken:key: and provides the lowerCamelCase version of the token's name as the key. Only use this method for tokens that will not change. For example, this method shouldn't be used for multiple tokens which have the same use but would have different names. Specifically: When exposing a user-selected token, you'll end up with duplicates because each token will likely have a different name.
 */
- (void)exposeToken:(PCToken *)token;

- (void)clearValuesForChangingExpression:(PCExpression *)expression toToken:(PCToken *)token;
- (void)clearValuesForChangingExpression:(PCExpression *)expression advancedChunks:(NSArray *)chunks simpleMode:(BOOL)simpleMode;

// Inspector Helpers
- (NSViewController<PCExpressionInspector> *)createValueInspectorForPropertyType:(PCPropertyType)propertyType expression:(PCExpression *)expression name:(NSString *)name;
- (NSViewController<PCExpressionInspector> *)createValueInspectorForPropertyType:(PCPropertyType)propertyType expression:(PCExpression *)expression;
- (PCNumberExpressionInspector *)createFloatInspectorForExpression:(PCExpression *)expression;
- (NSViewController<PCExpressionInspector> *)createPopupInspectorForExpression:(PCExpression *)expression withItems:(NSArray *)items onSave:(dispatch_block_t)saveHandler;

/**
 * Default implementation returns tokens available to the current scope. Call super and filter the results further or just return your own tokens.
 */
- (NSArray *)availableTokensForExpression:(PCExpression *)expression;

@end
