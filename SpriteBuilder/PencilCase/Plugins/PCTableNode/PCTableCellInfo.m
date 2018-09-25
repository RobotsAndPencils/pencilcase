//
//  PCTableCellInfo.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-05-08.
//
//

#import "PCTableCellInfo.h"
#import <Underscore.m/Underscore.h>
#import "PCViewLoader.h"

NSString * const PCTableCellInfoValueKey = @"value";
NSString * const PCTableCellInfoTypeKey = @"type";

@interface PCTableCellInfo ()

@property (strong, nonatomic) NSString *cellTypeName;
@property (strong, nonatomic) NSMutableDictionary *values;
@property (strong, nonatomic, readwrite) NSString *uuid;

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

- (instancetype)initWithCellTypeName:(NSString *)cellTypeName {
    self = [self init];
    if (self) {
        _cellTypeName = cellTypeName;
    }
    return self;
}

#pragma mark - Public

+ (NSArray *)cellTypeDictionaries {
    static NSMutableDictionary *cellDictionariesByFilename = nil;
    if (!cellDictionariesByFilename) {
        cellDictionariesByFilename = [NSMutableDictionary dictionary];
        
        NSString *path = [self cellTypesPlistsPath];
        NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        for (NSString *filename in content) {
            if (![[filename pathExtension] isEqualToString:@"plist"]) continue;
            
            NSString *filePath = [path stringByAppendingPathComponent:filename];
            NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
            if (!dictionary) continue;
            
            cellDictionariesByFilename[filename] = dictionary;
        }
    }
    return [cellDictionariesByFilename allValues];
}

- (void)enumerateInspectorInfoDictionariesWithBlock:(void(^)(NSString *inspectorTitle, NSString *inspectorType, NSArray *inspectorValueInfos))block {
    for (NSDictionary *inspectorInfo in [self infoDictionary][@"inspectors"]) {
        NSString *inspectorType = inspectorInfo[@"inspectorType"];
        NSArray *valueInfos = inspectorInfo[@"values"];
        NSString *title = inspectorInfo[@"title"];
        block(title, inspectorType, valueInfos);
    }
}

- (id)valueForInspectorValueInfo:(NSDictionary *)valueInfo {
    return [self valueForViewID:valueInfo[@"view"] key:valueInfo[@"key"] defaultValue:valueInfo[@"default"] valueType:valueInfo[@"type"]];
}

- (void)setValue:(id)value forInspectorValueInfo:(NSDictionary *)valueInfo {
    [self setValue:value ofType:valueInfo[@"type"] forViewID:valueInfo[@"view"] withKey:valueInfo[@"key"]];
}

- (NSString *)title {
    for (NSString *viewID in self.values) {
        for (NSString *key in self.values[viewID]) {
            NSDictionary *valueInfo = self.values[viewID][key];
            if ([valueInfo[PCTableCellInfoTypeKey] isEqualToString:@"string"]) {
                return valueInfo[PCTableCellInfoValueKey];
            }
        }
    }
    return @"";
}

- (BOOL)hasInfoButton {
    NSInteger accessoryType = [self accessoryType];
    return accessoryType == 4 || accessoryType == 2;
}

#pragma mark - Private

+ (NSDictionary *)infoDictionaryForName:(NSString *)name {
    return Underscore.array([self cellTypeDictionaries]).find(^BOOL(NSDictionary *info) {
        return [info[@"name"] isEqualToString:name];
    });
}

+ (NSString *)cellTypesPlistsPath {
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Cell Types"];
}

- (void)setValue:(id)value ofType:(NSString *)type forViewID:(NSString *)viewID withKey:(NSString *)key {
    if (!value) return;
    
    value = [PCViewLoader encodeValue:value asType:type];
    if (!value) return;
    
    NSMutableDictionary *values = self.values[viewID];
    if (!values) {
        values = [NSMutableDictionary dictionary];
        self.values[viewID] = values;
    }
    values[key] = @{
                    PCTableCellInfoValueKey: value,
                    PCTableCellInfoTypeKey: type,
                    };
}

- (id)valueForViewID:(NSString *)viewID key:(NSString *)key {
    id value = self.values[viewID][key][PCTableCellInfoValueKey];
    if (!value) return nil;
    NSString *type = self.values[viewID][key][PCTableCellInfoTypeKey];
    return [PCViewLoader decodeValue:value ofType:type];
}

- (id)valueForViewID:(NSString *)viewID key:(NSString *)key defaultValue:(id)defaultValue valueType:(NSString *)type {
    id value = [self valueForViewID:viewID key:key];
    if (!value) {
        value = [PCViewLoader decodeValue:defaultValue ofType:type];
    }
    return value;
}

- (NSInteger)accessoryType {
    return [[self valueForViewID:@"cell" key:@"accessoryType"] integerValue];
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
