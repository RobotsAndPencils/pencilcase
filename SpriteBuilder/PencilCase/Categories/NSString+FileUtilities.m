//
//  NSString+FileUtilities.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-02-02.
//
//

#import "NSString+FileUtilities.h"

@implementation NSString (FileUtilities)

- (BOOL)pc_isHiddenFile {
    return [self hasPrefix:@"."];
}

+ (NSArray *)pc_imageExtensions {
    return @[ @"png", @"jpg", @"jpeg" ];
}

+ (NSArray *)pc_audioExtensions {
    return @[ @"wav" ];
}

+ (NSArray *)pc_3DExtensions {
    return @[ @"dae" ];
}

+ (NSArray *)pc_cardExtensions {
    return @[ @"ccb" ];
}

- (BOOL)pc_isImageFileExtension {
    return [[NSString pc_imageExtensions] containsObject:self.lowercaseString];
}

- (BOOL)pc_isAudioFileExtension {
    return [[NSString pc_audioExtensions] containsObject:self.lowercaseString];
}

- (BOOL)pc_is3DFileExtension {
    return [[NSString pc_3DExtensions] containsObject:self.lowercaseString];
}

- (BOOL)pc_isCardFileExtension {
    return [[NSString pc_cardExtensions] containsObject:self.lowercaseString];
}

- (NSString *)pc_sdFilePath {
    NSString *originalExtension = [self pathExtension];
    NSString *fileNameWithoutExtension = [self stringByDeletingPathExtension];
    if (![fileNameWithoutExtension hasSuffix:@"@2x"]) return [self copy];

    NSString *fileNameWithoutRetinaSuffix = [fileNameWithoutExtension substringToIndex:fileNameWithoutExtension.length - 3];
    return [[NSString stringWithFormat:@"%@", fileNameWithoutRetinaSuffix] stringByAppendingPathExtension:originalExtension];
}

- (NSString *)pc_retinaFilePath {
    return [self pc_stringByInsertingSuffixBeforeExtension:@"@2x"];
}

- (NSString *)pc_doubleRetinaPath {
    return [[self pc_sdFilePath] pc_stringByInsertingSuffixBeforeExtension:@"@2x@2x"];
}

- (NSString *)pc_stringByInsertingSuffixBeforeExtension:(NSString *)suffix {
    NSString *originalExtension = [self pathExtension];
    NSString *fileNameWithoutExtension = [self stringByDeletingPathExtension];
    if ([fileNameWithoutExtension hasSuffix:suffix]) return [self copy];
    return [[NSString stringWithFormat:@"%@%@", fileNameWithoutExtension, suffix] stringByAppendingPathExtension:originalExtension];
}

@end
