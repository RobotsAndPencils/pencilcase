//
// Created by Brandon Evans on 15-02-23.
//

#import "PCSetKeyValueStatement.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCStatement+Subclass.h"
#import "PCBehavioursDataSource.h"
#import "PCTokenKVSKeyDescriptor.h"

@interface PCSetKeyValueStatement ()

@property (nonatomic, strong) PCExpression *valueExpression;
@property (nonatomic, strong) PCExpression *keyExpression;

@end

@implementation PCSetKeyValueStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCSetKeyValueStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.valueExpression = [[PCExpression alloc] init];
        self.valueExpression.suggestedTokenTypes = [PCToken tokenTypesThatMakeSenseToAppearInAnExpression];
        self.keyExpression = [[PCExpression alloc] init];
        self.keyExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeString) ];

        [self appendString:@"Then save value "];
        [self appendExpression:self.valueExpression withOrder:1];
        [self appendString:@" with key "];
        [self appendExpression:self.keyExpression withOrder:0];

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
            PCTokenKVSKeyDescriptor *descriptor = (PCTokenKVSKeyDescriptor *)weakSelf.keyExpression.token.descriptor;
            PCTokenEvaluationType evaluationType = [Constants tokenEvaluationTypeForKeyType:descriptor.config.type];
            weakSelf.valueExpression.supportedTokenTypes = @[ @(evaluationType) ];
        }];
    }
    else if (expression == self.valueExpression) {
        PCTokenKVSKeyDescriptor *descriptor = (PCTokenKVSKeyDescriptor *)self.keyExpression.token.descriptor;
        PCPropertyType propertyType = [Constants propertyTypeForKeyType:descriptor.config.type];
        return [self createValueInspectorForPropertyType:propertyType expression:expression];
    }
    return nil;
}

- (void)clearValuesForChangingExpression:(PCExpression *)expression toToken:(PCToken *)token {
    // If the key type hasn't changed then don't clear the value
    if (expression == self.keyExpression) {
        PCTokenKVSKeyDescriptor *descriptor = (PCTokenKVSKeyDescriptor *)self.keyExpression.token.descriptor;
        PCTokenKVSKeyDescriptor *newDescriptor = (PCTokenKVSKeyDescriptor *)token.descriptor;

        if (descriptor.config.type == newDescriptor.config.type) {
            return;
        }
    }
    [super clearValuesForChangingExpression:expression toToken:token];
}

- (NSArray *)availableTokensForExpression:(PCExpression *)expression {
    if (expression == self.keyExpression) {
        return [PCBehavioursDataSource keyValueTokens];
    }
    else if (expression == self.valueExpression) {
        NSArray *availableTokens = [self.delegate statementAvailableTokens:self];

        // Adding texture tokens here because there isn't a strong enough distinction between available and suggested tokens.
        // If we add texture tokens to the globally-available collection, they show up in the suggested tokens view but there's a _lot_ of them by default.
        // They _are_ globally-available, but until that view scales with token count more effectively, they shouldn't be displayed there.
        if ([self.valueExpression.supportedTokenTypes containsObject:@(PCTokenEvaluationTypeTexture)]) {
            availableTokens = [availableTokens arrayByAddingObjectsFromArray:[PCBehavioursDataSource textureTokens]];
        }

        // We need to allow the user to be able to add a node token and then choose a sub-property (say, a point)
        // If we restrict the supported token types to a point they won't be able to add the node in the first place
        // We want all of the usual tokens to appear in the expression view, but they're not all necessarily supported
        return [PCToken filterTokens:availableTokens evaluationTypes:[PCToken tokenTypesThatMakeSenseToAppearInAnExpression]];
    }
    return @[];
}

- (BOOL)allowAdvancedEntryForExpression:(PCExpression *)expression {
    return expression == self.valueExpression;
}

- (BOOL)evaluatesAsync {
    return YES;
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

    // Clear the value if the type changes
    if (oldConfig.type != newConfig.type) {
        PCTokenEvaluationType evaluationType = [Constants tokenEvaluationTypeForKeyType:descriptor.config.type];
        self.valueExpression.supportedTokenTypes = @[ @(evaluationType) ];
        [self updateExpression:self.valueExpression withValue:nil];
    }
}

@end

