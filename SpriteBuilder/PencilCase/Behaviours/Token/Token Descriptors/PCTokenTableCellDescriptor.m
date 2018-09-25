//
//  PCTokenTableCellDescriptor.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-12-06.
//
//

#import "PCTokenTableCellDescriptor.h"
#import <Mantle/MTLModel+NSCoding.h>
#import "PCTokenAttachment.h"
#import "PCBehavioursDataSource.h"

@interface PCTokenTableCellDescriptor ()

@property (weak, nonatomic) PCToken *tableViewToken;
@property (copy, nonatomic) NSUUID *cellUUID;

@end

@implementation PCTokenTableCellDescriptor

@synthesize token = _token;

+ (instancetype)descriptorForTableViewToken:(PCToken *)token cellUUID:(NSUUID *)cellUUID {
    PCTokenTableCellDescriptor *descriptor = [[PCTokenTableCellDescriptor alloc] init];
    descriptor.tableViewToken = token;
    descriptor.cellUUID = cellUUID;
    return descriptor;
}

#pragma mark - PCTokenDescriptor

- (NSString *)displayName {
    return [PCBehavioursDataSource displayNameForTableViewToken:self.tableViewToken cellUUID:self.cellUUID];
}

- (PCTokenType)tokenType {
    return PCTokenTypeValue;
}

- (BOOL)isReferenceType {
    return YES;
}

- (PCTokenEvaluationType)evaluationType {
    return PCTokenEvaluationTypeTableCell;
}

- (NSAttributedString *)attributedDisplayName {
    return [PCTokenAttachment attachmentForToken:self.token];
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

- (NSString *)javaScriptRepresentation {
    return [NSString stringWithFormat:@"'%@'", [self.cellUUID UUIDString]];
}

@end
