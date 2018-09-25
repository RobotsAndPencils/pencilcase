//
//  PCBOOLExpressionInspector.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-12-07.
//
//

#import <Cocoa/Cocoa.h>
#import "PCExpressionInspector.h"

@interface PCBOOLExpressionInspector : NSViewController <PCExpressionInspector>

@property (assign, nonatomic) BOOL value;
@property (copy, nonatomic) NSString *name;

@end
