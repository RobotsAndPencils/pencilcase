//
//  PCTokenKVSKeyDescriptor.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 15-04-06.
//
//

#import "PCTokenKVSKeyDescriptor.h"
#import "PCKeyValueStoreKeyConfig.h"

@interface PCTokenKVSKeyDescriptor ()

@property (nonatomic, strong, readwrite) PCKeyValueStoreKeyConfig *config;

@end

@implementation PCTokenKVSKeyDescriptor

+ (PCTokenKVSKeyDescriptor *)descriptorWithKeyConfig:(PCKeyValueStoreKeyConfig *)config {
    PCTokenKVSKeyDescriptor *descriptor = [[PCTokenKVSKeyDescriptor alloc] init];
    descriptor.config = config;
    return descriptor;
}

- (BOOL)isEqual:(id)other {
    if (other == self) return YES;
    if (![other isKindOfClass:[self class]]) return NO;

    PCTokenKVSKeyDescriptor *otherDescriptor = (PCTokenKVSKeyDescriptor *)other;
    return [otherDescriptor.config isEqual:self.config];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }

    _config = [aDecoder decodeObjectForKey:@"config"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.config forKey:@"config"];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [PCTokenKVSKeyDescriptor descriptorWithKeyConfig:self.config];
}

#pragma mark - PCTokenDescriptor

- (NSString *)displayName {
    if (PCIsEmpty(self.config.collectionName)) {
        return self.config.key;
    }
    return [NSString stringWithFormat:@"%@:%@", self.config.collectionName, self.config.key];
}

- (PCTokenEvaluationType)evaluationType {
    return PCTokenEvaluationTypeString;
}

- (PCTokenType)tokenType {
    return PCTokenTypeValue;
}

- (BOOL)isReferenceType {
    return NO;
}

#pragma mark - PCJavaScriptRepresentable

- (NSString *)javaScriptRepresentation {
    return [NSString stringWithFormat:@"\"%@\", \"%@\"", self.config.key, self.config.collectionName];
}

@end
