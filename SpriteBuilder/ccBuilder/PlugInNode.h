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
#import "Constants.h"

@interface PlugInNode : NSObject <NSPasteboardWriting> {
    NSBundle *bundle;

    NSString *nodeClassName;
    NSString *nodeEditorClassName;

    NSString *displayName;
    NSString *descr;
    int ordering;
    BOOL supportsTemplates;

    NSImage *icon;

    NSString *dropTargetSpriteFrameClass;
    NSString *dropTargetSpriteFrameProperty;

    NSMutableArray *nodeProperties;
    NSMutableDictionary *nodePropertiesDict;
    NSDictionary *migratedPropertiesDict;

    BOOL canBeRoot;
    BOOL canHaveChildren;
    BOOL isAbstract;
    NSString *positionProperty;
    NSString *requireParentClass;
    NSArray *requireChildClass;

    NSArray *cachedAnimatableProperties;
    NSArray *cachedAnimatablePropertiesFlashSkew;
}

@property (nonatomic) NSString *nodeClassName;
@property (nonatomic) NSString *nodeSpriteKitClassName;
@property (nonatomic, readonly) NSString *nodeEditorClassName;
@property (nonatomic, readonly) NSString *nodeEditorSpriteKitClassName;
@property (nonatomic, readonly) NSString *displayName;
@property (nonatomic, readonly) NSString *javaScriptClassName;
@property (nonatomic, readonly) NSString *descr;
@property (nonatomic, readonly) int ordering;
@property (nonatomic, assign) BOOL supportsTemplates;
@property (nonatomic) NSMutableArray *nodeProperties;
@property (nonatomic) NSMutableDictionary *nodePropertiesDict;
@property (nonatomic, readonly) NSString *dropTargetSpriteFrameClass;
@property (nonatomic, readonly) NSString *dropTargetSpriteFrameProperty;
@property (nonatomic, readonly) BOOL acceptsDroppedSpriteFrameChildren;
@property (nonatomic, readonly) BOOL canBeRoot;
@property (nonatomic, readonly) BOOL canHaveChildren;
@property (nonatomic, readonly) BOOL isAbstract;
@property (nonatomic, readonly) NSString *requireParentClass;
@property (nonatomic, readonly) NSArray *requireChildClass;
@property (nonatomic, readonly) NSString *positionProperty;
@property (nonatomic, strong) NSImage *icon;

@property (assign, nonatomic) BOOL comingSoon;
@property (strong, nonatomic) NSArray *nodeChangeProperties;
@property (strong, nonatomic, readonly) NSArray *readOnlyProperties;
@property (assign, nonatomic, readonly) PCNodeType nodeType;
+ (PCPropertyType)propertyTypeForPropertyInfo:(NSDictionary *)property;

- (BOOL)dontSetInEditorProperty:(NSString *)prop;
- (NSString *)migratedNameForPropertyNamed:(NSString *)name;

- (id)initWithBundle:(NSBundle *)b;
- (NSBundle *)bundle;

- (NSArray *)localizablePropertiesForNode:(SKNode *)node;
- (NSArray *)animatablePropertiesForSpriteKitNode:(SKNode *)node;
- (NSString *)propertyTypeForProperty:(NSString *)property;

- (BOOL)isAnimatableProperty:(NSString *)prop spriteKitNode:(SKNode *)node;

- (NSArray *)loadInheritableAndOverridableArrayForKey:(NSString *)key withUniqueIDKey:(NSString *)uniqueIDKey forBundle:(NSBundle *)b;
- (void)setupNodePropsDict;

@end
