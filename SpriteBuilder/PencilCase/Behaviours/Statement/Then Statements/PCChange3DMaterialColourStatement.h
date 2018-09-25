//
//  PCChange3DMaterialColourStatement.h
//  SpriteBuilder
//
//  Created by Reuben Lee on 2015-03-06.
//
//

#import "PCStatement.h"
#import "PC3DNode.h"

@interface PCChange3DMaterialColourStatement : PCStatement

+ (NSString *)nameForPC3DMaterialType:(PC3DMaterialType)type;
+ (NSArray *)allMaterialTypes;

@end
