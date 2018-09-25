//
//  RPJSContext.h
//  RPJSContext
//
//  Created by Brandon Evans on 2014-04-24.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

typedef void(^RPJSContextExceptionHandler)(JSContext *, JSValue *);
typedef void(^RPJSContextLogHandler)(NSString *);

@interface RPJSContext : JSContext

/**
 *  Custom exception handler block that gets called in addition to the default exception handler
 */
@property (nonatomic, copy) RPJSContextExceptionHandler customExceptionHandler;

/**
 *  Log handler block that gets called in addition to the default log handler
 */
@property (nonatomic, copy) RPJSContextLogHandler logHandler;

/**
 *  Evaluate a JavaScript file
 *
 *  @param name The name of the file contained in the same bundle as this class
 *
 *  @return The JSValue returned from the script
 */
- (JSValue *)evaluateScriptFileWithName:(NSString *)name;

/**
 *  Evaluate a JavaScript file. This method is equivalent to `-[RPJSContext evaluateScriptFileAtPath:path requiresShim:YES]`
 *
 *  @param path The path of the file to evaluate
 *
 *  @return The return value of the evaluated file
 */
- (JSValue *)evaluateScriptFileAtPath:(NSString *)path;

/**
 *  Evaluate a JavaScript file
 *
 *  @param path The path of the file to evaluate
 *
 *  @param scriptRequiresShim Whether or not the script needs to be processed by regenerator. Pass in NO if the script has already been shimmed.
 *
 *  @return The return value of the evaluated file
 */
- (JSValue *)evaluateScriptFileAtPath:(NSString *)path requiresShim:(BOOL)scriptRequiresShim;

/**
 *  Require JavaScript module files in the CommonJS format.
 *
 *  This calls `var $NAME = require('$NAME');` for each module
 *  `require` will either load the named module from the file with a matching name or assign the native class to a variable of the same name in the context, provided the module file doesn't exist
 *  For example, `[context requireModules:@[ @"NSUUID" ]]` would set the JS variable `NSUUID` to the exported native constructor object
 *
 *  @param modules An array of module names. Module names should match the filename minus the file extension, e.g. DemoModule would correspond to the file DemoModule.js
 */
- (void)requireModules:(NSArray *)modules;

@end
