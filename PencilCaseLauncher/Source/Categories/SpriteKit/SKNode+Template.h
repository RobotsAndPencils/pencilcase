//
//  SKNode+Template.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-29.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import SpriteKit;
@import JavaScriptCore;

@protocol SKNodeTemplateExport <JSExport>
JSExportAs(createFromTemplateNamed,
+ (instancetype)createFromTemplateNamed:(NSString *)name className:(NSString *)className
);
@end

@interface SKNode (Template) <SKNodeTemplateExport>

+ (instancetype)createFromTemplateNamed:(NSString *)name className:(NSString *)className;
+ (instancetype)createFromTemplate:(NSDictionary *)template className:(NSString *)className;
- (void)applyTemplateNamed:(NSString *)name;
- (void)applyTemplate:(NSDictionary *)template;

@end
