//
//  PCWebViewNode+JSExport.h
//  PCPlayer
//
//  Created by Brandon Evans on 2014-04-24.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCWebViewNode.h"
#import "NSObject+JSDataBinding.h"


@protocol PCWebViewNodeExport <JSExport, NSObjectJSDataBindingExport>

@property (copy, nonatomic) NSString *currentURL;
@property (copy, nonatomic) NSString *homeURL;

- (void)back:(JSValue *)completionHandler;
- (void)forward:(JSValue *)completionHandler;
- (void)refresh:(JSValue *)completionHandler;
- (void)stop:(JSValue *)completionHandler;
- (void)home:(JSValue *)completionHandler;

@end

@interface PCWebViewNode (JSExport) <PCWebViewNodeExport>

@end
