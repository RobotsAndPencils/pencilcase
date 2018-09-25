//
//  PCToken.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-27.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "MTLModel.h"
#import "Constants.h"
#import <AppKit/AppKit.h>
#import "PCTokenDescriptor.h"
#import "PCJavaScriptRepresentable.h"

@interface PCToken : MTLModel <PCJavaScriptRepresentable>

@property (strong, nonatomic, readonly) NSObject<PCTokenDescriptor, PCJavaScriptRepresentable> *descriptor;
@property (assign, nonatomic, readonly) PCTokenType tokenType;
@property (copy, nonatomic, readonly) NSString *displayName;
@property (copy, nonatomic, readonly) NSAttributedString *attributedString;
@property (copy, nonatomic, readonly) NSUUID *sourceUUID;
@property (strong, nonatomic) PCToken *childToken;
@property (strong, nonatomic, readonly) NSArray *potentialChildTokens;
@property (assign, nonatomic, readonly) BOOL isReferenceType;
@property (assign, nonatomic) BOOL isInvalidReference;
@property (assign, nonatomic, readonly) PCNodeType nodeType;
@property (assign, nonatomic, readonly) PCPropertyType propertyType;
@property (assign, nonatomic, readonly) NSUUID *nodeUUID;

+ (instancetype)tokenWithDescriptor:(NSObject<PCTokenDescriptor, PCJavaScriptRepresentable> *)descriptor;
+ (NSArray *)tokenTypesThatMakeSenseToAppearInAnExpression;
+ (NSArray *)filterTokens:(NSArray *)tokens evaluationTypes:(NSArray *)types;
+ (NSArray *)filterTokens:(NSArray *)tokens forNodeTypes:(NSArray *)types;

- (BOOL)wantsHover;
- (void)setHovered:(BOOL)hovered;
- (NSColor *)hoverColor;

- (BOOL)isEqualReferenceToToken:(PCToken *)token;

+ (BOOL)tokens:(NSArray *)tokens containsTokenReferenceEqual:(PCToken *)token;

- (void)updateSourceUUIDsWithMapping:(NSDictionary *)mapping;
- (void)updateReferencesToNodeUUID:(NSUUID *)oldUUID toNewUUID:(NSUUID *)newUUID;

@end
