//
//  PCTokenValueDescriptor.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-02.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCTokenValueDescriptor.h"
#import <Mantle/MTLModel+NSCoding.h>
#import "PCTokenAttachment.h"
#import "NSString+CamelCase.h"
#import "Constants.h"
#import "PCResourceManager.h"
#import "PCBehavioursDataSource.h"
#import "BehavioursStyleKit.h"

@interface PCTokenValueDescriptor ()

@property (copy, nonatomic) NSString *name;
@property (assign, nonatomic) PCTokenEvaluationType evaluationType;
@property (copy, readwrite, nonatomic) NSObject<NSCopying, NSSecureCoding> *value;

@end

@implementation PCTokenValueDescriptor

@synthesize token = _token;
@synthesize value = _value;

+ (instancetype)descriptorWithName:(NSString *)name evaluationType:(PCTokenEvaluationType)evaluationType value:(NSObject<NSSecureCoding,NSCopying> *)value {
    PCTokenValueDescriptor *descriptor = [[PCTokenValueDescriptor alloc] init];
    descriptor.name = name;
    descriptor.value = value;
    descriptor.evaluationType = evaluationType;
    return descriptor;
}

#pragma mark - PCTokenDescriptor

- (NSString *)displayName {
    if ([self.name length] > 0) return self.name;
    switch (self.evaluationType) {
        case PCTokenEvaluationTypeString: {
            return [NSString stringWithFormat:@"\"%@\"", self.value];
        }
        case PCTokenEvaluationTypePoint: {
            NSDictionary *info = (id)self.value;
            id xValue = info[@"x"] ?: @"-";
            id yValue = info[@"y"] ?: @"-";
            return [NSString stringWithFormat:@"(%@, %@)", xValue, yValue];
        }
        case PCTokenEvaluationTypeSize: {
            NSDictionary *info = (id)self.value;
            id xValue = info[@"width"] ?: @"-";
            id yValue = info[@"height"] ?: @"-";
            return [NSString stringWithFormat:@"(%@, %@)", xValue, yValue];
        }
        case PCTokenEvaluationTypeScale: {
            NSDictionary *info = (id)self.value;
            id xValue = info[@"x"] ?: @"-";
            id yValue = info[@"y"] ?: @"-";
            return [NSString stringWithFormat:@"(%@, %@)", xValue, yValue];
        }
        case PCTokenEvaluationTypeVector: {
            NSDictionary *info = (id)self.value;
            id xValue = info[@"dx"] ?: @"-";
            id yValue = info[@"dy"] ?: @"-";
            return [NSString stringWithFormat:@"(%@, %@)", xValue, yValue];
        }
        case PCTokenEvaluationTypeNumber: {
            return [[self.class numberFormatter] stringFromNumber:(id)self.value] ?: @"0";
        }
        case PCTokenEvaluationTypeColor: {
            NSColor *color = (id)self.value;
            color = [color colorUsingColorSpaceName:NSDeviceColorSpaceName];
            CGFloat red, green, blue, alpha;
            [color getRed:&red green:&green blue:&blue alpha:&alpha];
            return [NSString stringWithFormat:@"(%f.2, %f.2, %f.2, %f.2)", red, green, blue, alpha];
        }
        default:
            break;
    }
    return [self.value description];
}

- (PCTokenType)tokenType {
    return PCTokenTypeValue;
}

- (NSAttributedString *)attributedDisplayName {
    switch (self.evaluationType) {
        case PCTokenEvaluationTypeColor: {
            return [[NSAttributedString alloc] initWithString:@"⬤" attributes:@{ NSForegroundColorAttributeName: self.value }];
        }
        case PCTokenEvaluationTypeNode:
        case PCTokenEvaluationTypeNodeType:
        case PCTokenEvaluationTypeProperty:
        case PCTokenEvaluationTypeTexture:
        case PCTokenEvaluationTypeImage:
        case PCTokenEvaluationTypeBeacon:
        case PCTokenEvaluationTypeTimeline: {
            return [PCTokenAttachment attachmentForToken:self.token];
        }
        default: {
            NSColor *color = self.token.isInvalidReference ? [NSColor redColor] : [BehavioursStyleKit darkBlueColor];
            return [[NSAttributedString alloc] initWithString:self.displayName attributes:@{ NSForegroundColorAttributeName: color }];
        }
    }
}

- (PCNodeType)nodeType {
    if (self.evaluationType == PCTokenEvaluationTypeNodeType) {
        return [(NSNumber *)self.value integerValue];
    }
    return PCNodeTypeUnknown;
}

- (BOOL)isReferenceType {
    switch (self.evaluationType) {
        case PCTokenEvaluationTypeCard:
        case PCTokenEvaluationTypeNode:
        case PCTokenEvaluationTypeNodeType:
        case PCTokenEvaluationTypeProperty:
        case PCTokenEvaluationTypeTexture:
        case PCTokenEvaluationTypeImage:
        case PCTokenEvaluationTypeBeacon:
        case PCTokenEvaluationTypeTimeline:
        case PCTokenEvaluationTypeTemplate:
            return YES;
        default:
            return NO;
    }
}

- (PCPropertyType)propertyType {
    if (self.evaluationType == PCTokenEvaluationTypeProperty) {
        NSDictionary *info = (NSDictionary *)self.value;
        return (PCPropertyType)[info[@"propertyType"] integerValue];
    }
    return PCPropertyTypeNotSupported;
}

#pragma mark - Private

+ (NSNumberFormatter *)numberFormatter {
    static NSNumberFormatter *numberFormatter;
    if (!numberFormatter) {
        numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.formatterBehavior = NSNumberFormatterBehavior10_4;
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    }
    return numberFormatter;
}

#pragma mark - MTLModel

+ (NSSet *)excludedPropertyKeys {
    return [NSSet setWithArray:@[ @"token" ]];
}

+ (NSSet *)propertyKeys {
    NSMutableSet *keys = [[super propertyKeys] mutableCopy];
    for (id key in [self excludedPropertyKeys]) {
        [keys removeObject:key];
    }
    return [keys copy];
}

#pragma mark - JavaScriptRepresentable

//TODO: need to clarify and document the names and values for all of these types
- (NSString *)javaScriptRepresentation {
    switch (self.evaluationType) {
        case PCTokenEvaluationTypeNumber:
            return [[self.class numberFormatter] stringFromNumber:(id)self.value];
        case PCTokenEvaluationTypeBOOL:
            return [(id)self.value boolValue] ? @"true" : @"false";
        case PCTokenEvaluationTypeString:
            return [NSString stringWithFormat:@"'%@'", self.value];
        case PCTokenEvaluationTypeJavaScript:
            return (NSString *)self.value;
        case PCTokenEvaluationTypePoint: {
            NSDictionary *info = (id)self.value;
            id x = info[@"x"] ?: @"0";
            id y = info[@"y"] ?: @"0";
            return [NSString stringWithFormat:@"{ x: %@, y: %@ }", x, y];
        }
        case PCTokenEvaluationTypeSize: {
            NSDictionary *info = (id)self.value;
            id width = info[@"width"] ?: @"0";
            id height = info[@"height"] ?: @"0";
            return [NSString stringWithFormat:@"{ width: %@, height: %@ }", width, height];
        }
        case PCTokenEvaluationTypeScale: {
            NSDictionary *info = (id)self.value;
            id xScale = info[@"x"] ?: @"0";
            id yScale = info[@"y"] ?: @"0";
            return [NSString stringWithFormat:@"{ x: %@, y: %@ }", xScale, yScale];
        }
        case PCTokenEvaluationTypeVector: {
            NSDictionary *info = (id)self.value;
            id dx = info[@"dx"] ?: @"0";
            id dy = info[@"dy"] ?: @"0";
            return [NSString stringWithFormat:@"{ dx: %@, dy: %@ }", dx, dy];
        }
        case PCTokenEvaluationTypeColor: {
            NSColor *color = (id)self.value;
            color = [color colorUsingColorSpaceName:NSDeviceRGBColorSpace];
            CGFloat red, green, blue, alpha;
            [color getRed:&red green:&green blue:&blue alpha:&alpha];
            return [NSString stringWithFormat:@"Color.colorWithRGBAComponents(%f, %f, %f, %f)", red, green, blue, alpha];
        }
        case PCTokenEvaluationTypeCard:
            return [NSString stringWithFormat:@"Creation.cardWithUUID('%@')", self.value];
        case PCTokenEvaluationTypeNode:
            return [NSString stringWithFormat:@"Creation.nodeWithUUID('%@')", self.value];
        case PCTokenEvaluationTypeProperty: {
            NSDictionary *info = (NSDictionary *)self.value;
            return info[@"propertyName"] ?: @"";
        }
        case PCTokenEvaluationTypeNodeType:
            return [PCBehavioursDataSource javaScriptNameForObjectType:(PCNodeType)[(NSNumber *)self.value integerValue]];
        case PCTokenEvaluationTypeTexture: {
            NSUUID *uuid = (NSUUID *)self.value;
            return [NSString stringWithFormat:@"Texture.textureWithUUID('%@')", [uuid UUIDString]];
        }
        case PCTokenEvaluationTypeImage: {
            NSUUID *uuid = (NSUUID *)self.value;
            return [NSString stringWithFormat:@"Image.imageWithUUID('%@')", [uuid UUIDString]];
        }
        case PCTokenEvaluationTypeTemplate: {
            NSString *name = (NSString *)self.value;
            return name;
        }
        case PCTokenEvaluationTypeTimeline:
            return [NSString stringWithFormat:@"'%@'", self.name];
        case PCTokenEvaluationTypeBeacon: {
            NSDictionary *info = (NSDictionary *)self.value;
            NSString *uuidString = info[@"beaconUUID"];
            NSString *major = info[@"beaconMajor"];
            NSString *minor = info[@"beaconMinor"];
            return [NSString stringWithFormat:@"(new Beacon({ beaconName: '', beaconUUID: '%@', beaconMajorId: '%@', beaconMinorId: '%@' }))", uuidString, major, minor];
        }
        case PCTokenEvaluationTypeTableCell:
            return self.name;
        case PCTokenEvaluationTypeKeyboardInput: {
            NSDictionary *value = (NSDictionary *)self.value;
            NSString *keyCode, *modifier;
            if (value) {
                keyCode = value[@"keycode"];
                modifier = value[@"keycodeModifier"];
                return [NSString stringWithFormat:@"'%@|%@'", keyCode, modifier];
            }
            return @"";
        }
        default:
            return self.name;
    }
    return @"";
}

@end
