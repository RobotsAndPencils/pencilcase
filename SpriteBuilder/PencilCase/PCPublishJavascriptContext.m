//
//  PCPublishJavascriptContext.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-03-16.
//
//

#import "PCPublishJavascriptContext.h"

@implementation PCPublishJavascriptContext

- (id)init {
    self = [super init];
    if (self) {
        // For scripts that reference globals through the window object
        self[@"window"] = self.globalObject;

        [self evaluateScriptFileWithName:@"regenerator"];
        [self evaluateScript:@"regenerator.runtime();"];
    }
    return self;
}

#pragma mark - Public

- (NSString *)shimGeneratorScriptAtPath:(NSString *)generatorScriptPath error:(NSError **)outError {
    NSError *error;
    NSString *generatorScript = [NSString stringWithContentsOfFile:generatorScriptPath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Could not load source Javascript file %@: %@", [generatorScriptPath lastPathComponent], error);
        if (outError) *outError = error;
        return nil;
    }
    return [self shimGeneratorScript:generatorScript];
}

#pragma mark - Private

- (JSValue *)evaluateScriptFileWithName:(NSString *)name {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:@"js"];
    return [self evaluateScriptFileAtPath:path];
}

- (JSValue *)evaluateScriptFileAtPath:(NSString *)path {
    NSString *scriptContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    if (!scriptContents) return nil;

    return [self evaluateScript:scriptContents withSourceURL:[NSURL URLWithString:path]];
}

- (NSString *)shimGeneratorScript:(NSString *)generatorScript {
    JSValue *regenerator = self[@"regenerator"];
    if ([regenerator isUndefined]) return generatorScript;

    JSValue *result = [regenerator invokeMethod:@"compile" withArguments:@[ generatorScript ]];
    NSString *shimmedScript = result.toDictionary[@"code"];
    return shimmedScript;
}

@end
