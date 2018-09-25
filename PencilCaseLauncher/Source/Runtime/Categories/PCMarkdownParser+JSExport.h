//
//  PCMarkdownParser+JSExport.h
//  Pods
//
//  Created by Cody Rayment on 2015-05-13.
//
//

#import "PCMarkdownParser.h"
@import JavaScriptCore;

@protocol PCMarkdownParserExport <JSExport>

+ (NSString *)parseMarkdown:(NSString *)markdown;

@end

@interface PCMarkdownParser (JSExport) <PCMarkdownParserExport>

@end
