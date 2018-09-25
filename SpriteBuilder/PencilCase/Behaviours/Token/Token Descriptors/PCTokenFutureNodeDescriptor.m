//
//  PCTokenFutureNodeDescriptor.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-02.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCTokenFutureNodeDescriptor.h"
#import <Mantle/MTLModel+NSCoding.h>
#import "PCTokenAttachment.h"
#import "NSString+CamelCase.h"
#import "PCStatement.h"
#import "PCBehavioursDataSource.h"

@interface PCTokenFutureNodeDescriptor ()

@property (copy, nonatomic) NSString *displayName;
@property (assign, nonatomic) PCNodeType nodeType;
@property (copy, nonatomic) NSUUID *sourceUUID;

@end

@implementation PCTokenFutureNodeDescriptor

@synthesize token = _token;

+ (instancetype)descriptorWithType:(PCNodeType)type variableName:(NSString *)name sourceUUID:(NSUUID *)UUID {
    PCTokenFutureNodeDescriptor *descriptor = [[PCTokenFutureNodeDescriptor alloc] init];
    descriptor.displayName = name;
    descriptor.sourceUUID = UUID;
    descriptor.nodeType = type;
    return descriptor;
}

#pragma mark - PCTokenDescriptor

- (PCTokenType)tokenType {
    return PCTokenTypePredicate;
}

- (BOOL)isReferenceType {
    return YES;
}

- (PCTokenEvaluationType)evaluationType {
    return PCTokenEvaluationTypeNode;
}

- (NSAttributedString *)attributedDisplayName {
    return [PCTokenAttachment attachmentForToken:self.token];
}

- (void)updateSourceUUIDWithMapping:(NSDictionary *)mapping {
    self.sourceUUID = [PCStatement newUUIDFrom:self.sourceUUID mapping:mapping];
}

#pragma mark - MTLModel

+ (NSSet *)excludedPropertyKeys {
    return [NSSet setWithArray:@[ @"token" ]];
}

+ (NSSet *)propertyKeys {
    NSMutableSet *keys = [[super propertyKeys] mutableCopy];
    for (id key in [self excludedPropertyKeys]) {
        [keys removeObject:key];
    }
    return [keys copy];
}

#pragma mark - PCJavaScriptRepresentable

- (NSString *)javaScriptRepresentation {
    return [self.displayName pc_lowerCamelCaseString];
}

@end
