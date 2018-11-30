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

@class PlugInNode;
@class SequencerNodeProperty;

@interface NodeInfo : NSObject
{
    PlugInNode* __weak plugIn;
    NSMutableDictionary* extraProps;
    NSMutableDictionary* animatableProperties;
    NSMutableDictionary* baseValues;
    NSMutableArray* customProperties;
    CGPoint transformStartPosition;
    float transformStartRotation;
    float transformStartScaleX;
    float transformStartScaleY;
    float transformStartSkewX;
    float transformStartSkewY;
    NSString* displayName;
}

@property (nonatomic,weak) PlugInNode* plugIn;
@property (nonatomic,readonly) NSMutableDictionary* extraProps;
@property (nonatomic,strong) NSMutableDictionary* animatableProperties;
@property (nonatomic,readonly) NSMutableDictionary* baseValues;
@property (nonatomic,copy) NSString* displayName;
@property (nonatomic,strong) NSMutableArray* customProperties;
@property (nonatomic,assign) CGPoint transformStartPosition;
@property (nonatomic,assign) CGPoint transformStartAnchorPoint;

@property (nonatomic, assign) float transformStartRotation;
@property (nonatomic, assign) float transformStartScaleX;
@property (nonatomic, assign) float transformStartScaleY;
@property (nonatomic, assign) float transformStartSkewX;
@property (nonatomic, assign) float transformStartSkewY;

+ (id) nodeInfoWithPlugIn:(PlugInNode*)pin;

- (void)generateUuid;

@end
