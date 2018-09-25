//
//  SKNode+Template.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-29.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "SKNode+Template.h"
#import "CCFileUtils.h"
#import "PCAppViewController.h"
#import "PCApp.h"

@implementation SKNode (Template)

#pragma mark - Public

+ (instancetype)createFromTemplateNamed:(NSString *)name className:(NSString *)className {
    PCApp *app = [PCAppViewController lastCreatedInstance].runningApp;
    if (!app) return nil;

    NSDictionary *template = [self findTemplateNamed:name forClassName:className];
    if (!template) return nil;
    return [self createFromTemplate:template className:className];
}

+ (instancetype)createFromTemplate:(NSDictionary *)template className:(NSString *)className {
    Class class = NSClassFromString(className);
    if (!class) return nil;
    id instance = [[class alloc] init];
    [instance applyTemplate:template];
    return instance;
}

- (void)applyTemplateNamed:(NSString *)name {
    NSDictionary *template = [[self class] findTemplateNamed:name forClassName:NSStringFromClass(self)];
    if (!template) return;
    [self applyTemplate:template];
}

- (void)applyTemplate:(NSDictionary *)template {
    for (NSDictionary *propertyInfo in template[@"properties"]) {
        NSString *type = propertyInfo[@"type"];
        NSString *name = propertyInfo[@"name"];
        id serializedValue = propertyInfo[@"value"];
        [self loadSerializedTemplateValue:serializedValue ofType:type forPropertyName:name];
    }
}

#pragma mark - Private

+ (NSDictionary *)findTemplateNamed:(NSString *)name forClassName:(NSString *)className {
    PCApp *app = [PCAppViewController lastCreatedInstance].runningApp;
    if (!app) return nil;

    NSDictionary *template = [app templateDictionaryWithName:name forClassName:className];
    return template;
}

- (void)loadSerializedTemplateValue:(id)value ofType:(NSString *)type forPropertyName:(NSString *)name {
    NSDictionary *mapping = [self propertyValueMappingForSerializedTemplateValue:value ofType:type forPropertyName:name];
    for (NSString *key in mapping) {
        id value = mapping[key];
        [self setValue:value forKey:key];
    }
}

- (NSDictionary *)propertyValueMappingForSerializedTemplateValue:(id)value ofType:(NSString *)type forPropertyName:(NSString *)name {
    NSMutableDictionary *mapping = [NSMutableDictionary dictionary];
    if ([type isEqualToString:@"Position"]
        || [type isEqualToString:@"Point"]
        || [type isEqualToString:@"PointLock"]) {
        CGFloat x = [value[0] floatValue];
        CGFloat y = [value[1] floatValue];
        mapping[name] = [NSValue valueWithCGPoint:CGPointMake(x, y)];
    }
    else if ([type isEqualToString:@"Size"]) {
        CGFloat w = [value[0] floatValue];
        CGFloat h = [value[1] floatValue];
        mapping[name] = [NSValue valueWithCGSize:CGSizeMake(w, h)];
    }
    else if ([type isEqualToString:@"Scale"]
             || [type isEqualToString:@"ScaleLock"]
             || [type isEqualToString:@"FloatXY"]) {
        CGFloat x = [value[0] floatValue];
        CGFloat y = [value[1] floatValue];
        mapping[[name stringByAppendingString:@"X"]] = @(x);
        mapping[[name stringByAppendingString:@"Y"]] = @(y);
    }
    else if ([type isEqualToString:@"Float"]
             || [type isEqualToString:@"Degrees"]) {
        mapping[name] = value;
    }
    else if ([type isEqualToString:@"FloatScale"]) {
        if ([value isKindOfClass:[NSNumber class]]) {
            // Support for old files
            mapping[name] = value;
        }
        else if ([value isKindOfClass:[NSArray class]]) {
            mapping[name] = [value firstObject];
        }
    }
    else if ([type isEqualToString:@"FloatVar"]) {
        mapping[name] = [value firstObject];
        mapping[[name stringByAppendingString:@"Range"]] = [value objectAtIndex:1];
    }
    else if ([type isEqualToString:@"Integer"]
             || [type isEqualToString:@"IntegerLabeled"]
             || [type isEqualToString:@"Byte"]) {
        mapping[name] = value;
    }
    else if ([type isEqualToString:@"Check"]) {
        mapping[name] = value;
    }
    else if ([type isEqualToString:@"Flip"]) {
        mapping[[name stringByAppendingString:@"X"]] = [value firstObject];
        mapping[[name stringByAppendingString:@"Y"]] = [value objectAtIndex:1];
    }
    else if ([type isEqualToString:@"SpriteFrame"]) {
        SKTexture *texture =  [[CCFileUtils sharedFileUtils] textureForSpriteUUID:value];
        if (texture) {
            mapping[name] = texture;
        } else {
            PCLog(@"Could not load texture for UUID %@", value);
        }
    }
    else if ([type isEqualToString:@"Texture"]) {
        mapping[name] = [[CCFileUtils sharedFileUtils] textureForSpriteUUID:value];
    }
    else if ([type isEqualToString:@"Color4"] ||
             [type isEqualToString:@"Color3"]) {
        CGFloat r,g,b,a;
        r = [value[0] floatValue];
        g = [value[1] floatValue];
        b = [value[2] floatValue];
        a = [value[3] floatValue];
        mapping[name] = [SKColor colorWithRed:r green:g blue:b alpha:a];
    }
    else if ([type isEqualToString:@"Color4FVar"]) {
        CGFloat r,g,b,a;
        r = [value[0] floatValue];
        g = [value[1] floatValue];
        b = [value[2] floatValue];
        a = [value[3] floatValue];
        mapping[name] = [SKColor colorWithRed:r green:g blue:b alpha:a];

        r = [value[0] floatValue];
        g = [value[1] floatValue];
        b = [value[2] floatValue];
        a = [value[3] floatValue];
        mapping[[name stringByAppendingString:@"Range"]] = [SKColor colorWithRed:r green:g blue:b alpha:a];
    }
    else if ([type isEqualToString:@"StringSimple"]) {
        mapping[name] = value ?: @"";
    }
    else if ([type isEqualToString:@"Text"]
             || [type isEqualToString:@"String"]
             || [type isEqualToString:@"JavaScript"]) {
        mapping[name] = value ?: @"";
    }
    else if ([type isEqualToString:@"Dictionary"]
             || [type isEqualToString:@"Build"]
             || [type isEqualToString:@"PCShape"]) {
        NSDictionary *dictionary = value;
        if (![dictionary isKindOfClass:[NSDictionary class]]) {
            dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:value];
        }
        mapping[name] = dictionary;
    }
    else if ([type isEqualToString:@"Array"]) {
        NSArray *array = value;
        if (![array isKindOfClass:[NSArray class]]) {
            array = [NSKeyedUnarchiver unarchiveObjectWithData:value];
        }
        mapping[name] = array;
    }
    else if ([type isEqualToString:@"MutableArray"]) {
        NSMutableArray *array = value;
        if (![array isKindOfClass:[NSMutableArray class]]) {
            array = [NSKeyedUnarchiver unarchiveObjectWithData:value];
        }
        mapping[name] = array;
    }
    else if ([type isEqualToString:@"FontTTF"]) {
        mapping[name] = value;
    }
    else {
        NSLog(@"WARNING Unrecognized property type: %@", type);
    }
    return [mapping copy];
}

@end
