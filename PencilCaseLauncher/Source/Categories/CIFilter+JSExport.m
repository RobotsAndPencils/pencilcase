//
//  CIFilter+JSExport.m
//  Pods
//
//  Created by Cody Rayment on 2015-03-01.
//
//

#import "CIFilter+JSExport.h"

@implementation CIFilter (JSExport)

// Listed here: https://developer.apple.com/library/mac/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html

+ (instancetype)filterWithName:(NSString *)name paramaters:(NSDictionary *)paramaters {
    if (![[self allNames] containsObject:name]) {
        return nil;
    }
    return [CIFilter filterWithName:name withInputParameters:paramaters];
}

+ (NSArray *)allNames {
    return [CIFilter filterNamesInCategory:nil];
}

@end
