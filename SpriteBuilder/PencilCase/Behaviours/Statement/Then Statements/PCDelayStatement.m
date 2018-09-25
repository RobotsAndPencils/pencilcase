//
//  PCDelayStatement.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 15-01-19.
//
//

#import "PCDelayStatement.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCBehavioursDataSource.h"
#import "PCStatement+Subclass.h"
#import "PCNumberExpressionInspector.h"

@interface PCDelayStatement ()

@property (nonatomic, strong) PCExpression *delayExpression;

@end

@implementation PCDelayStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCDelayStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.delayExpression = [[PCExpression alloc] init];
        self.delayExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNumber) ];
        [self appendString:@"Then wait for "];
        [self appendExpression:self.delayExpression];
        [self appendString:@" seconds"];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    PCNumberExpressionInspector *inspector = [self createFloatInspectorForExpression:expression];
    inspector.minValue = 0; // Anything less doesn't make sense, we can't travel through time :)
    inspector.maxValue = (CGFloat)PCJavaScriptNumberMax / 1000.0; // http://ecma262-5.com/ELS5_HTML.htm#Section_8.5, but in seconds since it'll be turned into milliseconds at runtime
    inspector.increment = 0.01; // Arbitrary reasonable number
    return inspector;
}

- (BOOL)evaluatesAsync {
    return YES;
}

@end
