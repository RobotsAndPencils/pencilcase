//
//  PCPopUpExpressionInspector.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-24.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCExpressionInspector.h"

@interface PCPopUpExpressionInspector : NSViewController <PCExpressionInspector>

@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) id selectedItem;
@property (copy, nonatomic) NSAttributedString *(^displayStringForItemHandler)(id item);
@property (copy, nonatomic) void(^highlightItemHandler)(id item, BOOL highlighted);

@end
