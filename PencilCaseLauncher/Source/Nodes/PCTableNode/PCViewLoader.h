//
//  PCViewLoader.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-05-27.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCViewLoader : NSObject

+ (instancetype)loadViewDictionary:(NSDictionary *)info intoRootView:(UIView *)view additonalViewMappings:(NSDictionary *)mappings;
+ (id)propertyValueOfType:(NSString *)type fromValueData:(id)value;
- (void)loadValues:(NSDictionary *)valuesData;

@end
