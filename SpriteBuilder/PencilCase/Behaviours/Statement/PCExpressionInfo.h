//
//  PCTokenStringInfo.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-17.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@class PCExpression;

/**
 * Stores information about an expression within a statement
 */
@interface PCExpressionInfo : MTLModel

@property (strong, nonatomic) NSUUID *UUID;
@property (strong, nonatomic) PCExpression *expression;
@property (assign, nonatomic) NSRange range;
@property (assign, nonatomic) NSInteger order;

@end
