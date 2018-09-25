//
//  PC3DAnimation.m
//  SpriteBuilder
//
//  Created by Reuben Lee on 2015-04-02.
//
//

#import "PC3DAnimation.h"
#import <QuartzCore/QuartzCore.h>

@interface PC3DAnimation () <NSCoding>

@end

@implementation PC3DAnimation

- (instancetype)init {
    self = [super init];
    if (self) {
        self.fadeInDuration = 0.15;
        self.fadeOutDuration = 0.15;
        self.repeatCount = NSIntegerMax;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.name = [coder decodeObjectForKey:@"self.name"];
        self.skeletonName = [coder decodeObjectForKey:@"self.skeletonName"];
        self.repeatCount = [coder decodeInt64ForKey:@"self.repeatCount"];
        self.fadeInDuration = [coder decodeDoubleForKey:@"self.fadeInDuration"];
        self.fadeOutDuration = [coder decodeDoubleForKey:@"self.fadeOutDuration"];
        self.animation = [coder decodeObjectForKey:@"self.animation"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"self.name"];
    [coder encodeObject:self.skeletonName forKey:@"self.skeletonName"];
    [coder encodeInt64:self.repeatCount forKey:@"self.repeatCount"];
    [coder encodeDouble:self.fadeInDuration forKey:@"self.fadeInDuration"];
    [coder encodeDouble:self.fadeOutDuration forKey:@"self.fadeOutDuration"];
    [coder encodeObject:self.animation forKey:@"self.animation"];
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;
    return [self isEqualToAnimation:other];
}

- (BOOL)isEqualToAnimation:(PC3DAnimation *)animation {
    if (self == animation)
        return YES;
    if (animation == nil)
        return NO;
    if (self.name != animation.name && ![self.name isEqualToString:animation.name])
        return NO;
    if (self.skeletonName != animation.skeletonName && ![self.skeletonName isEqualToString:animation.skeletonName])
        return NO;
    if (self.repeatCount != animation.repeatCount)
        return NO;
    if (self.fadeInDuration != animation.fadeInDuration)
        return NO;
    if (self.fadeOutDuration != animation.fadeOutDuration)
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.name hash];
    hash = hash * 31u + [self.animation hash];
    hash = hash * 31u + [self.skeletonName hash];
    hash = hash * 31u + self.repeatCount;
    hash = hash * 31u + [[NSNumber numberWithDouble:self.fadeInDuration] hash];
    hash = hash * 31u + [[NSNumber numberWithDouble:self.fadeOutDuration] hash];
    return hash;
}

- (id)copyWithZone:(NSZone *)zone {
    PC3DAnimation *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.name = [self.name copy];
        copy.animation = [self.animation copy];
        copy.skeletonName = [self.skeletonName copy];
        copy.repeatCount = self.repeatCount;
        copy.fadeInDuration = self.fadeInDuration;
        copy.fadeOutDuration = self.fadeOutDuration;
    }

    return copy;
}

#pragma mark - Properties

- (CGFloat)duration {
    if (self.repeatCount == NSIntegerMax) return INFINITY;
    return self.animation.duration * (self.repeatCount + 1);
}

#pragma mark - Public

- (void)refresh {
    self.animation.repeatCount = self.repeatCount;     
    self.animation.fadeInDuration = self.fadeInDuration;
    self.animation.fadeOutDuration = self.fadeOutDuration;
}

@end
