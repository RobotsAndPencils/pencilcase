//
//  NSString+FileNameFormatting_.h
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-12-04.
//
//

#import <Foundation/Foundation.h>

@interface NSString (FileNameFormatting)

+ (NSRegularExpression *)pc_resolutionDependentStringRegex;
+ (NSString *)pc_trimFileNameResolutionDependencySuffix:(NSString *)file;

@end
