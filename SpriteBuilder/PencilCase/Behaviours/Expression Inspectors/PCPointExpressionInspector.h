//
//  PCPointExpressionInspector.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-27.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCExpressionInspector.h"

@interface PCPointExpressionInspector : NSViewController <PCExpressionInspector>

@property (assign, nonatomic) double minValue;
@property (assign, nonatomic) double maxValue;
@property (assign, nonatomic) double increment;
@property (assign, nonatomic) BOOL allowFloats;

@property (strong, nonatomic) NSNumber *firstValue;
@property (strong, nonatomic) NSNumber *secondValue;

@end
