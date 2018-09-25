//
//  PCTokenCardDescriptor.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-12-04.
//
//

#import "PCTokenCardDescriptor.h"
#import "PCBehavioursDataSource.h"
#import "Constants.h"
#import "PCTokenAttachment.h"
#import <Mantle/MTLModel+NSCoding.h>

@interface PCTokenCardDescriptor ()

@property (copy, nonatomic) NSUUID *cardUUID;
@property (assign, nonatomic) PCCardChangeType changeType;

@end

@implementation PCTokenCardDescriptor

@synthesize token = _token;

+ (instancetype)descriptorWithCardUUID:(NSUUID *)UUID {
    PCTokenCardDescriptor *descriptor = [[PCTokenCardDescriptor alloc] init];
    descriptor.cardUUID = UUID;
    descriptor.changeType = -1;
    return descriptor;
}

+ (instancetype)descriptorWithCardChangeType:(PCCardChangeType)changeType {
    PCTokenCardDescriptor *descriptor = [[PCTokenCardDescriptor alloc] init];
    descriptor.changeType = changeType;
    return descriptor;
}

+ (NSArray *)descriptorsForAllChangeTypes {
    NSArray *types = @[
                       @(PCCardChangeTypeNextCard),
                       @(PCCardChangeTypePreviousCard)
                       ];
    return Underscore.array(types).map(^id(NSNumber *type){
        return [self descriptorWithCardChangeType:[type integerValue]];
    }).unwrap;
}

#pragma mark - PCTokenDescriptor

- (NSString *)displayName {
    if (self.cardUUID) {
        return [PCBehavioursDataSource nameForCardWithUUID:self.cardUUID];
    }
    return [self displayStringForChangeType:self.changeType];
}

- (PCTokenType)tokenType {
    return PCTokenTypeValue;
}

- (BOOL)isReferenceType {
    return !!self.cardUUID;
}

- (PCTokenEvaluationType)evaluationType {
    return PCTokenEvaluationTypeCard;
}

- (NSAttributedString *)attributedDisplayName {
    return [PCTokenAttachment attachmentForToken:self.token];
}

#pragma mark - Private

- (NSString *)displayStringForChangeType:(PCCardChangeType)changeType {
    switch (changeType) {
        case PCCardChangeTypeNextCard: return @"NextCard";
        case PCCardChangeTypePreviousCard: return @"PreviousCard";
        default: return @"";
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

- (NSString *)javaScriptRepresentation {
    if (self.changeType == PCCardChangeTypeNextCard) {
        return @"'next'";
    }
    else if (self.changeType == PCCardChangeTypePreviousCard) {
        return @"'previous'";
    }

    return [NSString stringWithFormat:@"'%@'", [self.cardUUID UUIDString]];
}

@end
