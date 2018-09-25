//
//  PCTokenTableCellDescriptor.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-12-06.
//
//

#import "MTLModel.h"
#import "PCTokenDescriptor.h"
#import "Constants.h"
#import "PCJavaScriptRepresentable.h"

@interface PCTokenTableCellDescriptor : MTLModel <PCTokenDescriptor, PCJavaScriptRepresentable>

+ (instancetype)descriptorForTableViewToken:(PCToken *)token cellUUID:(NSUUID *)cellUUID;

@end
