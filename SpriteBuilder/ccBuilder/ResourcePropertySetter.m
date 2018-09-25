/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "ResourcePropertySetter.h"
#import "PCResourceManager.h"
#import "CCBFileUtil.h"
#import "SKNode+NodeInfo.h"
#import "SKNode+NodeInfo.h"
#import "ResourceManagerUtil.h"
#import "PCResourceLibrary.h"

@implementation ResourcePropertySetter

+ (void) setTtfForNode:(SKNode*)node andProperty:(NSString*) prop withFont:(NSString*) fontName
{
    NSString* fullName = fontName;
    if ([[fontName lowercaseString] hasSuffix:@".ttf"])
    {
        fullName = [[PCResourceManager sharedManager] toAbsolutePath:fontName];
    }
    if (!fullName) fullName = @"";
    
    [node setValue:fullName forKey:prop];
    
    if (!fontName) fontName = @"";
    [node setExtraProp:fontName forKey:prop];
}

+ (NSString*) ttfForNode:(SKNode*)node andProperty:(NSString*) prop
{
    NSString* fntFile = [node extraPropForKey:prop];
    if ([fntFile isEqualToString:@""]) return NULL;
    return fntFile;
}

+ (void)setResource:(PCResource *)resource forProperty:(NSString *)property onNode:(SKNode *)node {
    if (PCIsEmpty(resource.filePath)) return;

    [node setExtraProp:resource.uuid forKey:property];
    switch (resource.type) {
        case PCResourceTypeImage: {
            [node setValue:[[PCResourceLibrary sharedLibrary] textureForResource:resource] forKey:property];
            break;
        }
        default:
            break;
    }
}

+ (void)setResourceWithUUID:(NSString *)uuid forProperty:(NSString *)property onNode:(SKNode *)node {
    PCResource *resource = [[PCResourceManager sharedManager] resourceWithUUID:uuid];
    if (!resource) {
        NSLog(@"Unable to locate resource with UUID %@", uuid);
        return;
    }
    [ResourcePropertySetter setResource:resource forProperty:property onNode:node];
}

+ (void)setResourceUUID:(NSString *)uuid forProperty:(NSString *)property onNode:(SKNode *)node {
    [node setExtraProp:uuid forKey:property];
    [node setValue:uuid forKey:property];
}

@end
