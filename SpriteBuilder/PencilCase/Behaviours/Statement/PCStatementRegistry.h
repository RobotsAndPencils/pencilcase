//
//  PCStatementRegistry.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-24.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCStatement;

@interface PCStatementRegistry : NSObject

@property (strong, nonatomic, readonly) NSArray *whenStatementClasses;
@property (strong, nonatomic, readonly) NSArray *thenStatementClasses;

+ (instancetype)sharedInstance;

- (void)registerWhenStatementClass:(Class)klass;
- (void)registerThenStatementClass:(Class)klass;

- (NSArray *)instancesOfAllWhenStatements;
- (NSArray *)instancesOfAllThenStatements;

@end
