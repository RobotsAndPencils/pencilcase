//
//  PCParticleSystem.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-08-27.
//
//

#if TARGET_IPHONE_SIMULATOR
#define PLATFORM_IOS
#elif TARGET_OS_IPHONE
#define PLATFORM_IOS
#elif TARGET_OS_MAC
#define PLATFORM_MAC
#endif


#import "PCParticleSystem.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+CoordinateConversion.h"
#import "PCResourceManager.h"

#ifdef PLATFORM_MAC
#import "SKNode+NodeInfo.h"
#import "NodeInfo.h"
#import "SKNode+Template.h"
#endif

// Not sure the best way to avoid defining these in every plugin that needs them :?
#define PARTICLE_RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) / (CGFloat)M_PI * 180.0f)
#define PARTICLE_DEGREES_TO_RADIANS(__ANGLE__) ((CGFloat)M_PI * (__ANGLE__) / 180.0f)

@interface PCParticleSystem ()

@property (strong, nonatomic) SKEmitterNode *emitterNode;
@property (assign, nonatomic) CGFloat birthRate;
@property (assign, nonatomic) CGFloat savedBirthRate;
@property (assign, nonatomic) CGFloat particleRotationDegrees;
@property (assign, nonatomic) CGFloat particleRotationDegreesRange;
@property (assign, nonatomic) CGFloat emissionAngleDegrees;
@property (assign, nonatomic) CGFloat emissionAngleDegreesRange;
@property (strong, nonatomic) SKColor *startColor;
@property (strong, nonatomic) SKColor *endColor;
@property (assign, nonatomic) BOOL resetOnVisibilityToggle;
@property (assign, nonatomic) CGPoint gravity;

@end

@implementation PCParticleSystem

@synthesize birthRate = _birthRate;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.emitterNode = [SKEmitterNode node];
        [self addChild:self.emitterNode];

#ifdef PLATFORM_MAC
        // So that anchor point adjustments keep centered
        self.emitterNode.userObject = [NodeInfo nodeInfoWithPlugIn:nil];
#endif

        self.emitterNode.particleColorBlendFactor = 1;
        self.emitterNode.particleColorSequence = [self colorSequenceWithStartColor:[SKColor whiteColor] endColor:[SKColor whiteColor]];
    }
    return self;
}

#pragma mark - Resize Behaviour

#ifdef PLATFORM_MAC
- (PCEditorResizeBehaviour)editorResizeBehaviour {
    return PCEditorResizeBehaviourContentSize;
}
#endif

#pragma mark - Template

#ifdef PLATFORM_MAC
- (void)didApplyTemplate {
    [super didApplyTemplate];
    [self stopSystem];
    [self resetSystem];
}
#endif

#pragma mark - Private

- (SKKeyframeSequence *)colorSequenceWithStartColor:(SKColor *)startColor endColor:(SKColor *)endColor {
    SKKeyframeSequence *sequence = [[SKKeyframeSequence alloc] initWithKeyframeValues:@[ startColor, endColor] times:@[ @0, @(1) ]];
    return sequence;
}

- (void)updateParticleRangeFromSize {
    self.emitterNode.particlePositionRange = CGVectorMake(self.contentSize.width, self.contentSize.height);
}

- (void)updateSizeFromParticleRange {
    self.contentSize = CGSizeMake(self.emitterNode.particlePositionRange.dx, self.emitterNode.particlePositionRange.dy);
}

#pragma mark - Public

- (void)stopSystem {
    self.emitterNode.particleBirthRate = 0;
    [self.emitterNode resetSimulation];
}

- (void)resetSystem {
    self.emitterNode.particleBirthRate = self.savedBirthRate;
    [self.emitterNode resetSimulation];
}

- (void)showMissingResourceImageIfResourceMissing {
    NSString *uuid = [self extraPropForKey:@"particleTexture"];
    if (![[PCResourceManager sharedManager] resourceWithUUID:uuid]) {
        [self showMissingResourceImageWithKey:@"particleTexture"];
    }
}

#pragma mark - Properties

#pragma mark Self

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (self.resetOnVisibilityToggle && !hidden) {
        [self.emitterNode resetSimulation];
    }
}

- (void)setSize:(CGSize)size {
    [super setSize:size];
    [self updateParticleRangeFromSize];
}

#pragma mark Emitter

- (void)setBirthRate:(CGFloat)birthRate {
    self.emitterNode.particleBirthRate = birthRate;
    self.savedBirthRate = birthRate;
}

- (CGFloat)birthRate {
    // Always return the saved birth rate to be encoded.
    return self.savedBirthRate;
}

- (CGFloat)particleRotationDegrees {
    return PARTICLE_RADIANS_TO_DEGREES(self.emitterNode.particleRotation);
}

- (void)setParticleRotationDegrees:(CGFloat)particleRotationDegrees {
    self.emitterNode.particleRotation = PARTICLE_DEGREES_TO_RADIANS(particleRotationDegrees);
}

- (CGFloat)particleRotationDegreesRange {
    return PARTICLE_RADIANS_TO_DEGREES(self.emitterNode.particleRotationRange);
}

- (void)setParticleRotationDegreesRange:(CGFloat)particleRotationDegreesRange {
    self.emitterNode.particleRotationRange = PARTICLE_DEGREES_TO_RADIANS(particleRotationDegreesRange);
}

- (CGFloat)emissionAngleDegrees {
    return PARTICLE_RADIANS_TO_DEGREES(self.emitterNode.emissionAngle);
}

- (void)setEmissionAngleDegrees:(CGFloat)emissionAngleDegrees {
    self.emitterNode.emissionAngle = PARTICLE_DEGREES_TO_RADIANS(emissionAngleDegrees);
}

- (CGFloat)emissionAngleDegreesRange {
    return PARTICLE_RADIANS_TO_DEGREES(self.emitterNode.emissionAngleRange);
}

- (void)setEmissionAngleDegreesRange:(CGFloat)emissionAngleDegreesRange {
    self.emitterNode.emissionAngleRange = PARTICLE_DEGREES_TO_RADIANS(emissionAngleDegreesRange);
}

- (SKColor *)startColor {
    return [self.emitterNode.particleColorSequence sampleAtTime:0];
}

- (void)setStartColor:(SKColor *)startColor {
    self.emitterNode.particleColorSequence = [self colorSequenceWithStartColor:startColor endColor:self.endColor];
}

- (SKColor *)endColor {
    return [self.emitterNode.particleColorSequence sampleAtTime:1];
}

- (void)setEndColor:(SKColor *)endColor {
    self.emitterNode.particleColorSequence = [self colorSequenceWithStartColor:self.startColor endColor:endColor];
}

- (CGPoint)gravity {
    return CGPointMake(self.emitterNode.xAcceleration, self.emitterNode.yAcceleration);
}

- (void)setGravity:(CGPoint)gravity {
    self.emitterNode.xAcceleration = gravity.x;
    self.emitterNode.yAcceleration = gravity.y;
}

- (void)setParticlePositionRange:(CGVector)range {
    self.emitterNode.particlePositionRange = range;
    [self updateSizeFromParticleRange];
}

#pragma mark Just for side effects

- (void)setParticleTexture:(SKTexture *)particleTexture {
    [self.emitterNode setParticleTexture:particleTexture];
}

#pragma mark - Forward

// Generated in an editor with multiple cursors :)
#define IsForwardSelector(aSelector) aSelector == @selector(particleTexture) \
|| aSelector == @selector(setParticleTexture:) \
|| aSelector == @selector(particleZPosition) \
|| aSelector == @selector(setParticleZPosition:) \
|| aSelector == @selector(particleZPositionRange) \
|| aSelector == @selector(setParticleZPositionRange:) \
|| aSelector == @selector(particleZPositionSpeed) \
|| aSelector == @selector(setParticleZPositionSpeed:) \
|| aSelector == @selector(particleBlendMode) \
|| aSelector == @selector(setParticleBlendMode:) \
|| aSelector == @selector(particleColor) \
|| aSelector == @selector(setParticleColor:) \
|| aSelector == @selector(particleColorRedRange) \
|| aSelector == @selector(setParticleColorRedRange:) \
|| aSelector == @selector(particleColorGreenRange) \
|| aSelector == @selector(setParticleColorGreenRange:) \
|| aSelector == @selector(particleColorBlueRange) \
|| aSelector == @selector(setParticleColorBlueRange:) \
|| aSelector == @selector(particleColorAlphaRange) \
|| aSelector == @selector(setParticleColorAlphaRange:) \
|| aSelector == @selector(particleColorRedSpeed) \
|| aSelector == @selector(setParticleColorRedSpeed:) \
|| aSelector == @selector(particleColorGreenSpeed) \
|| aSelector == @selector(setParticleColorGreenSpeed:) \
|| aSelector == @selector(particleColorBlueSpeed) \
|| aSelector == @selector(setParticleColorBlueSpeed:) \
|| aSelector == @selector(particleColorAlphaSpeed) \
|| aSelector == @selector(setParticleColorAlphaSpeed:) \
|| aSelector == @selector(particleColorSequence) \
|| aSelector == @selector(setParticleColorSequence:) \
|| aSelector == @selector(particleColorBlendFactor) \
|| aSelector == @selector(setParticleColorBlendFactor:) \
|| aSelector == @selector(particleColorBlendFactorRange) \
|| aSelector == @selector(setParticleColorBlendFactorRange:) \
|| aSelector == @selector(particleColorBlendFactorSpeed) \
|| aSelector == @selector(setParticleColorBlendFactorSpeed:) \
|| aSelector == @selector(particleColorBlendFactorSequence) \
|| aSelector == @selector(setParticleColorBlendFactorSequence:) \
|| aSelector == @selector(particlePosition) \
|| aSelector == @selector(setParticlePosition:) \
|| aSelector == @selector(particlePositionRange) \
|| aSelector == @selector(setParticlePositionRange:) \
|| aSelector == @selector(particleSpeed) \
|| aSelector == @selector(setParticleSpeed:) \
|| aSelector == @selector(particleSpeedRange) \
|| aSelector == @selector(setParticleSpeedRange:) \
|| aSelector == @selector(emissionAngle) \
|| aSelector == @selector(setEmissionAngle:) \
|| aSelector == @selector(emissionAngleRange) \
|| aSelector == @selector(setEmissionAngleRange:) \
|| aSelector == @selector(xAcceleration) \
|| aSelector == @selector(setXAcceleration:) \
|| aSelector == @selector(yAcceleration) \
|| aSelector == @selector(setYAcceleration:) \
|| aSelector == @selector(particleBirthRate) \
|| aSelector == @selector(setParticleBirthRate:) \
|| aSelector == @selector(numParticlesToEmit) \
|| aSelector == @selector(setNumParticlesToEmit:) \
|| aSelector == @selector(particleLifetime) \
|| aSelector == @selector(setParticleLifetime:) \
|| aSelector == @selector(particleLifetimeRange) \
|| aSelector == @selector(setParticleLifetimeRange:) \
|| aSelector == @selector(particleRotation) \
|| aSelector == @selector(setParticleRotation:) \
|| aSelector == @selector(particleRotationRange) \
|| aSelector == @selector(setParticleRotationRange:) \
|| aSelector == @selector(particleRotationSpeed) \
|| aSelector == @selector(setParticleRotationSpeed:) \
|| aSelector == @selector(particleSize) \
|| aSelector == @selector(setParticleSize:) \
|| aSelector == @selector(particleScale) \
|| aSelector == @selector(setParticleScale:) \
|| aSelector == @selector(particleScaleRange) \
|| aSelector == @selector(setParticleScaleRange:) \
|| aSelector == @selector(particleScaleSpeed) \
|| aSelector == @selector(setParticleScaleSpeed:) \
|| aSelector == @selector(particleScaleSequence) \
|| aSelector == @selector(setParticleScaleSequence:) \
|| aSelector == @selector(particleAlpha) \
|| aSelector == @selector(setParticleAlpha:) \
|| aSelector == @selector(particleAlphaRange) \
|| aSelector == @selector(setParticleAlphaRange:) \
|| aSelector == @selector(particleAlphaSpeed) \
|| aSelector == @selector(setParticleAlphaSpeed:) \
|| aSelector == @selector(particleAlphaSequence) \
|| aSelector == @selector(setParticleAlphaSequence:) \
|| aSelector == @selector(particleAction) \
|| aSelector == @selector(setParticleAction:) \
|| aSelector == @selector(fieldBitMask) \
|| aSelector == @selector(setFieldBitMask:) \
|| aSelector == @selector(targetNode) \
|| aSelector == @selector(setTargetNode:) \
|| aSelector == @selector(shader) \
|| aSelector == @selector(setShader:)

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if (IsForwardSelector(aSelector)) {
        return self.emitterNode;
    }
    return nil;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    [self.emitterNode setValue:value forKey:key];
}

- (id)valueForUndefinedKey:(NSString *)key {
    return [self.emitterNode valueForKey:key];
}

@end
