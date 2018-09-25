//
//  PCTokenVariableDescriptor.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-04.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCTokenVariableDescriptor.h"
#import <Mantle/MTLModel+NSCoding.h>
#import "PCTokenAttachment.h"
#import "NSString+CamelCase.h"
#import "PCStatement.h"

@interface PCTokenVariableDescriptor ()

@property (copy, nonatomic) NSString *name;
@property (assign, nonatomic) PCTokenEvaluationType evaluationType;
@property (copy, nonatomic) NSUUID *sourceUUID;

@end

@implementation PCTokenVariableDescriptor

@synthesize token = _token;

+ (instancetype)descriptorWithVariableName:(NSString *)name evaluationType:(PCTokenEvaluationType)evaluationType sourceUUID:(NSUUID *)sourceUUID {
    PCTokenVariableDescriptor *descriptor = [[PCTokenVariableDescriptor alloc] init];
    descriptor.name = name;
    descriptor.evaluationType = evaluationType;
    descriptor.sourceUUID = sourceUUID;
    return descriptor;
}

#pragma mark - PCTokenDescriptor

- (NSString *)displayName {
    return self.name;
}

- (PCTokenType)tokenType {
    return PCTokenTypeVariable;
}

- (BOOL)isReferenceType {
    return YES;
}

- (NSAttributedString *)attributedDisplayName {
    return [PCTokenAttachment attachmentForToken:self.token];
}

- (void)updateSourceUUIDWithMapping:(NSDictionary *)mapping {
    self.sourceUUID = [PCStatement newUUIDFrom:self.sourceUUID mapping:mapping];
}

#pragma mark - Private

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

#pragma mark - JavaScriptRepresentable

- (NSString *)javaScriptRepresentation {
    NSString *name = [self.name pc_lowerCamelCaseString];
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet symbolCharacterSet];
    [characterSet addCharactersInString:@":"];
    name = [[name componentsSeparatedByCharactersInSet:characterSet] componentsJoinedByString:@"_"];
    return name;
}

@end
