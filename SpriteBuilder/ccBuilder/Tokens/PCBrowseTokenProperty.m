//
//  PCBrowseTokenProperty.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-09-19.
//
//

#import "PCBrowseTokenProperty.h"

typedef NS_ENUM(NSInteger, PCTokenPropertyType) {
    PCTokenPropertyTypePoint,
    PCTokenPropertyTypeSize,
    PCTokenPropertyTypeNumber,
    PCTokenPropertyTypeBOOL,
    PCTokenPropertyTypeString,
};

@interface PCBrowseTokenProperty ()

@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) PCTokenPropertyType type;
@property (strong, nonatomic) NSArray *children;

@end

@implementation PCBrowseTokenProperty

#pragma mark - Public

+ (NSArray *)propertyTokensFromPropertyInfo:(NSDictionary *)propertyInfo {
    NSDictionary *scriptingInfo = propertyInfo[@"scriptingInfo"];
    if (!scriptingInfo) return @[];

    // Sometimes you might need to remove the scriptingInfo dict in a node subclass, so check for a disabled key inside set to true inside
    BOOL scriptingInfoDisabled = [scriptingInfo[@"disabled"] boolValue];
    if (scriptingInfoDisabled) return @[];

    NSString *type = propertyInfo[@"type"];
    NSString *name = propertyInfo[@"name"];
    NSArray *tokens = @[];

    if ([type isEqualToString:@"Position"]
        || [type isEqualToString:@"Point"]) {
        PCBrowseTokenProperty *position = [[self alloc] initWithName:name type:PCTokenPropertyTypePoint];
        PCBrowseTokenProperty *x = [[self alloc] initWithName:@"x" type:PCTokenPropertyTypeNumber];
        PCBrowseTokenProperty *y = [[self alloc] initWithName:@"y" type:PCTokenPropertyTypeNumber];
        position.children = @[x, y];
        tokens = @[ position ];
    }
    else if ([type isEqualToString:@"Size"]) {
        PCBrowseTokenProperty *size = [[self alloc] initWithName:name type:PCTokenPropertyTypeSize];
        PCBrowseTokenProperty *width = [[self alloc] initWithName:@"width" type:PCTokenPropertyTypeNumber];
        PCBrowseTokenProperty *height = [[self alloc] initWithName:@"height" type:PCTokenPropertyTypeNumber];
        size.children = @[width, height];
        tokens = @[ size ];
    }
    else if ([type isEqualToString:@"Check"]) {
        PCBrowseTokenProperty *token = [[self alloc] initWithName:name type:PCTokenPropertyTypeBOOL];
        tokens = @[ token ];
    }
    else if ([@[ @"Degrees", @"Float" ] containsObject:type]) {
        PCBrowseTokenProperty *token = [[self alloc] initWithName:name type:PCTokenPropertyTypeNumber];
        tokens = @[ token ];
    }
    else if ([type isEqualToString:@"StringSimple"]) {
        PCBrowseTokenProperty *token = [[self alloc] initWithName:name type:PCTokenPropertyTypeString];
        tokens = @[ token ];
    }
    else {
        PCLog(@"Unknown token type: %@", type);
    }

    return tokens;
}

- (instancetype)initWithName:(NSString *)name type:(PCTokenPropertyType)type {
    self = [super init];
    if (self) {
        _name = name;
        _type = type;
    }
    return self;
}

#pragma mark - PCTokenBrowsable

- (NSString *)browseDisplayName {
    return self.name;
}

- (NSArray *)browseChildren {
    return self.children;
}

- (BOOL)isSelectable {
    return YES;
}

@end
