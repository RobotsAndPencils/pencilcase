//
//  NSUUID+JSExport.h
//  PCPlayer
//
//  Created by Brandon on 2014-03-13.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;

@protocol NSUUIDExport <JSExport>

+ (NSString *)uuid;

@end

@interface NSUUID (JSExport) <NSUUIDExport>

+ (NSString *)uuid;

@end
