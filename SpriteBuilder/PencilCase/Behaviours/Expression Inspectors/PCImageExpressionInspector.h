//
//  PCImageExpressionInspector.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-12-07.
//
//

#import <Cocoa/Cocoa.h>
#import "PCExpressionInspector.h"

@class PCResource;

@interface PCImageExpressionInspector : NSViewController <PCExpressionInspector>

@property (strong, nonatomic) PCResource *selectedResource;

@end
