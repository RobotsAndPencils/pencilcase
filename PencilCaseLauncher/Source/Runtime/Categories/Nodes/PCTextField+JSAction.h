//
//  PCTextField+JSAction.h
//  PCPlayer
//
//  Created by Quinn Thomson on 2014-07-14.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCTextField.h"

@protocol PCTextfieldJSActionExport <JSExport>

JSExportAs(addBeginEndHandler,
- (void)addBeginEndHandlerForState:(NSNumber *)state handler:(JSValue *)handler
);

@end

@interface PCTextField (JSAction) <PCTextfieldJSActionExport>

@end
