//
//  PCPlaySoundStatement.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 15-01-19.
//
//

#import "PCPlaySoundStatement.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCBehavioursDataSource.h"
#import "PCStatement+Subclass.h"
#import "PCTokenValueDescriptor.h"
#import "PCResourceManager.h"

@interface PCPlaySoundStatement ()

@property (nonatomic, strong) PCExpression *soundExpression;

@end

@implementation PCPlaySoundStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCPlaySoundStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.soundExpression = [[PCExpression alloc] init];
        self.soundExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeString) ];

        [self appendString:@"Then play sound "];
        [self appendExpression:self.soundExpression];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    if (expression == self.soundExpression) {
        return [self createPopupInspectorForExpression:expression withItems:[self soundTokens] onSave:nil];
    }
    return nil;
}

- (BOOL)allowAdvancedEntryForExpression:(PCExpression *)expression {
    return expression == self.soundExpression;
}

- (NSArray *)availableTokensForExpression:(PCExpression *)expression {
    if (expression == self.soundExpression) {
        return [self soundTokens];
    }
    return [super availableTokensForExpression:expression];
}

#pragma mark - PCJavaScriptRepresentable

- (BOOL)evaluatesAsync {
    return YES;
}

#pragma mark - Private

- (NSArray *)soundTokens {
    NSArray *tokens = Underscore.array([[PCResourceManager sharedManager] allResources]).filter(^BOOL(PCResource *resource) {
        return resource.type == PCResourceTypeAudio;
    }).map(^PCToken *(PCResource *resource) {
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:[resource.filePath lastPathComponent] evaluationType:PCTokenEvaluationTypeString value:resource.uuid];
        return [PCToken tokenWithDescriptor:descriptor];
    }).unwrap;
    return tokens;
}

@end
