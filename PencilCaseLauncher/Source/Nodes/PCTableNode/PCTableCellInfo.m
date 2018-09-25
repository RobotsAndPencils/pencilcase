//
//  PCTableCellInfo.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-05-08.
//
//

#import "PCTableCellInfo.h"
#import "PCAppViewController.h"
#import "PCApp.h"
#import <RXCollections/RXCollection.h>
#import "PCViewLoader.h"
#import "PCTableViewCell.h"

@interface PCTableCellInfo ()

@property (strong, nonatomic) NSString *cellTypeName;
@property (strong, nonatomic) NSMutableDictionary *values;
@property (strong, nonatomic) NSString *uuid;

@end


@implementation PCTableCellInfo

- (instancetype)init {
    self = [super init];
    if (self) {
        _values = [NSMutableDictionary dictionary];
        _uuid = [[NSUUID UUID] UUIDString];
    }
    return self;
}

#pragma mark - Public

- (CGRect)baseFrame {
    return CGRectFromString([self infoDictionary][@"baseFrame"]);
}

- (CGFloat)height {
    return CGRectGetHeight([self baseFrame]);
}

- (NSString *)reuseIdentifier {
    return [self infoDictionary][@"name"];
}

- (id)createViewsForTableCell:(PCTableViewCell *)cell {
    CGRect baseFrame = [self baseFrame];
    cell.frame = baseFrame;
    cell.contentView.frame = baseFrame;
    return [PCViewLoader loadViewDictionary:[self infoDictionary][@"contentView"] intoRootView:cell.contentView additonalViewMappings:@{ @"cell": cell }];
}

- (void)loadValuesUsingViewMapping:(id)object {
    if (![object isKindOfClass:[PCViewLoader class]]) return;
    PCViewLoader *viewLoader = object;
    [viewLoader loadValues:[self values]];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [self init];
    if (!self) {
        return nil;
    }

    _cellTypeName = dictionary[@"cellTypeName"] ?: @"";
    _values = dictionary[@"values"] ?: [NSMutableDictionary dictionary];
    _uuid = [[NSUUID UUID] UUIDString];

    return self;
}

+ (instancetype)cellInfoWithTitle:(NSString *)title accessoryType:(UITableViewCellAccessoryType)accessoryType {
    if (accessoryType < UITableViewCellAccessoryNone || accessoryType > UITableViewCellAccessoryDetailButton) {
        accessoryType = UITableViewCellAccessoryNone;
    }

    PCTableCellInfo *info = [PCTableCellInfo cellInfoWithName:@"Simple Cell" values:@{
        @"label" : @{
            @"text" : @{
                @"type" : @"string",
                @"value" : title ?: @""
            }
        },
        @"cell" : @{
            @"accessoryType" : @{
                @"type" : @"number",
                @"value" : @(accessoryType)
            },
            @"backgroundColor" : @{
                @"type" : @"color",
                @"value" : [PCViewLoader propertyValueOfType:@"color" fromValueData:[UIColor whiteColor]]
            }
        }
    }];
    return info;
}

+ (instancetype)cellInfoWithTitle:(NSString *)title detail:(NSString *)detail accessoryType:(UITableViewCellAccessoryType)accessoryType {
    if (accessoryType < UITableViewCellAccessoryNone || accessoryType > UITableViewCellAccessoryDetailButton) {
        accessoryType = UITableViewCellAccessoryNone;
    }

    PCTableCellInfo *info = [PCTableCellInfo cellInfoWithName:@"Detail Cell" values:@{
        @"label" : @{
            @"text" : @{
                @"type" : @"string",
                @"value" : title ?: @""
            }
        },
        @"detailLabel" : @{
            @"text" : @{
                @"type" : @"string",
                @"value" : detail ?: @""
            }
        },
        @"cell" : @{
            @"accessoryType" : @{
                @"type" : @"number",
                @"value" : @(accessoryType)
            },
            @"backgroundColor" : @{
                @"type" : @"color",
                @"value" : [PCViewLoader propertyValueOfType:@"color" fromValueData:[UIColor whiteColor]]
            }
        }
    }];
    return info;
}

+ (instancetype)cellInfoWithTitle:(NSString *)title imagePath:(NSString *)imagePath accessoryType:(UITableViewCellAccessoryType)accessoryType {
    if (accessoryType < UITableViewCellAccessoryNone || accessoryType > UITableViewCellAccessoryDetailButton) {
        accessoryType = UITableViewCellAccessoryNone;
    }

    PCTableCellInfo *info = [PCTableCellInfo cellInfoWithName:@"Image Cell" values:@{
        @"label" : @{
            @"text" : @{
                @"type" : @"string",
                @"value" : title ?: @""
            }
        },
        @"image": @{
            @"image": @{
                @"type": @"relativeImagePath",
                @"value": imagePath ?: @""
            }
        },
        @"cell" : @{
            @"accessoryType" : @{
                @"type" : @"number",
                @"value" : @(accessoryType)
            },
            @"backgroundColor" : @{
                @"type" : @"color",
                @"value" : [PCViewLoader propertyValueOfType:@"color" fromValueData:[UIColor whiteColor]]
            }
        }
    }];
    return info;
}

+ (instancetype)cellInfoWithName:(NSString *)name values:(NSDictionary *)values {
    PCTableCellInfo *info = [[PCTableCellInfo alloc] init];
    info.cellTypeName = name;
    info.values = [values mutableCopy];
    return info;
}

#pragma mark - Private

+ (NSDictionary *)infoDictionaryForName:(NSString *)name {
    return [[PCAppViewController lastCreatedInstance].runningApp.tableCellTypes rx_detectWithBlock:^BOOL(NSDictionary *info) {
        return [info[@"name"] isEqualToString:name];
    }];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.values forKey:@"values"];
    [coder encodeObject:self.cellTypeName forKey:@"cellTypeName"];
    [coder encodeObject:self.uuid forKey:@"uuid"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [self init];
    if (self) {
        _values = [coder decodeObjectForKey:@"values"] ?: [NSMutableDictionary dictionary];
        _cellTypeName = [coder decodeObjectForKey:@"cellTypeName"];
        _uuid = [coder decodeObjectForKey:@"uuid"] ?: _uuid;
    }
    return self;
}

#pragma mark - Properties

- (NSDictionary *)infoDictionary {
    return [[self class] infoDictionaryForName:self.cellTypeName];
}

@end
