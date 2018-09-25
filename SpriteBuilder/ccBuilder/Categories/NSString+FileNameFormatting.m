//
//  NSString+FileNameFormatting_.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-12-04.
//
//

#import "NSString+FileNameFormatting.h"

@implementation NSString (FileNameFormatting)

+ (NSRegularExpression *)pc_resolutionDependentStringRegex {
    return [NSRegularExpression regularExpressionWithPattern:@"@\\d+\\.?\\d*x" options:NSRegularExpressionCaseInsensitive error:nil];
}

+ (NSString *)pc_trimFileNameResolutionDependencySuffix:(NSString *)file {
    NSString *fileExtension = [file pathExtension];
    NSString *pathComponents = [file stringByDeletingLastPathComponent];
    NSString *fileName = [[file lastPathComponent] stringByDeletingPathExtension];
    
    fileName = [[NSString pc_resolutionDependentStringRegex] stringByReplacingMatchesInString:fileName options:0 range:NSMakeRange(0, fileName.length) withTemplate:@""];
    NSString *updatedFilePath = [[pathComponents stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:fileExtension];
    return updatedFilePath;
}

@end
