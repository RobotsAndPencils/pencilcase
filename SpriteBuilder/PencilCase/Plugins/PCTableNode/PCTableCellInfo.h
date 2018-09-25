//
//  PCTableCellInfo.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-05-08.
//
//

#import <Foundation/Foundation.h>

@interface PCTableCellInfo : NSObject <NSCoding>

@property (strong, nonatomic, readonly) NSDictionary *infoDictionary;
@property (strong, nonatomic, readonly) NSString *uuid;

- (instancetype)initWithCellTypeName:(NSString *)cellTypeName;

- (void)enumerateInspectorInfoDictionariesWithBlock:(void(^)(NSString *inspectorTitle, NSString *inspectorType, NSArray *inspectorValueInfos))block;
- (id)valueForInspectorValueInfo:(NSDictionary *)valueInfo;
- (void)setValue:(id)value forInspectorValueInfo:(NSDictionary *)valueInfo;

+ (NSArray *)cellTypeDictionaries;

- (NSString *)title;
- (BOOL)hasInfoButton;

@end
