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

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@class PCResource;

@interface ResourcePropertySetter : NSObject

+ (void) setTtfForNode:(SKNode*)node andProperty:(NSString*) prop withFont:(NSString*) fontName;
+ (NSString*) ttfForNode:(SKNode*)node andProperty:(NSString*) prop;

/**
 Sets a resource onto a node.
 @param resource The PCResource object that points to the underlying resource the object will display
 @param property The property to set
 @param node The node to set the property on
 */
+ (void)setResource:(PCResource *)resource forProperty:(NSString *)property onNode:(SKNode *)node;

/**
 Given a UUID, sets a resource on a node. If there is no matching UUID, the function fails silently.
 @param uuid The UUID of the resource to set. If the resource cannot be found, the function fails silently.
 @param property The property to set
 @param node The node to set the property on
 */
+ (void)setResourceWithUUID:(NSString *)uuid forProperty:(NSString *)property onNode:(SKNode *)node;

/**
 Sets a UUID directly on a node, letting the node handle loading the resource if necessary
 @param uuid The UUID to set on the node
 @param property The property to set the UUID on
 @param node The node to set the UUID on
 */
+ (void)setResourceUUID:(NSString *)uuid forProperty:(NSString *)property onNode:(SKNode *)node;

@end
