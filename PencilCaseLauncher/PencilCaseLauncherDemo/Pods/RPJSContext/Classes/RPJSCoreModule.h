//
// Created by Brandon Evans on 14-12-05.
//

@import JavaScriptCore;

@protocol RPJSCoreModule <NSObject>

+ (void)setupInContext:(JSContext *)context;

@end