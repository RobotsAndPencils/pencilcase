//
//  PCSelectPhotoFromLibraryStatement.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-02-25.
//
//

#import "PCSelectPhotoFromLibraryStatement.h"
#import "PCStatementRegistry.h"
#import "PCTokenVariableDescriptor.h"
#import "PCToken.h"
#import "PCStatement+Subclass.h"
#import "PCExpression.h"
#import "AppDelegate.h"

@interface PCSelectPhotoFromLibraryStatement()

@property (strong, nonatomic) PCExpression *nodeExpression;

@end

@implementation PCSelectPhotoFromLibraryStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCSelectPhotoFromLibraryStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.nodeExpression = [[PCExpression alloc] init];
        self.nodeExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];
        
        [self appendString:@"Then show image selector pointing at "];
        [self appendExpression:self.nodeExpression];

        [self exposeToken:[PCToken tokenWithDescriptor:[PCTokenVariableDescriptor descriptorWithVariableName:@"Fetched Photo" evaluationType:PCTokenEvaluationTypeTexture sourceUUID:self.UUID]]];
    }
    return self;
}

- (BOOL)evaluatesAsync {
    return YES;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    if (expression == self.nodeExpression) {
        return [self createPopupInspectorForExpression:self.nodeExpression withItems:[self availableTokensForExpression:self.nodeExpression] onSave:nil];
    }
    return nil;
}

@end
