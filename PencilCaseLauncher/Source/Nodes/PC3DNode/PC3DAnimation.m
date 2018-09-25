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
        self.repeatCount = (NSUInteger)[coder decodeInt64ForKey:@"self.repeatCount"];
        self.fadeInDuration = (CGFloat) [coder decodeDoubleForKey:@"self.fadeInDuration"];
        self.fadeOutDuration = (CGFloat) [coder decodeDoubleForKey:@"self.fadeOutDuration"];
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

#pragma mark - Properties

- (CGFloat)duration {
    if (self.repeatCount == NSIntegerMax) return INFINITY;
    return (CGFloat) (self.animation.duration * (self.repeatCount + 1));
}

- (void)setRepeatForever:(BOOL)repeatForever {
    self.repeatCount = repeatForever ? NSIntegerMax : 0;
}

#pragma mark - Public

- (void)refresh {
    self.animation.repeatCount = self.repeatCount;     
    self.animation.fadeInDuration = self.fadeInDuration;
    self.animation.fadeOutDuration = self.fadeOutDuration;
}

@end
