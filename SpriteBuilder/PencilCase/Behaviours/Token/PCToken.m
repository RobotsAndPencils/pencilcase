//
//  PCToken.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-27.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCToken.h"
#import "PCBehavioursDataSource.h"
#import "BehavioursStyleKit.h"

@interface PCToken ()

@property (strong, nonatomic, readwrite) NSObject<PCTokenDescriptor, PCJavaScriptRepresentable> *descriptor;
@property (copy, nonatomic) NSString *lastKnownDisplayName;

@end

@implementation PCToken

#pragma mark - Public

+ (instancetype)tokenWithDescriptor:(NSObject<PCTokenDescriptor, PCJavaScriptRepresentable> *)descriptor {
    PCToken *token = [[self alloc] init];
    token.descriptor = descriptor;
    return token;
}

+ (NSArray *)tokenTypesThatMakeSenseToAppearInAnExpression {
    return @[
        @(PCTokenEvaluationTypeNumber),
        @(PCTokenEvaluationTypeBOOL),
        @(PCTokenEvaluationTypeString),
        @(PCTokenEvaluationTypePoint),
        @(PCTokenEvaluationTypeSize),
        @(PCTokenEvaluationTypeVector),
        @(PCTokenEvaluationTypeColor),
        @(PCTokenEvaluationTypeNode),
        @(PCTokenEvaluationTypeTexture),
        @(PCTokenEvaluationTypeImage),
        @(PCTokenEvaluationTypeScale)
    ];
}

+ (NSArray *)filterTokens:(NSArray *)tokens evaluationTypes:(NSArray *)types {
    NSMutableArray *filteredTokens = [NSMutableArray array];
    for (PCToken *token in tokens) {
        if ([types containsObject:@(token.descriptor.evaluationType)]) {
            [filteredTokens addObject:token];
        }
    }
    return [filteredTokens copy];
}

+ (NSArray *)filterTokens:(NSArray *)tokens forNodeTypes:(NSArray *)types {
    NSMutableArray *filteredTokens = [NSMutableArray array];
    for (PCToken *token in tokens) {
        if ([types containsObject:@(token.nodeType)]) {
            [filteredTokens addObject:token];
        }
    }
    return [filteredTokens copy];
}

- (void)setDescriptor:(NSObject<PCTokenDescriptor, PCJavaScriptRepresentable> *)descriptor {
    _descriptor.token = nil;
    _descriptor = descriptor;
    descriptor.token = self;
}

- (NSString *)displayName {
    NSString *displayName = self.descriptor.displayName;
    if ([displayName length] > 0) {
        self.lastKnownDisplayName = displayName;
    }
    else {
        displayName = self.lastKnownDisplayName ?: @"";
    }
    return displayName;
}

- (NSAttributedString *)attributedString {
    if ([self.descriptor respondsToSelector:@selector(attributedDisplayName)]) {
        return [self.descriptor attributedDisplayName];
    }
    NSColor *color = self.isInvalidReference ? [NSColor redColor] : [NSColor blueColor];
    return [[NSAttributedString alloc] initWithString:self.displayName attributes:@{ NSForegroundColorAttributeName: color }];
}

- (PCTokenType)tokenType {
    return self.descriptor.tokenType;
}

- (BOOL)isReferenceType {
    return self.descriptor.isReferenceType;
}

- (NSUUID *)sourceUUID {
    if ([self.descriptor respondsToSelector:@selector(sourceUUID)]) {
        return [self.descriptor sourceUUID];
    }
    return nil;
}

- (BOOL)wantsHover {
    return self.sourceUUID != nil;
}

- (void)setHovered:(BOOL)hovered {
    NSMutableDictionary *info = [@{
                                  PCTokenHighlightSourceStateKey: @(hovered),
                                  } mutableCopy];
    if (self.sourceUUID) {
        info[PCTokenHighlightSourceUUIDKey] = self.sourceUUID;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PCTokenHighlightSourceChangeNotification object:self userInfo:info];
}

- (NSColor *)hoverColor {
    return [BehavioursStyleKit lightBlueColor];
}

- (PCNodeType)nodeType {
    if ([self.descriptor respondsToSelector:@selector(nodeType)]) {
        return [self.descriptor nodeType];
    }
    return PCNodeTypeUnknown;
}

- (PCPropertyType)propertyType {
    if ([self.descriptor respondsToSelector:@selector(propertyType)]) {
        return [self.descriptor propertyType];
    }
    return PCPropertyTypeNotSupported;
}

- (NSUUID *)nodeUUID {
    if ([self.descriptor respondsToSelector:@selector(nodeUUID)]) {
        return [self.descriptor nodeUUID];
    }
    return nil;
}

- (NSArray *)potentialChildTokens {
    switch (self.descriptor.evaluationType) {
        case PCTokenEvaluationTypeNode:
            return [PCBehavioursDataSource propertyTokensForNodeToken:self];
        case PCTokenEvaluationTypeProperty:
            return [PCBehavioursDataSource subPropertyTokensForPropertyToken:self];
        default:
            return [PCBehavioursDataSource subPropertyTokensForPropertyType:[Constants propertyTypeFromEvaluationType:self.descriptor.evaluationType]];
    }
}

#pragma mark - MTLModel

+ (NSSet *)excludedPropertyKeys {
    return [NSSet setWithArray:@[]];
}

+ (NSSet *)propertyKeys {
    NSMutableSet *keys = [[super propertyKeys] mutableCopy];
    for (id key in [self excludedPropertyKeys]) {
        [keys removeObject:key];
    }
    return [keys copy];
}

#pragma mark - Custon equality

+ (NSSet *)excludedIsReferenceEqualPropertyKeys {
    return [NSSet setWithArray:@[ @"isInvalidReference", @"childToken", @"lastKnownDisplayName" ]];
}

+ (NSSet *)isEqualReferencePropertyKeys {
    NSMutableSet *keys = [[self propertyKeys] mutableCopy];
    for (id key in [self excludedIsReferenceEqualPropertyKeys]) {
        [keys removeObject:key];
    }
    return [keys copy];
}

- (BOOL)isEqualReferenceToToken:(PCToken *)token {
    if (self == token) return YES;
    if (![token isMemberOfClass:self.class]) return NO;

    for (NSString *key in self.class.isEqualReferencePropertyKeys) {
        id selfValue = [self valueForKey:key];
        id modelValue = [token valueForKey:key];

        BOOL valuesEqual = ((selfValue == nil && modelValue == nil) || [selfValue isEqual:modelValue]);
        if (!valuesEqual) return NO;
    }
    
    return YES;
}

+ (BOOL)tokens:(NSArray *)tokens containsTokenReferenceEqual:(PCToken *)token {
    return [[tokens filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(PCToken *each, NSDictionary *bindings) {
        return [each isEqualReferenceToToken:token];
    }]] count] > 0;
}

- (void)updateSourceUUIDsWithMapping:(NSDictionary *)mapping {
    if ([self.descriptor respondsToSelector:@selector(updateSourceUUIDWithMapping:)]) {
        [self.descriptor updateSourceUUIDWithMapping:mapping];
    }
}

- (void)updateReferencesToNodeUUID:(NSUUID *)oldUUID toNewUUID:(NSUUID *)newUUID {
    if ([self.descriptor respondsToSelector:@selector(updateReferencesToNodeUUID:toNewUUID:)]) {
        [self.descriptor updateReferencesToNodeUUID:oldUUID toNewUUID:newUUID];
    }
}

#pragma mark - JavaScriptRepresentable

- (NSString *)javaScriptRepresentation {
    NSString *representation = [self.descriptor javaScriptRepresentation];

    PCToken *token = self;
    if (token) {
        while (token.childToken) {
            token = token.childToken;
            representation = [representation stringByAppendingFormat:@".%@", [token.descriptor javaScriptRepresentation]];
        }
    }
    return representation;
}

@end
