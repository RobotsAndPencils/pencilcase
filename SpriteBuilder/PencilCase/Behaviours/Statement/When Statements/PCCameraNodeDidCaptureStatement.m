//
//  PCCameraNodeDidCaptureStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-03.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <GRMustache/GRMustacheTemplate.h>
#import "PCCameraNodeDidCaptureStatement.h"
#import "PCStatement+Subclass.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCTokenVariableDescriptor.h"

@interface PCCameraNodeDidCaptureStatement ()

@property (strong, nonatomic) PCExpression *cameraNodeExpression;

@end

@implementation PCCameraNodeDidCaptureStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerWhenStatementClass:[PCCameraNodeDidCaptureStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cameraNodeExpression = [[PCExpression alloc] init];
        self.cameraNodeExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];

        [self appendString:@"When camera and photos view "];
        [self appendExpression:self.cameraNodeExpression];
        [self appendString:@" captures an image"];

        [self exposeToken:[PCToken tokenWithDescriptor:[PCTokenVariableDescriptor descriptorWithVariableName:@"Captured Image" evaluationType:PCTokenEvaluationTypeTexture sourceUUID:self.UUID]] key:@"capturedImage"];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    if (expression == self.cameraNodeExpression) {
        return [self createPopupInspectorForExpression:expression withItems:[self cameraCaptureTokensForExpression:expression] onSave:nil];
    }
    return nil;
}

#pragma mark - Private

- (NSArray *)cameraCaptureTokensForExpression:(PCExpression *)expression {
    return [PCToken filterTokens:[self availableTokensForExpression:expression] forNodeTypes:@[ @(PCNodeTypeCameraNode) ]];
}

@end