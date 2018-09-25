//
//  RPJSContext.m
//  RPJSContext
//
//  Created by Brandon Evans on 2014-04-24.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "RPJSContext.h"

// Standard Library
#import "RPJSRequest.h"
#import "RPJSTimers.h"

@implementation RPJSContext

- (id)init {
    self = [super init];
    if (self) {
        __weak __typeof(self) weakSelf = self;
        self.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            if (weakSelf.customExceptionHandler) {
                weakSelf.customExceptionHandler(context, exception);
                return;
            }

            NSLog(@"[%@:%@:%@] %@\n%@", exception[@"sourceURL"], exception[@"line"], exception[@"column"], exception, [exception[@"stack"] toObject]);
        };

        // Replicate some browser/Node APIs
        void(^log)(NSString *) = ^(NSString *message) {
            if (weakSelf.logHandler) {
                weakSelf.logHandler(message);
                return;
            }

            NSLog(@"JS: %@", message);
        };
        self[@"console"] = @{
                             @"log": log,
                             @"warn": log,
                             @"info": log
                             };

        // For scripts that reference globals through the window object
        self[@"window"] = self.globalObject;

        // Basic CommonJS module require implementation (http://wiki.commonjs.org/wiki/Modules/1.1)
        self[@"require"] = ^JSValue *(NSString *moduleName) {
            NSLog(@"require: %@", moduleName);

            // Avoid a retain cycle
            JSContext *context = [RPJSContext currentContext];

            NSString *modulePath = [[NSBundle bundleForClass:[context class]] pathForResource:moduleName ofType:@"js"];
            NSData *moduleFileData = [NSData dataWithContentsOfFile:modulePath];
            NSString *moduleStringContents = [[NSString alloc] initWithData:moduleFileData encoding:NSUTF8StringEncoding];

            // Analagous to Node's require.resolve loading a core module (http://nodejs.org/api/modules.html#modules_the_module_object)
            if (!moduleStringContents || [moduleStringContents length] == 0) {
                moduleStringContents = [NSString stringWithFormat:@"module.exports = nativeClassWithName('%@');", moduleName];
            }

            NSString *exportScript = [NSString stringWithFormat:@"(function() { var module = { exports: {}}; var exports = module.exports; %@; return module.exports; })();", moduleStringContents];
            return [context evaluateScript:exportScript];
        };

        self[@"nativeClassWithName"] = ^JSValue *(NSString *className) {
            return [JSValue valueWithObject:NSClassFromString(className) inContext:[JSContext currentContext]];
        };

        // Backports
        [self evaluateScriptFileWithName:@"rsvp"];
        [self evaluateScript:@"Promise = RSVP.Promise;"];
        [self evaluateScriptFileWithName:@"regenerator"];
        [self evaluateScript:@"regenerator.runtime();"];

        // Core Modules
        [RPJSRequest setupInContext:self];
        [RPJSTimers setupInContext:self];
    }
    return self;
}

#pragma mark - Public

- (JSValue *)evaluateScriptFileWithName:(NSString *)name {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:@"js"];
    return [self evaluateScriptFileAtPath:path];
}

- (JSValue *)evaluateScriptFileAtPath:(NSString *)path {
    return [self evaluateScriptFileAtPath:path requiresShim:YES];
}

- (JSValue *)evaluateScriptFileAtPath:(NSString *)path requiresShim:(BOOL)scriptRequiresShim {
    NSString *scriptContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    if (scriptContents) {
        if (scriptRequiresShim) {
            scriptContents = [self shimGeneratorScript:scriptContents];
        }
        return [self evaluateScript:scriptContents withSourceURL:[NSURL URLWithString:path]];
    }
    return nil;
}

- (void)requireModules:(NSArray *)modules {
    for (NSString *moduleName in modules) {
        [self evaluateScript:[NSString stringWithFormat:@"var %@ = require('%@');", moduleName, moduleName]];
    }
}

#pragma mark - Private

- (NSString *)shimGeneratorScript:(NSString *)generatorScript {
    // Return early if regenerator isn't available
    if ([self[@"regenerator"] isUndefined]) return generatorScript;

    NSString *preparedGeneratorScript = [generatorScript copy];
    // Escape whitespace since this is being interpolated into another script
    preparedGeneratorScript = [preparedGeneratorScript stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    preparedGeneratorScript = [preparedGeneratorScript stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    preparedGeneratorScript = [preparedGeneratorScript stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    preparedGeneratorScript = [preparedGeneratorScript stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    NSString *compile = [NSString stringWithFormat:@"regenerator.compile('%@').code;", preparedGeneratorScript];
    NSString *shimmedScript = [[self evaluateScript:compile] toString];
    return shimmedScript;
}

@end

