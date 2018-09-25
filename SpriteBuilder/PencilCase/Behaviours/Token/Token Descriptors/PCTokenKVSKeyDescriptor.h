//
//  PCTokenKVSKeyDescriptor.h
//  SpriteBuilder
//
//  Created by Brandon Evans on 15-04-06.
//
//

#import "PCTokenDescriptor.h"
#import "PCJavaScriptRepresentable.h"
#import "PCKeyValueStoreKeyConfig.h"

@class PCKeyValueStoreKeyConfig;

@interface PCTokenKVSKeyDescriptor : NSObject <PCTokenDescriptor, PCJavaScriptRepresentable>

@property (nonatomic, strong, readonly) PCKeyValueStoreKeyConfig *config;

+ (PCTokenKVSKeyDescriptor *)descriptorWithKeyConfig:(PCKeyValueStoreKeyConfig *)config;

@property (copy, nonatomic, readonly) NSString *displayName;
@property (assign, nonatomic, readonly) PCTokenEvaluationType evaluationType;
@property (assign, nonatomic, readonly) PCTokenType tokenType;
@property (assign, nonatomic, readonly) BOOL isReferenceType;
@property (weak, nonatomic) PCToken *token;

@end
