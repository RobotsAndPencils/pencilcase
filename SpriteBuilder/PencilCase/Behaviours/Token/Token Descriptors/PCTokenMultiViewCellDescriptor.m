//
//  PCTokenMultiViewCellDescriptor.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-12-05.
//
//

#import "PCTokenMultiViewCellDescriptor.h"
#import <Mantle/MTLModel+NSCoding.h>
#import "PCTokenAttachment.h"

@interface PCTokenMultiViewCellDescriptor ()

@property (weak, nonatomic) PCToken *multiViewToken;
@property (assign, nonatomic) NSInteger index;
@property (assign, nonatomic) PCMVCellChangeType changeType;

@end

@implementation PCTokenMultiViewCellDescriptor

@synthesize token = _token;

+ (instancetype)descriptorForMultiViewToken:(PCToken *)token viewIndex:(NSInteger)index {
    PCTokenMultiViewCellDescriptor *descriptor = [[PCTokenMultiViewCellDescriptor alloc] init];
    descriptor.multiViewToken = token;
    descriptor.index = index;
    descriptor.changeType = -1;
    return descriptor;
}

+ (instancetype)descriptorForMultiViewToken:(PCToken *)token changeType:(PCMVCellChangeType)changeType {
    PCTokenMultiViewCellDescriptor *descriptor = [[PCTokenMultiViewCellDescriptor alloc] init];
    descriptor.multiViewToken = token;
    descriptor.index = -1;
    descriptor.changeType = changeType;
    return descriptor;
}

+ (NSArray *)allChangeTypeDescriptorsForMulitViewToken:(PCToken *)token {
    NSArray *types = @[
                       @(PCMVCellChangeTypeNextCell),
                       @(PCMVCellChangeTypePreviousCell)
                       ];
    return Underscore.array(types).map(^id(NSNumber *type){
        return [self descriptorForMultiViewToken:token changeType:[type integerValue]];
    }).unwrap;
}

#pragma mark - PCTokenDescriptor

- (NSString *)displayName {
    if (self.index >= 0) {
        return [NSString stringWithFormat:@"View %@", @(self.index + 1)];
    }
    return [self displayStringForChangeType:self.changeType];
}

- (PCTokenType)tokenType {
    return PCTokenTypeValue;
}

- (BOOL)isReferenceType {
    return self.index > 0;
}

- (PCTokenEvaluationType)evaluationType {
    return PCTokenEvaluationTypeNumber;
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

#pragma mark - Private

- (NSString *)displayStringForChangeType:(PCMVCellChangeType)changeType {
    switch (changeType) {
        case PCMVCellChangeTypeNextCell: return @"NextView";
        case PCMVCellChangeTypePreviousCell: return @"PreviousView";
        default: return @"";
    }
}

#pragma mark - JavaScriptRepresentable

- (NSString *)javaScriptRepresentation {
    if (self.index >= 0) {
        return [@(self.index) stringValue];
    }
    else {
        NSString *method = self.changeType == PCMVCellChangeTypeNextCell ? @"nextIndex" : @"previousIndex";
        return [NSString stringWithFormat:@"%@.%@", self.multiViewToken.javaScriptRepresentation, method];
    }
}

@end
