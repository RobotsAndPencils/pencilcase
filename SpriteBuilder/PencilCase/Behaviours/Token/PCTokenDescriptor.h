//
//  PCTokenDescriptor.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-02.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

/**
 * A descriptor is used to have encodable behaviour for different tokens. These were initially blocks passed into token creation but needed to support NSKeyedArchiving.
 */
@class PCToken;

@protocol PCTokenDescriptor <NSObject, NSCopying, NSCoding>

@required
@property (copy, nonatomic, readonly) NSString *displayName;
@property (assign, nonatomic, readonly) PCTokenEvaluationType evaluationType;
@property (assign, nonatomic, readonly) PCTokenType tokenType;
@property (assign, nonatomic, readonly) BOOL isReferenceType;
@property (weak, nonatomic) PCToken *token;

@optional
@property (copy, nonatomic, readonly) NSAttributedString *attributedDisplayName;
@property (copy, nonatomic, readonly) NSUUID *sourceUUID;
@property (assign, nonatomic, readonly) PCNodeType nodeType;
@property (assign, nonatomic, readonly) PCPropertyType propertyType;
@property (copy, nonatomic, readonly) NSUUID *nodeUUID;
@property (copy, readonly, nonatomic) NSObject<NSCopying, NSSecureCoding> *value;

- (void)updateSourceUUIDWithMapping:(NSDictionary *)mapping;
- (void)updateReferencesToNodeUUID:(NSUUID *)oldUUID toNewUUID:(NSUUID *)newUUID;

@end