//
//  RPJSCodeIntel.m
//  RPJSCodeIntel
//
//  Created by Brandon Evans on 2014-11-10.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "RPJSCodeIntel.h"
@import JavaScriptCore;

@interface RPJSCodeIntel ()

@property (nonatomic, strong) JSContext *context;
@property (nonatomic, strong) NSString *script;
@property (nonatomic, strong) NSArray *typeDefinitions;
@property (nonatomic, strong) JSValue *ternServer;

@end

@implementation RPJSCodeIntel

#pragma mark - Lifecycle

- (instancetype)initWithScript:(NSString *)script typeDefinitions:(NSArray *)typeDefinitions {
    self = [super init];
    if (!self) return nil;

    _typeDefinitions = typeDefinitions;
    [self resetContext];
    self.script = script;

    return self;
}

#pragma mark - Properties

- (void)setScript:(NSString *)script {
    _script = script;
    [self.ternServer invokeMethod:@"setScript" withArguments:@[ script, [NSNull null] ]];
}

#pragma mark - Private Methods

- (void)resetContext {
    self.context = [JSContext new];
    self.context[@"log"] = ^(id msg) {
        NSLog(@"%@", [msg description]);
    };
    self.context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSLog(@"%@", exception);
    };
    for (NSString *scriptName in @[ @"acorn", @"acorn_loose", @"walk", @"signal", @"def", @"infer", @"tern", @"comment", @"tern-server" ]) {
        NSString *scriptPath = [[NSBundle bundleForClass:[RPJSCodeIntel class]] pathForResource:scriptName ofType: @"js"];
        if (scriptPath) {
            NSString *script = [NSString stringWithContentsOfFile:scriptPath encoding:NSUTF8StringEncoding error:nil];
            [self.context evaluateScript:script withSourceURL:[NSURL URLWithString:scriptPath]];
        }
    }

    NSArray *arguments = @[];
    if (self.typeDefinitions) {
        arguments = @[ @{ @"defs": self.typeDefinitions } ];
    }
    JSValue *ternConstructor = self.context[@"TernServer"];
    self.ternServer = [ternConstructor constructWithArguments:arguments];
}

#pragma mark - Public Methods

- (NSDictionary *)typeInformationForLineNumber:(NSInteger)lineNumber column:(NSInteger)column error:(NSError **)error {
    // We need to pass a callback but it's evaluated syncronously
    __block NSString *ternError = @"";
    __block NSDictionary *typeInfo = @{};
    [self.ternServer invokeMethod:@"type" withArguments:@[ @{ @"line": @(lineNumber), @"ch": @(column) }, [NSNull null], ^(NSString *e, NSDictionary *t) {
        ternError = e;
        typeInfo = t;
    } ]];

    if (!PCIsEmpty(ternError)) {
        if (error) {
            *error = [[NSError alloc] initWithDomain:@"com.robotsandpencils.RPJSCodeIntel" code:0 userInfo:@{ NSLocalizedDescriptionKey: ternError }];
        }
        return nil;
    }

    return typeInfo;
}

- (NSDictionary *)typeInformationForExpression:(NSError **)error {
    NSInteger lineNumber = 0, column = self.script.length - 1;

    // We need to pass a callback but it's evaluated synchronously
    __block NSString *ternError = @"";
    __block NSDictionary *typeInfo = @{};
    [self.ternServer invokeMethod:@"type" withArguments:@[ @{ @"line": @(lineNumber), @"ch": @(column) }, @{ @"line": @0, @"ch": @0 }, ^(NSString *e, NSDictionary *t) {
        ternError = e;
        typeInfo = t;
    } ]];

    // If there was an error inferring types then try naive method on return value to get the name
    if (!PCIsEmpty(ternError) && ![ternError isEqualToString:@"null"]) {
        JSValue *returnValue = [self.context evaluateScript:[NSString stringWithFormat:@"(%@)", self.script]];
        NSString *name = [self nameOfValue:returnValue];
        NSMutableDictionary *mutableTypeInfo = [typeInfo mutableCopy] ?: [NSMutableDictionary dictionary];
        mutableTypeInfo[@"name"] = name;
        typeInfo = [mutableTypeInfo copy];
    }

    if (!PCIsEmpty(ternError) && ![ternError isEqualToString:@"null"]) {
        if (error) {
            *error = [[NSError alloc] initWithDomain:@"com.robotsandpencils.RPJSCodeIntel" code:0 userInfo:@{ NSLocalizedDescriptionKey: ternError }];
        }
    }

    return typeInfo;
}

- (BOOL)validateObjectValueOfScript:(NSString *)script expectedType:(PCTokenEvaluationType)type {
    JSValue *returnValue = [self.context evaluateScript:[NSString stringWithFormat:@"(%@)", script]];

    // This is only expected to work on the Object token evaluation types
    if (!returnValue.isObject || ![[Constants javaScriptObjectEvaluationTypes] containsObject:@(type)]) {
        return NO;
    }

    JSValue *object = self.context[@"Object"];
    JSValue *ownProperties = [object invokeMethod:@"getOwnPropertyNames" withArguments:@[ returnValue ]];
    // There won't be duplicate property names but more importantly we want to compare unordered contents
    NSSet *uniqueProperties = [NSSet setWithArray:[ownProperties toArray]];

    NSSet *expectedProperties = [Constants propertiesForJavaScriptObjectEvaluationType:type];
    if (![uniqueProperties isEqualToSet:expectedProperties]) {
        return NO;
    }

    // Operating under the assumption that these are structs with only numbers as members, per propertiesForJavaScriptObjectEvaluationType: docs
    BOOL containsNonNumber = Underscore.any(expectedProperties.allObjects, ^BOOL(NSString *propertyName) {
        return !returnValue[propertyName].isNumber;
    });

    return !containsNonNumber;
}

#pragma mark - Private

// This isn't in a category since the return values aren't canonical
- (NSString *)nameOfValue:(JSValue *)value {
    if (value.isUndefined) {
        return @"undefined";
    }
    else if (value.isNull) {
        return @"null";
    }
    else if (value.isBoolean) {
        return @"bool";
    }
    else if (value.isNumber) {
        return @"number";
    }
    else if (value.isString) {
        return @"string";
    }
    else if (value.isObject) {
        return @"Object";
    }
    return @"";
}

@end
