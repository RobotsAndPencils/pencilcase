//
// Created by Brandon Evans on 15-02-23.
//

#import "PCGetKeyValueStatement.h"
#import "PCExpression.h"
#import "PCStatementRegistry.h"
#import "PCStatement+Subclass.h"
#import "PCTokenVariableDescriptor.h"
#import "PCTokenKVSKeyDescriptor.h"
#import "PCBehavioursDataSource.h"

@interface PCGetKeyValueStatement ()

@property (nonatomic, strong) PCExpression *keyExpression;

@end

@implementation PCGetKeyValueStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCGetKeyValueStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.keyExpression = [[PCExpression alloc] init];
        self.keyExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeString) ];

        [self appendString:@"Then load value with key "];
        [self appendExpression:self.keyExpression];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyConfigurationDidChange:) name:PCKeyValueStoreKeyConfigChangedNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PCKeyValueStoreKeyConfigChangedNotification object:nil];
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    if (expression == self.keyExpression) {
        __weak __typeof(self) weakSelf = self;
        return [self createPopupInspectorForExpression:expression withItems:[self availableTokensForExpression:expression] onSave:^{
            PCTokenKVSKeyDescriptor *keyDescriptor = (PCTokenKVSKeyDescriptor *)weakSelf.keyExpression.token.descriptor;
            NSString *name = [self uniqueTokenNameForName:keyDescriptor.displayName];

            PCTokenEvaluationType tokenType = [Constants tokenEvaluationTypeForKeyType:keyDescriptor.config.type];

            PCTokenVariableDescriptor *descriptor = [PCTokenVariableDescriptor descriptorWithVariableName:name evaluationType:tokenType sourceUUID:weakSelf.UUID];
            self.valueToken = [PCToken tokenWithDescriptor:descriptor];
        }];
    }
    return nil;
}

- (BOOL)allowAdvancedEntryForExpression:(PCExpression *)expression {
    return NO;
}

- (NSArray *)availableTokensForExpression:(PCExpression *)expression {
    if (expression == self.keyExpression) {
        return [PCBehavioursDataSource keyValueTokens];
    }
    return @[];
}

- (BOOL)validateEvaluatedExpressionType {
    return YES;
}

#pragma mark - Notifications

- (void)keyConfigurationDidChange:(NSNotification *)notification {
    NSDictionary *info = notification.object;
    PCKeyValueStoreKeyConfig *oldConfig = info[@"old"];
    PCKeyValueStoreKeyConfig *newConfig = info[@"new"];
    PCTokenKVSKeyDescriptor *descriptor = (PCTokenKVSKeyDescriptor *)self.keyExpression.token.descriptor;

    if (![oldConfig isEqual:descriptor.config]) {
        return;
    }

    descriptor = [PCTokenKVSKeyDescriptor descriptorWithKeyConfig:newConfig];
    PCToken *token = [PCToken tokenWithDescriptor:descriptor];
    [self updateExpression:self.keyExpression withValue:token];
}

#pragma mark - Private

- (void)setValueToken:(PCToken *)valueToken {
    [self exposeToken:valueToken key:@"FetchedValue"];
}

@end

