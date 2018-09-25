//
//  PCTokenCardDescriptor.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-12-04.
//
//

#import "MTLModel.h"
#import "PCTokenDescriptor.h"
#import "PCJavaScriptRepresentable.h"

typedef NS_ENUM(NSInteger, PCCardChangeType) {
    PCCardChangeTypeNextCard,
    PCCardChangeTypePreviousCard,
};

@interface PCTokenCardDescriptor : MTLModel <PCTokenDescriptor, PCJavaScriptRepresentable>

+ (instancetype)descriptorWithCardUUID:(NSUUID *)UUID;
+ (instancetype)descriptorWithCardChangeType:(PCCardChangeType)changeType;
+ (NSArray *)descriptorsForAllChangeTypes;

@end
