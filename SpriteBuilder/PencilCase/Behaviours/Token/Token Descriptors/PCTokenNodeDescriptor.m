//
//  PCNodeTokenDescriptor.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-02.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Mantle/MTLModel+NSCoding.h>
#import "PCTokenNodeDescriptor.h"
#import "PCBehavioursDataSource.h"
#import "PCStatement.h"
#import "PCTokenAttachment.h"

@interface PCTokenNodeDescriptor ()

@property (copy, nonatomic, readwrite) NSUUID *nodeUUID;
@property (copy, nonatomic, readwrite) NSUUID *sourceUUID;
@property (assign, nonatomic, readwrite) PCNodeType nodeType;

@end

@implementation PCTokenNodeDescriptor

@synthesize token = _token;
@synthesize nodeUUID = _nodeUUID;

+ (instancetype)descriptorWithNodeUUID:(NSUUID *)UUID nodeType:(PCNodeType)nodeType {
    PCTokenNodeDescriptor *descriptor = [[PCTokenNodeDescriptor alloc] init];
    descriptor.nodeUUID = UUID;
    descriptor.sourceUUID = UUID;
    descriptor.nodeType = nodeType;
    return descriptor;
}

#pragma mark - PCTokenDescriptor

- (NSString *)displayName {
    return [PCBehavioursDataSource nameForObjectWithUUID:self.nodeUUID];
}

- (PCTokenType)tokenType {
    return PCTokenTypeValue;
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

- (void)updateReferencesToNodeUUID:(NSUUID *)oldUUID toNewUUID:(NSUUID *)newUUID {
    if ([self.sourceUUID isEqual:oldUUID]) {
        self.sourceUUID = newUUID;
        self.nodeUUID = newUUID;
    }
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

#pragma mark - JavaScriptRepresentable

- (NSString *)javaScriptRepresentation {
    return [NSString stringWithFormat:@"Creation.nodeWithUUID('%@')", [self.nodeUUID UUIDString]];
}

@end
