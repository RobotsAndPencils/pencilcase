//
//  PCTemplate.m
//  CocosBuilder
//
//  Created by Viktor on 7/30/13.
//
//

#import "PCResourceManager.h"
#import "PCTemplate.h"
#import "SKNode+NodeInfo.h"
#import "SKNode+Template.h"
#import "PlugInNode.h"
#import "HashValue.h"
#import "CCBWriterInternal.h"
#import "CCBReaderInternal.h"
#import "NSImage+PNGRepresentation.h"
#import "PCTemplateLibrary.h"

@implementation PCTemplate

#pragma mark - NSCoder

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.image forKey:@"image"];
    [coder encodeObject:self.nodeType forKey:@"nodeType"];
    [coder encodeObject:self.color forKey:@"color"];
    [coder encodeObject:self.properties forKey:@"properties"];
    [coder encodeObject:self.projectSetupProperties forKey:@"projectSetupProperties"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.name = [coder decodeObjectForKey:@"name"];
        self.image = [coder decodeObjectForKey:@"image"];
        self.nodeType = [coder decodeObjectForKey:@"nodeType"];
        self.color = [coder decodeObjectForKey:@"color"];
        self.properties = [coder decodeObjectForKey:@"properties"];
        self.projectSetupProperties = [coder decodeObjectForKey:@"projectSetupProperties"];
    }
    return self;
}

- (instancetype)initWithNode:(SKNode *)node name:(NSString *)name bgColor:(NSColor *)color {
    self = [super init];
    if (!self) return nil;

    color = [color colorUsingColorSpaceName:NSDeviceRGBColorSpace];

    self.name = name;
    self.color = color;

    PlugInNode *plugIn = node.plugIn;

    NSString *className = plugIn.nodeClassName;
    self.nodeType = className;

    // Generate image
    [self savePreviewForNode:node size:CGSizeMake(256, 256) backgroundColor:color filePath:[self imageFilePath]];
    self.image = [[NSImage alloc] initWithContentsOfFile:[self imageFilePath]];

    // Save properties
    NSMutableArray *properties = [NSMutableArray array];

    NSArray *plugInProperties = plugIn.nodeProperties;

    for (NSMutableDictionary *propertyInfo in plugInProperties) {
        if (![propertyInfo[@"saveInTemplate"] boolValue]) continue;

        id serializedValue = [CCBWriterInternal serializePropertyForSpriteKitNode:node propInfo:propertyInfo excludeProps:nil];

        NSMutableDictionary *serializedProperties = [NSMutableDictionary dictionary];
        serializedProperties[@"value"] = serializedValue;
        serializedProperties[@"type"] = propertyInfo[@"type"];
        serializedProperties[@"name"] = propertyInfo[@"name"];

        if (serializedValue) {
            [properties addObject:serializedProperties];
        }
        else {
            PCLog(@"WARNING! Failed to serialize value: %@", propertyInfo);
        }
    }

    self.properties = properties;

    return self;
}

- (void)applyToNode:(SKNode *)node {
    for (NSDictionary *propertyInfo in self.properties) {
        NSString *type = propertyInfo[@"type"];
        NSString *name = propertyInfo[@"name"];
        id serializedValue = propertyInfo[@"value"];

        [CCBReaderInternal setProp:name ofType:type toValue:serializedValue forSpriteKitNode:node parentSize:CGSizeZero];
    }
    [node didApplyTemplate];
}

- (instancetype)initWithSerialization:(NSDictionary *)dictionary {
    self = [super init];
    if (!self) return nil;

    NSArray *components = dictionary[@"color"];
    float r = [components[0] floatValue];
    float g = [components[1] floatValue];
    float b = [components[2] floatValue];
    NSColor *color = [NSColor colorWithDeviceRed:r green:g blue:b alpha:1];

    self.name = dictionary[@"name"];
    self.color = color;
    self.nodeType = dictionary[@"nodeType"];

    self.image = [[NSImage alloc] initWithContentsOfFile:[self imageFilePath]];

    self.properties = dictionary[@"properties"];
    self.projectSetupProperties = dictionary[@"projectSetupProperties"];

    return self;
}

- (NSDictionary *)serialization {
    NSMutableDictionary *serialization = [NSMutableDictionary dictionary];

    CGFloat r, g, b, a;
    [self.color getRed:&r green:&g blue:&b alpha:&a];
    NSArray *components = @[ @(r), @(g), @(b) ];

    serialization[@"name"] = self.name;
    serialization[@"color"] = components;
    serialization[@"nodeType"] = self.nodeType;

    if (self.properties) {
        serialization[@"properties"] = self.properties;
    }
    if (self.projectSetupProperties) {
        serialization[@"projectSetupProperties"] = self.projectSetupProperties;
    }

    return serialization;
}

- (NSString *)imageFilePath {
    HashValue *hash = [HashValue md5HashWithString:[NSString stringWithFormat:@"%@:%@", self.nodeType, self.name]];
    return [[[PCTemplateLibrary templateDirectory] stringByAppendingPathComponent:[hash description]] stringByAppendingPathExtension:@"png"];
}

- (void)savePreviewForNode:(SKNode *)node size:(CGSize)size backgroundColor:(NSColor *)backgroundColor filePath:(NSString *)filePath {
    if ([node.scene.view respondsToSelector:@selector(textureFromNode:crop:)]) {
        SKTexture *texture = [node.scene.view textureFromNode:node];

        SKSpriteNode *renderNode = [SKSpriteNode spriteNodeWithColor:backgroundColor size:size];
        SKSpriteNode *particleSnapshot = [SKSpriteNode spriteNodeWithTexture:texture];
        [renderNode addChild:particleSnapshot];

        renderNode.zPosition = CGFLOAT_MAX;
        [node.scene addChild:renderNode];
        SKTexture *finalTexture = [node.scene.view textureFromNode:renderNode];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        SEL selector = @selector(_savePngFromGLCache:);
        if ([finalTexture respondsToSelector:selector]) {
            [finalTexture performSelector:selector withObject:filePath];
        }
#pragma clang diagnostic pop

        [renderNode removeFromParent];
    }
    else {
        NSImage *snapshotImage = [[NSImage alloc] initWithSize:size];
        [snapshotImage lockFocus];
        [backgroundColor drawSwatchInRect:NSMakeRect(0, 0, size.width, size.height)];
        [snapshotImage unlockFocus];
        [[snapshotImage PNGRepresentation] writeToFile:filePath atomically:NO];
    }
}

- (void)updatePropertyName:(NSString *)propertyName value:(NSString *)newValue {
    NSUInteger propertyIndex = [self.properties indexOfObjectPassingTest:^BOOL(NSDictionary *eachProperty, NSUInteger idx, BOOL *stop) {
        return [eachProperty[@"name"] isEqualToString:propertyName];
    }];
    NSMutableDictionary *updatedPropertyDictionary = [self.properties[propertyIndex] mutableCopy];
    updatedPropertyDictionary[@"value"] = newValue;

    NSMutableArray *mutableProperties = self.properties.mutableCopy;
    mutableProperties[propertyIndex] = updatedPropertyDictionary.copy;
    self.properties = mutableProperties.copy;
}

@end
