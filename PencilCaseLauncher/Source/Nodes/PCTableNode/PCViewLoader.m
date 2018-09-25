//
//  PCViewLoader.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-05-27.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCViewLoader.h"
#import "CCFileUtils.h"
#import "PCResourceManager.h"

@interface PCViewLoader ()

@property (strong, nonatomic) NSMutableDictionary *viewsByIDMapping;

@end

@implementation PCViewLoader

- (instancetype)initWithDictionary:(NSDictionary *)info rootView:(UIView *)view additonalViewMappings:(NSDictionary *)mappings {
    self = [super init];
    if (self) {
        [self setupWithDictionary:info rootView:view additonalViewMappings:mappings];
    }
    return self;
}

#pragma mark - Public

+ (instancetype)loadViewDictionary:(NSDictionary *)info intoRootView:(UIView *)view additonalViewMappings:(NSDictionary *)mappings {
    return [[self alloc] initWithDictionary:info rootView:view additonalViewMappings:mappings];
}

- (void)loadValues:(NSDictionary *)valuesData {
    [self enumerateValuesDictionary:valuesData withBlock:^(UIView *view, NSString *key, id value) {
        if (view && key && value) {
            [view setValue:value forKey:key];
        }
    }];
}

#pragma mark - Private

- (void)setupWithDictionary:(NSDictionary *)info rootView:(UIView *)view additonalViewMappings:(NSDictionary *)mappings {
    self.viewsByIDMapping = [NSMutableDictionary dictionary];
    [self.viewsByIDMapping addEntriesFromDictionary:mappings];
    [self loadProperties:info intoView:view];
}

- (UIView *)viewForDictionary:(NSDictionary *)dictionary {
    UIView *view = [PCViewLoader createViewOfType:dictionary[@"type"]];
    if (!view) return nil;
    [self loadProperties:dictionary intoView:view];
    return view;
}

- (void)loadProperties:(NSDictionary *)info intoView:(UIView *)view {
    if (!view) return;
    self.viewsByIDMapping[info[@"id"]] = view;
    view.autoresizingMask = [PCViewLoader autoresizingMaskFromDictionary:info[@"autoResizing"]];
    for (NSDictionary *propertyInfo in info[@"properties"]) {
        id value = [PCViewLoader propertyValueOfType:propertyInfo[@"type"] fromValueData:propertyInfo[@"value"]];
        if (!value) continue;
        [view setValue:value forKey:propertyInfo[@"key"]];
    }
    for (NSDictionary *viewInfo in info[@"subviews"]) {
        UIView *subview = [self viewForDictionary:viewInfo];
        if (!subview) continue;
        [view addSubview:subview];
    }
}

- (void)enumerateValuesDictionary:(NSDictionary *)valuesData withBlock:(void(^)(UIView *view, NSString *key, id value))block {
    [valuesData enumerateKeysAndObjectsUsingBlock:^(NSString *viewID, NSDictionary *keys, BOOL *stop) {
        UIView *view = self.viewsByIDMapping[viewID];
        [keys enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *valueData, BOOL *stop) {
            id value = [PCViewLoader propertyValueOfType:valueData[@"type"] fromValueData:valueData[@"value"]];
            block(view, key, value);
        }];
    }];
}

#pragma mark (De)Serialization

+ (UIViewAutoresizing)autoresizingMaskFromDictionary:(NSDictionary *)info {
    if (!info || ![info isKindOfClass:[NSDictionary class]]) return 0;
    UIViewAutoresizing flexWidth = [info[@"flexWidth"] boolValue] ? UIViewAutoresizingFlexibleWidth : 0;
    UIViewAutoresizing flexHeight = [info[@"flexHeight"] boolValue] ? UIViewAutoresizingFlexibleHeight : 0;
    UIViewAutoresizing flexTopMargin = [info[@"flexTopMargin"] boolValue] ? UIViewAutoresizingFlexibleTopMargin : 0;
    UIViewAutoresizing flexBottomMargin = [info[@"flexBottomMargin"] boolValue] ? UIViewAutoresizingFlexibleBottomMargin : 0;
    UIViewAutoresizing flexLeftMargin = [info[@"flexLeftMargin"] boolValue] ? UIViewAutoresizingFlexibleLeftMargin : 0;
    UIViewAutoresizing flexRightMargin = [info[@"flexRightMargin"] boolValue] ? UIViewAutoresizingFlexibleRightMargin : 0;
    return flexWidth|flexHeight|flexTopMargin|flexBottomMargin|flexLeftMargin|flexRightMargin;
}

+ (UIView *)createViewOfType:(NSString *)type {
    if ([type isEqualToString:@"label"]) {
        return [[UILabel alloc] init];
    }
    if ([type isEqualToString:@"view"]) {
        return [[UIView alloc] init];
    }
    if ([type isEqualToString:@"image"]) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds = YES;
        return imageView;
    }
    return nil;
}

+ (id)propertyValueOfType:(NSString *)type fromValueData:(id)value {
    if ([type isEqualToString:@"string"]) {
        return value;
    }
    if ([type isEqualToString:@"number"]) {
        return value;
    }
    if ([type isEqualToString:@"dictionary"]) {
        return value;
    }
    if ([type isEqualToString:@"rect"]) {
        return [NSValue valueWithCGRect:CGRectFromString(value)];
    }
    if ([type isEqualToString:@"color"]) {
        return [self colorFromArray:value];
    }
    if ([type isEqualToString:@"font"]) {
        if ([value isKindOfClass:[NSString class]]) {
            return [UIFont fontWithName:value size:17];
        }
        if ([value isKindOfClass:[NSDictionary class]]
            && value[@"fontName"] && value[@"fontSize"]) {
            return [UIFont fontWithName:value[@"fontName"] size:[value[@"fontSize"] integerValue]];
        }
    }
    if ([type isEqualToString:@"relativeImagePath"]) {
        if ([value length] == 0) return nil;
        NSString *fullPath = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:[PCResourceManager sharedInstance].resources[value] ? : value];
        if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath]) return nil;
        return [UIImage imageWithContentsOfFile:fullPath];
    }
    return nil;
}

+ (UIColor *)colorFromArray:(NSArray *)values {
    if (![values isKindOfClass:[NSArray class]]) return [UIColor whiteColor];
    if ([values count] != 4) return [UIColor whiteColor];
    return [UIColor colorWithRed:[values[0] floatValue] green:[values[1] floatValue] blue:[values[2] floatValue] alpha:[values[3] floatValue]];
}

@end
