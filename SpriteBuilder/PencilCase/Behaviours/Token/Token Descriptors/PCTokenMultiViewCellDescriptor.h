//
//  PCTokenMultiViewCellDescriptor.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-12-05.
//
//

#import "MTLModel.h"
#import "PCTokenDescriptor.h"
#import "Constants.h"
#import "PCJavaScriptRepresentable.h"

typedef NS_ENUM(NSInteger, PCMVCellChangeType) {
    PCMVCellChangeTypeNextCell,
    PCMVCellChangeTypePreviousCell,
};

@interface PCTokenMultiViewCellDescriptor : MTLModel <PCTokenDescriptor, PCJavaScriptRepresentable>

+ (instancetype)descriptorForMultiViewToken:(PCToken *)token viewIndex:(NSInteger)index;
+ (instancetype)descriptorForMultiViewToken:(PCToken *)token changeType:(PCMVCellChangeType)changeType;
+ (NSArray *)allChangeTypeDescriptorsForMulitViewToken:(PCToken *)token;

@end
