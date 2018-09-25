//
//  PCMultiViewNode+JSExport.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-06-19.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCMultiViewNode.h"
#import "NSObject+JSDataBinding.h"

@protocol PCMultiViewNodeExport <JSExport, NSObjectJSDataBindingExport>

@property (assign, nonatomic) NSInteger focusedViewIndex;
@property (assign, nonatomic) BOOL showPageIndicator;
@property (assign, nonatomic, readonly) NSInteger nextIndex;
@property (assign, nonatomic, readonly) NSInteger previousIndex;

JSExportAs(nextView,
- (void)nextCell:(PCMultiviewTransitionType)transitionType transitionDuration:(NSNumber *)transitionDuration
);

JSExportAs(previousView,
- (void)previousCell:(PCMultiviewTransitionType)transitionType transitionDuration:(NSNumber *)transitionDuration
);

JSExportAs(goToView,
- (void)goToCell:(NSInteger)cellIndex transitionType:(PCMultiviewTransitionType)transitionType transitionDuration:(NSNumber *)transitionDuration
);

@end

@interface PCMultiViewNode (JSExport) <PCMultiViewNodeExport>

@end
