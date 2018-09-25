//
//  PCStatementRegistry.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-24.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCStatementRegistry.h"
#import "PCRunJavaScriptStatement.h"
#import "PCSetKeyValueStatement.h"
#import "PCGetKeyValueStatement.h"

@interface PCStatementRegistry ()

@property (strong, nonatomic) NSMutableArray *mutableWhenStatementClasses;
@property (strong, nonatomic) NSMutableArray *mutableThenStatementClasses;

@end

@implementation PCStatementRegistry

+ (instancetype)sharedInstance {
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mutableWhenStatementClasses = [NSMutableArray array];
        self.mutableThenStatementClasses = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Public

- (void)registerWhenStatementClass:(Class)klass {
    [self.mutableWhenStatementClasses addObject:klass];
}

- (void)registerThenStatementClass:(Class)klass {
    [self.mutableThenStatementClasses addObject:klass];
}

- (NSArray *)instancesOfAllWhenStatements {
    NSMutableArray *statements = [NSMutableArray array];
    for (Class klass in self.whenStatementClasses) {
        [statements addObject:[[klass alloc] init]];
    }
    return [statements copy];
}

- (NSArray *)instancesOfAllThenStatements {
    NSMutableArray *statements = [NSMutableArray array];
    for (Class klass in self.thenStatementClasses) {
        [statements addObject:[[klass alloc] init]];
    }
    return [statements copy];
}

#pragma mark Properties

- (NSArray *)whenStatementClasses {
    return [self.mutableWhenStatementClasses copy];
}

- (NSArray *)thenStatementClasses {
    return [self.mutableThenStatementClasses copy];
}

@end
