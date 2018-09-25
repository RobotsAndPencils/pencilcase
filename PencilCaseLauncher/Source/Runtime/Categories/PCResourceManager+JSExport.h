//
//  PCResourceManager+___VARIABLE_productName:identifier___.h
//  PencilCaseLauncherDemo
//
//  Created by Brandon Evans on 15-01-19.
//
//

@import JavaScriptCore;

#import "PCResourceManager.h"

@protocol PCResourceManagerExport <JSExport>

+ (instancetype)sharedInstance;

@property (strong, nonatomic) NSDictionary *resources;

@end

@interface PCResourceManager (JSExport) <PCResourceManagerExport>

@end
