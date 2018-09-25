//
//  PCKeyPressedStatement.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-03.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCStatement.h"

@class PCExpression;

@interface PCKeyPressedStatement : PCStatement

// That this expression is public is an exception to the rule so that we can lookup the key press info when publishing in order to write the key press lookup file
@property (strong, nonatomic) PCExpression *keyExpression;

@end
