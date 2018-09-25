//
//  PCMarkdownParser.m
//  Pods
//
//  Created by Cody Rayment on 2015-05-13.
//
//

#import "PCMarkdownParser.h"
#import <GHMarkdownParser/GHMarkdownParser.h>

@implementation PCMarkdownParser

+ (NSString *)parseMarkdown:(NSString *)markdown {
    return markdown.flavoredHTMLStringFromMarkdown;
}

@end
