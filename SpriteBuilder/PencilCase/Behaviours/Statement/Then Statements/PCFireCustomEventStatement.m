//
//  PCFireCustomEventStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-03.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <GRMustache/GRMustacheTemplate.h>
#import "PCFireCustomEventStatement.h"
#import "PCStatement+Subclass.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"

@interface PCFireCustomEventStatement ()

@property (strong, nonatomic) PCExpression *eventExpression;

@end

@implementation PCFireCustomEventStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCFireCustomEventStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.eventExpression = [[PCExpression alloc] init];
        [self appendString:@"Then fire event "];
        [self appendExpression:self.eventExpression];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    if (expression == self.eventExpression) {
        return [self createValueInspectorForPropertyType:PCPropertyTypeString expression:expression];
    }
    return nil;
}

- (BOOL)allowAdvancedEntryForExpression:(PCExpression *)expression {
    return NO;
}

@end