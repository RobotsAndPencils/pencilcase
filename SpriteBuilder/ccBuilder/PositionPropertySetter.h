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

#import <SpriteKit/SpriteKit.h>

enum
{
    kCCBScaleTypeAbsolute,
    kCCBScaleTypeMultiplyResolution
};

@interface PositionPropertySetter : NSObject

+ (CGSize) getParentSize:(SKNode*) node;

// Setting/getting positions
+ (void) setPosition:(NSPoint)pos forSpriteKitNode:(SKNode *)node prop:(NSString *)prop;
+ (NSPoint) positionForNode:(SKNode*)node prop:(NSString*)prop;
+ (void)addPositionKeyframeForSpriteKitNode:(SKNode *)node;
+ (void)addScaleKeyframeForNode:(SKNode*)node;
+ (void)addKeyframeForNode:(SKNode*)node value:(id)value property:(NSString*)prop;

// Setting/getting sizes
+ (void) setSize:(NSSize)size forSpriteKitNode:(SKNode *)node prop:(NSString *)prop;
+ (NSSize) sizeForNode:(SKNode*)node prop:(NSString*)prop;

// Setting/getting scale
+ (void) setScaledX:(float)scaleX Y:(float)scaleY forSpriteKitNode:(SKNode*)node prop:(NSString*)prop;
+ (float) scaleXForNode:(SKNode*)node prop:(NSString*)prop;
+ (float) scaleYForNode:(SKNode*)node prop:(NSString*)prop;

+ (void) setFloatScale:(float)f forNode:(SKNode*)node prop:(NSString*)prop;
+ (float) floatScaleForNode:(SKNode*)node prop:(NSString*)prop;

@end
