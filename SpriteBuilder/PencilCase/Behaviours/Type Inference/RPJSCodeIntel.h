//
//  RPJSCodeIntel.h
//  RPJSCodeIntel
//
//  Created by Brandon Evans on 2014-10-01.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

@import Foundation;

@interface RPJSCodeIntel : NSObject

/**
 *  Create a new code intel object
 *
 *  @param script          The JavaScript script string that you want insight into
 *  @param typeDefinitions An array of type definitions (as dictionaries) that follow the format here: http://ternjs.net/doc/manual.html#typedef
 *
 *  @return A new code intel object
 */
- (instancetype)initWithScript:(NSString *)script typeDefinitions:(NSArray *)typeDefinitions;

/**
 *  Looks up type information from the script's AST at a particular line and column offset
 *
 *  @param lineNumber The 0-indexed line number
 *  @param column     The 0-indexed column number
 *  @param error      nil unless there was an error finding type information at the given line/column in the script
 *
 *  @return The type name
 */
- (NSDictionary *)typeInformationForLineNumber:(NSInteger)lineNumber column:(NSInteger)column error:(NSError **)error;

/**
 *  Looks up type information from the script's AST for the entire expression
 *
 *  @param error nil unless there was an error finding the returned type for the entire expression
 *
 *  @return The type name
 */
- (NSDictionary *)typeInformationForExpression:(NSError **)error;

/**
 * Validates the return value of a script against an expected Object token evaluation type
 * See the implementation of +[Constants javaScriptObjectEvaluationTypes] for the list of supported types
 */
- (BOOL)validateObjectValueOfScript:(NSString *)script expectedType:(PCTokenEvaluationType)type;

@end

