//
//  PCPublishJavascriptContext.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-03-16.
//
//

#import <JavaScriptCore/JavaScriptCore.h>

@interface PCPublishJavascriptContext : JSContext

/**
 Applies a regenerator pass to the passed in script, allowing us access to 'yield'.
 @param generatorScriptPath The path to the file to shim
 */
- (NSString *)shimGeneratorScriptAtPath:(NSString *)generatorScriptPath error:(NSError **)outError;

@end
