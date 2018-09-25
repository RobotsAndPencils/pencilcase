//
//  PCRunJavaScriptStatement.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 15-01-20.
//
//

#import "PCRunJavaScriptStatement.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCStatement+Subclass.h"

@interface PCRunJavaScriptStatement ()

@property (nonatomic, strong) PCExpression *scriptExpression;

@end

@implementation PCRunJavaScriptStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCRunJavaScriptStatement class]];
}

- (instancetype)init         {
    self = [super init];
    if (self) {
        self.scriptExpression = [[PCExpression alloc] init];
        self.scriptExpression.suggestedTokenTypes = [PCToken tokenTypesThatMakeSenseToAppearInAnExpression];

        [self appendString:@"Then evaluate the JavaScript "];
        [self appendExpression:self.scriptExpression];
    }
    return self;
}

#pragma mark - MTLModel

- (id)decodeValueForKey:(NSString *)key withCoder:(NSCoder *)coder modelVersion:(NSUInteger)modelVersion {
    if ([key isEqualToString:@"scriptExpression"]) {
        PCExpression *scriptExpression = [super decodeValueForKey:key withCoder:coder modelVersion:modelVersion];
        NSArray *supportedTokenTypes = [PCToken tokenTypesThatMakeSenseToAppearInAnExpression];
        scriptExpression.suggestedTokenTypes = supportedTokenTypes;
        return scriptExpression;
    }
    return [super decodeValueForKey:key withCoder:coder modelVersion:modelVersion];
}

#pragma mark - PCStatement

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    if (expression == self.scriptExpression) {
        return [self createValueInspectorForPropertyType:PCPropertyTypeJavaScript expression:self.scriptExpression];
    }
    return nil;
}

- (BOOL)allowAdvancedEntryForExpression:(PCExpression *)expression {
    return YES;
}

- (BOOL)canRunWithPrevious {
    return NO;
}

- (BOOL)canRunWithNext {
    return NO;
}

- (NSString *)javaScriptValidationTemplate {
    return @"%@";
}

- (BOOL)validateEvaluatedExpressionType {
    return NO;
}

@end
