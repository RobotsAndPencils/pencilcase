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

#import "CCBReader.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "CCBAnimationManager.h"
#import "CCBSequence.h"
#import "CCBSequenceProperty.h"
#import "CCBKeyframe.h"
#import "CCBLocalizationManager.h"
#import "CCBReader_Private.h"
#import "SKNode+CocosCompatibility.h"
#import "PCReaderManager.h"
#import "CCFileUtils.h"
#import "SKNode+PhysicsExport.h"
#import "SKNode+PhysicsBody.h"
#import "PCResourceManager.h"
#import "PCPhysicsWrapperNode.h"
#import "PCPhysicsBodyParameters.h"
#import "PCConstants.h"
#import "CCBFile.h"

#ifdef CCB_ENABLE_UNZIP
#import "SSZipArchive.h"
#endif

@interface CCBReader ()

@property (assign, nonatomic) NSInteger fileVersion;

@end

@implementation CCBReader

#pragma mark - Lifecycle

- (instancetype)initWithOwner:(id)owner parentSize:(CGSize)parentSize animationManager:(CCBAnimationManager *)animationManager {
    self = [super init];
    if (!self) return nil;

    _owner = owner;

    _animationManager = animationManager;
    _animationManager.owner = owner;
    // The parentSize parameter only ever needs to be known by CCBReader in order to set it on its animationManager, so this can be changed to happen elsewhere
    _animationManager.rootContainerSize = parentSize;

    // Setup set of loaded sprite sheets
    loadedSpriteSheets = [[NSMutableSet alloc] init];

    return self;
}

- (void)dealloc {
    bytes = nil;
}

#pragma mark - CCB File Reading

static inline unsigned char readByte(CCBReader *self) {
    unsigned char byte = self->bytes[self->currentByte];
    self->currentByte++;
    return byte;
}

static inline BOOL readBool(CCBReader *self) {
    return (BOOL)readByte(self);
}

static inline NSString *readUTF8(CCBReader *self) {
    int b0 = readByte(self);
    int b1 = readByte(self);

    int numBytes = b0 << 8 | b1;

    NSString *str = [[NSString alloc] initWithBytes:self->bytes + self->currentByte length:numBytes encoding:NSUTF8StringEncoding];

    self->currentByte += numBytes;

    return str;
}

static inline void alignBits(CCBReader *self) {
    if (self->currentBit) {
        self->currentBit = 0;
        self->currentByte++;
    }
}

#define REVERSE_BYTE(b) (unsigned char)(((b * 0x0802LU & 0x22110LU) | (b * 0x8020LU & 0x88440LU)) * 0x10101LU >> 16)

static inline int readIntWithSign(CCBReader *self, BOOL sign) {
    // Good luck groking this!
    // The basic idea is to do as little bit reading as possible and use everything in a byte contexts and avoid loops; espc ones that iterate 8 * bytes-read
    // Note: this implementation is NOT the same encoding concept as the standard Elias Gamma, instead the real encoding is a byte flipped version of it.
    // In order to optimize to little-endian devices, we have chosen to unflip the bytes before transacting upon them (excluding of course the "leading" zeros.

    unsigned int v = *(unsigned int *)(self->bytes + self->currentByte);
    int numBits = 32;
    int extraByte = 0;
    v &= -((int)v);
    if (v) numBits--;
    if (v & 0x0000FFFF) numBits -= 16;
    if (v & 0x00FF00FF) numBits -= 8;
    if (v & 0x0F0F0F0F) numBits -= 4;
    if (v & 0x33333333) numBits -= 2;
    if (v & 0x55555555) numBits -= 1;

    if ((numBits & 0x00000007) == 0) {
        extraByte = 1;
        self->currentBit = 0;
        self->currentByte += (numBits >> 3);
    }
    else {
        self->currentBit = numBits - (numBits >> 3) * 8;
        self->currentByte += (numBits >> 3);
    }

    static char prefixMask[] = {
        0xFF,
        0x7F,
        0x3F,
        0x1F,
        0x0F,
        0x07,
        0x03,
        0x01,
    };
    static unsigned int suffixMask[] = {
        0x00,
        0x80,
        0xC0,
        0xE0,
        0xF0,
        0xF8,
        0xFC,
        0xFE,
        0xFF,
    };
    unsigned char prefix = REVERSE_BYTE(*(self->bytes + self->currentByte)) & prefixMask[self->currentBit];
    long long current = prefix;
    int numBytes = 0;
    int suffixBits = (numBits - (8 - self->currentBit) + 1);
    if (numBits >= 8) {
        suffixBits %= 8;
        numBytes = (numBits - (8 - (int)(self->currentBit)) - suffixBits + 1) / 8;
    }
    if (suffixBits >= 0) {
        self->currentByte++;
        for (int i = 0; i < numBytes; i++) {
            current <<= 8;
            unsigned char byte = REVERSE_BYTE(*(self->bytes + self->currentByte));
            current += byte;
            self->currentByte++;
        }
        current <<= suffixBits;
        unsigned char suffix = (REVERSE_BYTE(*(self->bytes + self->currentByte)) & suffixMask[suffixBits]) >> (8 - suffixBits);
        current += suffix;
    }
    else {
        current >>= -suffixBits;
    }
    self->currentByte += extraByte;
    int num;

    if (sign) {
        int s = current % 2;
        if (s) {
            num = (int)(current / 2);
        }
        else {
            num = (int)(-current / 2);
        }
    }
    else {
        num = (int)current - 1;
    }

    alignBits(self);

    return num;
}

static inline float readFloat(CCBReader *self) {
    unsigned char type = readByte(self);

    if (type == kCCBFloat0) return 0;
    else if (type == kCCBFloat1) return 1;
    else if (type == kCCBFloatMinus1) return -1;
    else if (type == kCCBFloat05) return 0.5f;
    else if (type == kCCBFloatInteger) {
        return readIntWithSign(self, YES);
    }
    else {
        volatile union {
            float f;
            int i;
        } t;
        t.i = *(int *)(self->bytes + self->currentByte);
        self->currentByte += 4;
        return t.f;
    }
}

- (NSString *)readCachedString {
    int n = readIntWithSign(self, NO);
    return stringCache[n];
}

- (void)readPropertyForNode:(SKNode *)node parent:(SKNode *)parent isExtraProp:(BOOL)isExtraProp {
    // Read type and property name
    int type = readIntWithSign(self, NO);
    NSString *name = [self readCachedString];

    // Check if the property can be set for this platform
    BOOL setProp = YES;
    if (![node isKindOfClass:[SKNode class]]) setProp = NO;
    if ([[self.class deprecatedKeys] containsObject:name]) {
        setProp = NO;
    }

    // Forward properties for sub ccb files
    if ([node isKindOfClass:[CCBFile class]]) {
        CCBFile *ccbNode = (CCBFile *)node;
        if (ccbNode.ccbFile && isExtraProp) {
            node = ccbNode.ccbFile;

            // Skip properties that doesn't have a value to override
            NSSet *extraPropsNames = node.userObject;
            setProp &= [extraPropsNames containsObject:name];
        }
    }
    else if (isExtraProp && node == self.animationManager.rootNode) {
        NSMutableSet *extraPropNames = node.userObject;
        if (!extraPropNames) {
            extraPropNames = [NSMutableSet set];
            node.userObject = extraPropNames;
        }

        [extraPropNames addObject:name];
    }

    if (type == kCCBPropTypePosition) {
        float x = readFloat(self);
        float y = readFloat(self);
        int corner = readByte(self);
        int xUnit = readByte(self);
        int yUnit = readByte(self);

        if (setProp) {
#ifdef PC_PLATFORM_IOS
            [node setValue:[NSValue valueWithCGPoint:CGPointMake(x, y)] forKey:name];
#elif defined (PC_PLATFORM_MAC)
            [node setValue:[NSValue valueWithPoint:CGPointMake(x,y)] forKey:name];
#endif

            if ([animatedProps containsObject:name]) {
                id baseValue = @[ @(x), @(y), @(corner), @(xUnit), @(yUnit) ];
                [self.animationManager setBaseValue:baseValue forNode:node propertyName:name];
            }
        }
    }
    else if (type == kCCBPropTypePoint
        || type == kCCBPropTypePointLock) {
        float x = readFloat(self);
        float y = readFloat(self);

        if (setProp) {
            CGPoint pt = CGPointMake(x, y);
#ifdef PC_PLATFORM_IOS
            [node setValue:[NSValue valueWithCGPoint:pt] forKey:name];
#else
            [node setValue:[NSValue valueWithPoint:NSPointFromCGPoint(pt)] forKey:name];
#endif
        }
    }
    else if (type == kCCBPropTypeSize) {
        float w = readFloat(self);
        float h = readFloat(self);
        __unused int xUnit = readByte(self);
        __unused int yUnit = readByte(self);

        if (setProp) {
            CGSize size = CGSizeMake(w, h);
#ifdef PC_PLATFORM_IOS
            [node setValue:[NSValue valueWithCGSize:size] forKey:name];
#elif defined (PC_PLATFORM_MAC)
            [node setValue:[NSValue valueWithSize:size] forKey:name];
#endif
        }
    }
    else if (type == kCCBPropTypeScaleLock) {
        float x = readFloat(self);
        float y = readFloat(self);
        int sType = readByte(self);

        if (setProp) {
            [node setValue:@(x) forKey:[name stringByAppendingString:@"X"]];
            [node setValue:@(y) forKey:[name stringByAppendingString:@"Y"]];

            if ([animatedProps containsObject:name]) {
                id baseValue = @[ @(x), @(y), @(sType) ];
                [self.animationManager setBaseValue:baseValue forNode:node propertyName:name];
            }
        }
    }
    else if (type == kCCBPropTypeFloatXY) {
        float xFloat = readFloat(self);
        float yFloat = readFloat(self);

        if (setProp) {
            NSString *nameX = [NSString stringWithFormat:@"%@X", name];
            NSString *nameY = [NSString stringWithFormat:@"%@Y", name];
            [node setValue:@(xFloat) forKey:nameX];
            [node setValue:@(yFloat) forKey:nameY];
        }
    }
    else if (type == kCCBPropTypeDegrees
        || type == kCCBPropTypeFloat) {
        float f = readFloat(self);

        if (setProp) {
            id value = @(f);
            [node setValue:value forKey:name];

            if ([animatedProps containsObject:name]) {
                [self.animationManager setBaseValue:value forNode:node propertyName:name];
            }
        }
    }
    else if (type == kCCBPropTypeFloatScale) {
        float f = readFloat(self);
        __unused int sType = readIntWithSign(self, NO);

        if (setProp) {
            [node setValue:@(f) forKey:name];
        }
    }
    else if (type == kCCBPropTypeInteger
        || type == kCCBPropTypeIntegerLabeled) {
        int d = readIntWithSign(self, YES);

        if (setProp) {
            [node setValue:@(d) forKey:name];
        }
    }
    else if (type == kCCBPropTypeFloatVar) {
        float f = readFloat(self);
        float fVar = readFloat(self);

        if (setProp) {
            NSString *nameVar = [NSString stringWithFormat:@"%@Range", name];
            [node setValue:@(f) forKey:name];
            [node setValue:@(fVar) forKey:nameVar];
        }
    }
    else if (type == kCCBPropTypeCheck) {
        BOOL b = readBool(self);

        if (setProp) {
            id value = @(b);
            [node setValue:value forKey:name];

            if ([animatedProps containsObject:name]) {
                [self.animationManager setBaseValue:value forNode:node propertyName:name];
            }
        }
    }
    else if (type == kCCBPropTypeSpriteFrame || type == kCCBPropTypeTexture) {
        NSString *spriteUUID = [self readCachedString];

        if (setProp && ![spriteUUID isEqualToString:@""]) {
            SKTexture *texture = [[CCFileUtils sharedFileUtils] textureForSpriteUUID:spriteUUID];
            [node setValue:texture forKey:name];

            if ([animatedProps containsObject:name]) {
                [self.animationManager setBaseValue:texture forNode:node propertyName:name];
            }
        }
    }
    else if (type == kCCBPropTypeByte) {
        int byte = readByte(self);

        if (setProp) {
            id value = @(byte);
            [node setValue:value forKey:name];

            if ([animatedProps containsObject:name]) {
                [self.animationManager setBaseValue:value forNode:node propertyName:name];
            }
        }
    }
    else if (type == kCCBPropTypeColor4 ||
        type == kCCBPropTypeColor3) {
        CGFloat r = readFloat(self);
        CGFloat g = readFloat(self);
        CGFloat b = readFloat(self);
        CGFloat a = readFloat(self);

        if (setProp) {
            SKColor *color = [SKColor colorWithRed:r green:g blue:b alpha:a];
            [node setValue:color forKey:name];

            if ([animatedProps containsObject:name]) {
                [self.animationManager setBaseValue:color forNode:node propertyName:name];
            }
        }
    }
    else if (type == kCCBPropTypeColor4FVar) {
        float r = readFloat(self);
        float g = readFloat(self);
        float b = readFloat(self);
        float a = readFloat(self);
        float rVar = readFloat(self);
        float gVar = readFloat(self);
        float bVar = readFloat(self);
        float aVar = readFloat(self);

        if (setProp) {
            SKColor *cVal = [SKColor colorWithRed:r green:g blue:b alpha:a];;
            SKColor *cVarVal = [SKColor colorWithRed:rVar green:gVar blue:bVar alpha:aVar];
            NSString *nameVar = [NSString stringWithFormat:@"%@Range", name];
            [node setValue:cVal forKey:name];
            [node setValue:cVarVal forKey:nameVar];
        }
    }
    else if (type == kCCBPropTypeFlip) {
        BOOL xFlip = readBool(self);
        BOOL yFlip = readBool(self);

        if (setProp) {
            NSString *nameX = [NSString stringWithFormat:@"%@X", name];
            NSString *nameY = [NSString stringWithFormat:@"%@Y", name];
            [node setValue:@(xFlip) forKey:nameX];
            [node setValue:@(yFlip) forKey:nameY];
        }
    }
    else if (type == kCCBPropTypeBlendmode) {
        // We don't use this anymore but have to keep the reads so things don't break.
        __unused int src = readIntWithSign(self, NO);
        __unused int dst = readIntWithSign(self, NO);
    }
    else if (type == kCCBPropTypeText
        || type == kCCBPropTypeString) {
        NSString *txt = [self readCachedString];
        BOOL localized = readBool(self);

        if (localized) {
            txt = CCBLocalize(txt);
        }

        if (setProp) {
            [node setValue:txt forKey:name];
        }
    }
    else if (type == kCCBPropTypeDictionary) {
        NSUInteger length = readIntWithSign(self, NO);
        unsigned char buffer[length];
        for (NSUInteger index = 0; index < length; index += 1) {
            buffer[index] = readByte(self);
        }
        NSData *propData = [NSData dataWithBytes:&buffer length:length];
        NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:propData];

        if (setProp) {
            [node setValue:dictionary forKey:name];
        }
    }
    else if (type == kCCBPropTypeArray) {
        NSUInteger length = readIntWithSign(self, NO);
        unsigned char buffer[length];
        for (NSUInteger index = 0; index < length; index += 1) {
            buffer[index] = readByte(self);
        }
        NSData *propData = [NSData dataWithBytes:&buffer length:length];
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:propData];

        if (setProp) {
            [node setValue:array forKey:name];
        }
    }
    else if (type == kCCBPropTypeMutableArray) {
        NSUInteger length = readIntWithSign(self, NO);
        unsigned char buffer[length];
        for (NSUInteger index = 0; index < length; index += 1) {
            buffer[index] = readByte(self);
        }
        NSData *propData = [NSData dataWithBytes:&buffer length:length];
        NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:propData];

        if (setProp) {
            [node setValue:array forKey:name];
        }
    }
    else if (type == kCCBPropTypeFontTTF) {
        NSString *fnt = [self readCachedString];

        if (setProp) {
            //if ([[fnt lowercaseString] hasSuffix:@".ttf"])
            //{
            //    fnt = [[fnt lastPathComponent] stringByDeletingPathExtension];
            //}
            [node setValue:fnt forKey:name];
        }
    }
    else if (type == kCCBPropTypeBlock) {
        NSString *selectorName = [self readCachedString];
        int selectorTarget = readIntWithSign(self, NO);

        if (setProp) {
            // Objective C callbacks
            if (selectorTarget) {
                id target = nil;
                if (selectorTarget == kCCBTargetTypeDocumentRoot) target = self.animationManager.rootNode;
                else if (selectorTarget == kCCBTargetTypeOwner) target = self.owner;

                if (target) {
                    SEL selector = NSSelectorFromString(selectorName);
                    __unsafe_unretained id t = target;

                    void (^block)(id sender);
                    block = ^(id sender) {
                        ((void (*)(id, SEL, id))objc_msgSend)(t, selector, sender);
                    };

                    NSString *setSelectorName = [NSString stringWithFormat:@"set%@:", [name capitalizedString]];
                    SEL setSelector = NSSelectorFromString(setSelectorName);

                    if ([node respondsToSelector:setSelector]) {
                        ((void (*)(id, SEL, void (^block)(id sender)))objc_msgSend)(node, setSelector, block);
                    }
                    else {
                        NSLog(@"CCBReader: Failed to set selector/target block for %@", selectorName);
                    }
                }
                else {
                    NSLog(@"CCBReader: Failed to find target for block");
                }
            }
        }
    }
    else {
        NSLog(@"CCBReader: Failed to read property type %d", type);
    }
}

- (CCBKeyframe *)readKeyframeOfType:(int)type {
    CCBKeyframe *keyframe = [[CCBKeyframe alloc] init];

    keyframe.time = readFloat(self);

    int easingType = readIntWithSign(self, NO);
    float easingOpt = 0;
    id value = nil;

    if (easingType == kCCBKeyframeEasingCubicIn
        || easingType == kCCBKeyframeEasingCubicOut
        || easingType == kCCBKeyframeEasingCubicInOut
        || easingType == kCCBKeyframeEasingElasticIn
        || easingType == kCCBKeyframeEasingElasticOut
        || easingType == kCCBKeyframeEasingElasticInOut) {
        easingOpt = readFloat(self);
    }
    keyframe.easingType = easingType;
    keyframe.easingOpt = easingOpt;

    if (type == kCCBPropTypeCheck) {
        value = @(readBool(self));
    }
    else if (type == kCCBPropTypeByte) {
        value = @(readBool(self));
    }
    else if (type == kCCBPropTypeColor3) {
        CGFloat r = readFloat(self);
        CGFloat g = readFloat(self);
        CGFloat b = readFloat(self);
        CGFloat a = readFloat(self);

        value = [SKColor colorWithRed:r green:g blue:b alpha:a];
    }
    else if (type == kCCBPropTypeDegrees || type == kCCBPropTypeFloat) {
        value = @(readFloat(self));
    }
    else if (type == kCCBPropTypeScaleLock
        || type == kCCBPropTypePosition
        || type == kCCBPropTypeFloatXY) {
        float a = readFloat(self);
        float b = readFloat(self);

        value = @[ @(a), @(b) ];
    }
    else if (type == kCCBPropTypeSpriteFrame) {
        NSString *spriteUUID = [self readCachedString];
        value = [[CCFileUtils sharedFileUtils] textureForSpriteUUID:spriteUUID];
    }

    keyframe.value = value;

    return keyframe;
}

- (void)didLoadFromCCB {
}

- (SKNode *)readNodeGraphParent:(SKNode *)parent {
    // Read class
    NSString *className = [self readCachedString];

    // Read assignment type and name
    int memberVarAssignmentType = readIntWithSign(self, NO);
    NSString *memberVarAssignmentName = nil;
    if (memberVarAssignmentType) {
        memberVarAssignmentName = [self readCachedString];
    }

    Class class = NSClassFromString(className);
    if (!class) {
        NSAssert(false, @"CCBReader: Could not create class of type %@", className);
        return nil;
    }

    SKNode *node = [[class alloc] init];

    // Need to default this to YES becuase some projects were published before we introduce the property. Those projects expected touch events to work.
    node.userInteractionEnabled = YES;

    // Set root node
    self.animationManager.rootNode = node;

    // Read animated properties
    NSMutableDictionary *seqs = [NSMutableDictionary dictionary];
    animatedProps = [[NSMutableSet alloc] init];

    int numSequences = readIntWithSign(self, NO);
    for (int i = 0; i < numSequences; i++) {
        int seqId = readIntWithSign(self, NO);
        NSMutableDictionary *seqNodeProps = [NSMutableDictionary dictionary];

        int numProps = readIntWithSign(self, NO);

        for (int j = 0; j < numProps; j++) {
            CCBSequenceProperty *seqProp = [[CCBSequenceProperty alloc] init];

            seqProp.name = [self readCachedString];
            seqProp.type = readIntWithSign(self, NO);
            [animatedProps addObject:seqProp.name];

            int numKeyframes = readIntWithSign(self, NO);

            for (int k = 0; k < numKeyframes; k++) {
                CCBKeyframe *keyframe = [self readKeyframeOfType:seqProp.type];
                [seqProp.keyframes addObject:keyframe];
            }

            seqNodeProps[seqProp.name] = seqProp;
        }

        seqs[@(seqId)] = seqNodeProps;
    }

    if (seqs.count > 0) {
        [self.animationManager addNode:node andSequences:seqs];
    }

    // Read properties
    int numRegularProps = readIntWithSign(self, NO);
    int numExtraProps = readIntWithSign(self, NO);
    int numProps = numRegularProps + numExtraProps;

    for (int i = 0; i < numProps; i++) {
        BOOL isExtraProp = (i >= numRegularProps);

        [self readPropertyForNode:node parent:parent isExtraProp:isExtraProp];
    }

    // Handle sub ccb files (remove middle node)
    if ([node isKindOfClass:[CCBFile class]]) {
        CCBFile *ccbFileNode = (CCBFile *)node;

        SKNode *embeddedNode = ccbFileNode.ccbFile;
        embeddedNode.position = ccbFileNode.position;
        //embeddedNode.anchorPoint = ccbFileNode.anchorPoint;
        embeddedNode.zRotation = ccbFileNode.zRotation;
        embeddedNode.xScale = ccbFileNode.xScale;
        embeddedNode.yScale = ccbFileNode.yScale;
        embeddedNode.name = ccbFileNode.name;
        embeddedNode.hidden = NO;
        //embeddedNode.ignoreAnchorPointForPosition = ccbFileNode.ignoreAnchorPointForPosition;

        [self.animationManager moveAnimationsFromNode:ccbFileNode toNode:embeddedNode];

        ccbFileNode.ccbFile = nil;

        node = embeddedNode;
    }

    // Assign to variable (if applicable)
    if (memberVarAssignmentType) {
        id target = nil;
        if (memberVarAssignmentType == kCCBTargetTypeDocumentRoot) target = self.animationManager.rootNode;
        else if (memberVarAssignmentType == kCCBTargetTypeOwner) target = self.owner;

        if (target) {
            Ivar ivar = class_getInstanceVariable([target class], [memberVarAssignmentName UTF8String]);
            if (ivar) {
                object_setIvar(target, ivar, node);
            }
            else {
                NSLog(@"CCBReader: Couldn't find member variable: %@", memberVarAssignmentName);
            }
        }
    }

    animatedProps = nil;

    PCPhysicsBodyParameters *physicsBodyParameters = [self readPhysicsBodyParametersForNode:node];
    if (physicsBodyParameters) {
        PCPhysicsWrapperNode *physicsWrapperNode = [[PCPhysicsWrapperNode alloc] initWithNode:node physicsBodyParameters:physicsBodyParameters];
        [parent addChild:physicsWrapperNode];
    }

    // Read and add children
    int numChildren = readIntWithSign(self, NO);
    for (int i = 0; i < numChildren; i++) {
        SKNode *child = [self readNodeGraphParent:node];
        if (node) {
            [node addChild:child];
        }
    }

    return node;
}

- (PCPhysicsBodyParameters *)readPhysicsBodyParametersForNode:(SKNode *)node {
    // Read physics
    BOOL hasPhysicsBody = readBool(self);
    if (!hasPhysicsBody) return nil;

    PCPhysicsBodyParameters *physicsBodyParameters = [[PCPhysicsBodyParameters alloc] init];

#ifdef PC_PLATFORM_IOS
    // Read body shape
    physicsBodyParameters.bodyShape = readIntWithSign(self, NO);
    physicsBodyParameters.cornerRadius = readFloat(self);
#endif
    // Read points
    NSInteger numPoints = readIntWithSign(self, NO);
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:numPoints];
    for (NSInteger i = 0; i < numPoints; i++) {
        CGFloat x = readFloat(self);
        CGFloat y = readFloat(self);
        [points addObject:[NSValue valueWithCGPoint:[self localPointForEncodedPhysicsPoint:CGPointMake(x, y) node:node]]];
    }
    physicsBodyParameters.points = [points copy];

#ifdef PC_PLATFORM_IOS

    physicsBodyParameters.dynamic = readBool(self);
    physicsBodyParameters.affectedByGravity = readBool(self);
    physicsBodyParameters.allowsRotation = readBool(self);
    physicsBodyParameters.allowsUserDragging = [self readBoolWithDefault:YES introducedInVersion:7];

    physicsBodyParameters.density = readFloat(self);
    physicsBodyParameters.friction = readFloat(self);
    physicsBodyParameters.elasticity = readFloat(self);

    physicsBodyParameters.originalAnchorPoint = node.anchorPoint;

#endif

    return physicsBodyParameters;
}

- (CGPathRef)newPathFromPoints:(CGPoint *)points count:(NSInteger)count forNode:(SKNode *)node {
    if (count < 1) return nil;

    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint point = points[0];
    CGPathMoveToPoint(path, nil, point.x, point.y);
    for (int i = 1; i < count; i++) {
        point = points[i];
        CGPathAddLineToPoint(path, nil, point.x, point.y);
    }
    return path;
}

- (CGPoint)localPointForEncodedPhysicsPoint:(CGPoint)point node:(SKNode *)node {
    CGPoint adjusted = CGPointMake(point.x - node.contentSize.width * node.anchorPoint.x, point.y - node.contentSize.height * node.anchorPoint.y);
    adjusted.x = adjusted.x * node.xScale;
    adjusted.y = adjusted.y * node.yScale;
    return adjusted;
}

- (BOOL)readCallbackKeyframesForSeq:(CCBSequence *)seq {
    int numKeyframes = readIntWithSign(self, NO);

    if (!numKeyframes) return YES;

    CCBSequenceProperty *channel = [[CCBSequenceProperty alloc] init];

    for (int i = 0; i < numKeyframes; i++) {
        float time = readFloat(self);
        NSString *callbackName = [self readCachedString];
        int callbackType = readIntWithSign(self, NO);

        NSMutableArray *value = [@[ callbackName, @(callbackType) ] mutableCopy];

        CCBKeyframe *keyframe = [[CCBKeyframe alloc] init];
        keyframe.time = time;
        keyframe.value = value;

        [channel.keyframes addObject:keyframe];
    }

    // Assign to sequence
    seq.callbackChannel = channel;

    return YES;
}

- (BOOL)readSoundKeyframesForSeq:(CCBSequence *)seq {
    int numKeyframes = readIntWithSign(self, NO);

    if (!numKeyframes) return YES;

    CCBSequenceProperty *channel = [[CCBSequenceProperty alloc] init];

    for (int i = 0; i < numKeyframes; i++) {
        float time = readFloat(self);
        NSString *soundFile = [self readCachedString];
        float pitch = readFloat(self);
        float pan = readFloat(self);
        float gain = readFloat(self);

        NSMutableArray *value = [@[ soundFile, @(pitch), @(pan), @(gain) ] mutableCopy];
        CCBKeyframe *keyframe = [[CCBKeyframe alloc] init];
        keyframe.time = time;
        keyframe.value = value;

        [channel.keyframes addObject:keyframe];
    }

    // Assign to sequence
    seq.soundChannel = channel;

    return YES;
}

- (BOOL)readSequences {
    NSMutableArray *sequences = self.animationManager.sequences;

    int numSeqs = readIntWithSign(self, NO);

    for (int i = 0; i < numSeqs; i++) {
        CCBSequence *seq = [[CCBSequence alloc] init];
        seq.duration = readFloat(self);
        seq.name = [self readCachedString];
        seq.sequenceId = readIntWithSign(self, NO);
        seq.chainedSequenceId = readIntWithSign(self, YES);

        if (![self readCallbackKeyframesForSeq:seq]) return NO;
        if (![self readSoundKeyframesForSeq:seq]) return NO;

        [sequences addObject:seq];
    }

    self.animationManager.autoPlaySequenceId = readIntWithSign(self, YES);
    return YES;
}

/*
 * Reads in the resources, encoded as [ count, uuid1, path1, uuid2, path2, ... ] by the author
 * I'm really not sure why it always returns YES though. Is failing the entire read because of a failure here undesirable? - Brandon
 */
- (BOOL)readResources {
    if (self.fileVersion < PCVersionWithFileUUIDs) {
        return YES;
    }
    NSMutableDictionary *resourcePaths = [NSMutableDictionary dictionary];
    int numResources = readIntWithSign(self, NO);
    for (int i = 0; i < numResources; i++) {
        NSString *uuid = [self readCachedString];
        NSString *path = [self readCachedString];
        resourcePaths[uuid] = path;
    }
    [PCResourceManager sharedInstance].resources = [resourcePaths copy];
    return YES;
}

- (BOOL)readStringCache {
    int numStrings = readIntWithSign(self, NO);

    stringCache = [[NSMutableArray alloc] initWithCapacity:numStrings];

    for (int i = 0; i < numStrings; i++) {
        [stringCache addObject:readUTF8(self)];
    }

    return YES;
}

- (BOOL)readBoolWithDefault:(BOOL)defaultValue introducedInVersion:(NSInteger)version {
    if (self.fileVersion < version) return defaultValue;
    return readBool(self);
}

#define CHAR4(c0, c1, c2, c3) (((c0)<<24) | ((c1)<<16) | ((c2)<<8) | (c3))

- (BOOL)readHeader {
    // if no bytes loaded, don't crash about it.
    if (bytes == nil) return NO;
    // Read magic
    int magic = *((int *)(bytes + currentByte));
    currentByte += 4;
    if (magic != CHAR4('c', 'c', 'b', 'i')) return NO;

    // Read version
    self.fileVersion = readIntWithSign(self, NO);
    if (self.fileVersion > PCLastSupportedFileVersion || self.fileVersion < PCFirstSupportedFileVersion) {
        NSLog(@"CCBReader: Incompatible ccbi file version (file: %d reader: %d)", self.fileVersion, PCFirstSupportedFileVersion);
        return NO;
    }

    return YES;
}

- (void)cleanUpNodeGraph:(SKNode *)node {
    node.userObject = nil;

    for (SKNode *child in node.children) {
        [self cleanUpNodeGraph:child];
    }
}

- (SKNode *)readFileWithCleanUp:(BOOL)cleanUp actionManagers:(NSMutableDictionary *)am {
    if (![self readHeader]) return nil;
    if (![self readStringCache]) return nil;
    if (![self readSequences]) return nil;
    if (![self readResources]) return nil;

    // Brandon: I'm really sure that this ivar doesn't need to exist. It's not used anywhere else! Leaving for now though because all of this is basically magic.
    actionManagers = am;

    SKNode *node = [self readNodeGraphParent:nil];

    if (self.animationManager) {
        actionManagers[[NSValue valueWithPointer:(__bridge const void *)(node)]] = self.animationManager;
    }

    if (cleanUp) {
        [self cleanUpNodeGraph:node];
    }

    return node;
}

#pragma mark - CCB File Loading

- (SKNode *)nodeGraphFromFilePath:(NSString *)filePath {
    if (![filePath hasSuffix:@".ccbi"]) filePath = [filePath stringByAppendingString:@".ccbi"];

    NSString *path = [[CCFileUtils sharedFileUtils] fullPathForFilename:filePath];
    NSData *d = [NSData dataWithContentsOfFile:path];

    return [self nodeGraphFromData:d];
}

- (SKNode *)nodeGraphFromData:(NSData *)d {
    // Setup byte array
    data = d;
    bytes = (unsigned char *)[d bytes];
    currentByte = 0;
    currentBit = 0;

    NSMutableDictionary *animationManagers = [NSMutableDictionary dictionary];
    SKNode *nodeGraph = [self readFileWithCleanUp:YES actionManagers:animationManagers];
    if (!nodeGraph) return nil;

    for (NSValue *pointerValue in animationManagers) {
        SKNode *node = [pointerValue pointerValue];

        CCBAnimationManager *manager = animationManagers[pointerValue];
        node.userObject = manager;
    }

    // Call didLoadFromCCB
    [CCBReader callDidLoadFromCCBForNodeGraph:nodeGraph];

    return nodeGraph;
}

+ (void)callDidLoadFromCCBForNodeGraph:(SKNode *)nodeGraph {
    for (SKNode *child in nodeGraph.children) {
        [CCBReader callDidLoadFromCCBForNodeGraph:child];
    }

    if ([nodeGraph respondsToSelector:@selector(didLoadFromCCB)]) {
        [nodeGraph performSelector:@selector(didLoadFromCCB)];
    }
}

+ (void)setResourcePath:(NSString *)searchPath {
    NSMutableArray *array = [[[CCFileUtils sharedFileUtils] searchPath] mutableCopy];
    [array addObject:searchPath];
    [[CCFileUtils sharedFileUtils] setSearchPath:array];
}

#pragma mark - Class Methods

+ (void)configureCCFileUtils {
    CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];

    // Setup file utils for use with SpriteBuilder
    [sharedFileUtils setEnableiPhoneResourcesOniPad:NO];

    sharedFileUtils.directoriesDict =
        [@{ CCFileUtilsSuffixiPad : @"resources-tablet",
            CCFileUtilsSuffixiPadHD : @"resources-tablethd",
            CCFileUtilsSuffixiPhone : @"resources-phone",
            CCFileUtilsSuffixiPhoneHD : @"resources-phonehd",
            CCFileUtilsSuffixiPhone5 : @"resources-phone",
            CCFileUtilsSuffixiPhone5HD : @"resources-phonehd",
            CCFileUtilsSuffixiPhone3x : @"resources-phone3x",
            CCFileUtilsSuffixDefault : @"" } mutableCopy];


    NSString *resourcePath = [[NSBundle mainBundle] resourcePath] ?: @"";
    sharedFileUtils.searchPath =
        @[ [resourcePath stringByAppendingPathComponent:@"Published-iOS"],
            resourcePath ];

    sharedFileUtils.enableiPhoneResourcesOniPad = YES;
    sharedFileUtils.searchMode = CCFileUtilsSearchModeDirectory;
    [sharedFileUtils buildSearchResolutionsOrder];

    [sharedFileUtils loadFilenameLookupDictionaryFromFile:@"fileLookup.plist"];
}

+ (NSString *)ccbDirectoryPath {
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [searchPaths[0] stringByAppendingPathComponent:@"ccb"];
}

+ (NSArray *)deprecatedKeys {
    return @[ @"buildIn", @"buildOut" ];
}

#pragma mark - Class Convenience Methods

+ (CCBReader *)readerWithOwner:(id)owner parentSize:(CGSize)parentSize animationManager:(CCBAnimationManager *)animationManager {
    // Reset delegate since it's strong :facepalm:
    CCBReader *currentReader = [[PCReaderManager sharedManager] currentReader];
    [currentReader.animationManager setDelegate:nil];

    CCBReader *reader = [[CCBReader alloc] initWithOwner:owner parentSize:parentSize animationManager:animationManager];
    [[PCReaderManager sharedManager] setCurrentReader:reader];
    return reader;
}

+ (SKNode *)nodeGraphFromFilePath:(NSString *)filePath owner:(id)owner parentSize:(CGSize)parentSize animationManager:(CCBAnimationManager *)animationManager {
    return [[CCBReader readerWithOwner:owner parentSize:parentSize animationManager:animationManager] nodeGraphFromFilePath:filePath];
}

+ (SKNode *)nodeGraphFromData:(NSData *)data owner:(id)owner parentSize:(CGSize)parentSize animationManager:(CCBAnimationManager *)animationManager {
    return [[CCBReader readerWithOwner:owner parentSize:parentSize animationManager:animationManager] nodeGraphFromData:data];
}

@end
