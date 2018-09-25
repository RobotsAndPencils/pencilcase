//
// Created by Brandon Evans on 15-05-15.
// Copyright (c) 2015 Robots & Pencils. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import <PencilCaseLauncher/PCTableCellInfo.h>

@protocol PCTableCellInfoExport <JSExport>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

JSExportAs(simpleCellInfo,
+ (instancetype)cellInfoWithTitle:(NSString *)title accessoryType:(UITableViewCellAccessoryType)accessoryType
);
JSExportAs(detailCellInfo,
+ (instancetype)cellInfoWithTitle:(NSString *)title detail:(NSString *)detail accessoryType:(UITableViewCellAccessoryType)accessoryType
);
JSExportAs(imageCellInfo,
+ (instancetype)cellInfoWithTitle:(NSString *)title imagePath:(NSString *)imagePath accessoryType:(UITableViewCellAccessoryType)accessoryType
);

@end

@interface PCTableCellInfo (JSExport) <PCTableCellInfoExport>

@end