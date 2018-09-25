//
//  NSObject(JSDataBinding) 
//  PCPlayer
//
//  Created by brandon on 2014-03-18.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;


@protocol NSObjectJSDataBindingExport <JSExport>

// The next two methods are exported as "private" (kind of an oxymoron, huh) methods by their names
// The intention is to use Object.prototype.watch (setup in the watch.js module) as the lone interface
// If the JS object is an Obj-C wrapper then the native, prefixed functions will be called instead and the JS will return early
JSExportAs(__watch,
- (void)watchKeyPath:(NSString *)keyPath handler:(JSValue *)handler
);
- (void)__unwatch;

// These methods are called when they exist (should only be on wrapper objects) by the keypath.js module
- (void)setValue:(id)value forKeyPath:(NSString *)keyPath;
- (id)valueForKeyPath:(NSString *)keyPath;

@end


@interface NSObject (JSDataBinding) <NSObjectJSDataBindingExport>

- (void)watchKeyPath:(NSString *)keyPath handler:(JSValue *)handler;
- (void)__unwatch;

@end
