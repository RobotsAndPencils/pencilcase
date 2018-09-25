//
//  CIFilter+JSExport.h
//  Pods
//
//  Created by Cody Rayment on 2015-03-01.
//
//

#import <CoreImage/CoreImage.h>
@import JavaScriptCore;

@protocol CIFilterExport <JSExport>

JSExportAs(filterWithName,
+ (instancetype)filterWithName:(NSString *)name paramaters:(NSDictionary *)paramaters
);

@end

@interface CIFilter (JSExport) <CIFilterExport>

+ (instancetype)filterWithName:(NSString *)name paramaters:(NSDictionary *)paramaters;

@end
