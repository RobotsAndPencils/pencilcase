/*
 * SpriteBuilder: http://www.spritebuilder.org
 *
 * Copyright (c) 2012 Zynga Inc.
 * Copyright (c) 2013 Apportable Inc.
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

@class CCBSequence;

@protocol CCBAnimationManagerDelegate <NSObject>
- (void)completedAnimationSequenceNamed:(NSString *)name;
@end

@interface CCBAnimationManager : NSObject

@property (nonatomic, readonly) NSMutableArray *sequences;
@property (nonatomic, strong) NSMutableDictionary *nodeSequences;
@property (nonatomic, assign) int autoPlaySequenceId;
@property (nonatomic, readonly) NSString *lastCompletedSequenceName;
@property (nonatomic, strong) NSMutableDictionary *baseValues;

@property (nonatomic, weak) SKNode *rootNode;
@property (nonatomic, weak) id owner;

@property (nonatomic, assign) CGSize rootContainerSize;

@property (nonatomic, strong) NSObject<CCBAnimationManagerDelegate> *delegate;

@property (nonatomic) NSInteger animationManagerId;
@property (nonatomic, copy) void (^block)(id);

- (CGSize)containerSize:(SKNode *)node;

- (void)addNode:(SKNode *)node andSequences:(NSDictionary *)seq;
- (void)moveAnimationsFromNode:(SKNode *)fromNode toNode:(SKNode *)toNode;

- (void)setBaseValue:(id)value forNode:(SKNode *)node propertyName:(NSString *)propName;

- (void)runAnimationsForSequenceNamed:(NSString *)name tweenDuration:(float)tweenDuration completion:(void (^)(void))completion;
- (void)runAnimationsForSequenceNamed:(NSString *)name completion:(void (^)(void))completion;
- (void)runAnimationsForSequenceId:(int)seqId tweenDuration:(float)tweenDuration completion:(void (^)(void))completion;

- (void)stopAnimationForSequenceNamed:(NSString *)name;
- (void)stopAnimationForSequenceId:(NSInteger)seqId;

@end
