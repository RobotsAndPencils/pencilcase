/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "PCWarningGroup.h"

@interface PCWarningGroup()

@property (strong, nonatomic) NSMutableDictionary* warningsFiles;

@end

@implementation PCWarningGroup

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
	_warnings = [NSMutableArray array];
    _warningsFiles = [NSMutableDictionary dictionary];
    _warningsDescription = @"Warnings";
    
    return self;
}

- (void)addWarningWithDescription:(NSString*)description {
    [self addWarningWithDescription:description isFatal:NO relatedFile:nil resolution:nil];
}

- (void)addWarningWithDescription:(NSString *)description isFatal:(BOOL)fatal {
    [self addWarningWithDescription:description isFatal:fatal relatedFile:nil];
}

- (void) addWarningWithDescription:(NSString *)description isFatal:(BOOL)fatal relatedFile:(NSString *)relatedFile {
    [self addWarningWithDescription:description isFatal:fatal relatedFile:relatedFile resolution:nil];
}

- (void) addWarningWithDescription:(NSString *)description isFatal:(BOOL)fatal relatedFile:(NSString *)relatedFile resolution:(NSString *)resolution {
    PCWarning* warning = [[PCWarning alloc] init];
    warning.message = description;
    warning.relatedFile = relatedFile;
    warning.fatal = fatal;
    warning.resolution = resolution;
    [self addWarning:warning];
}

- (void)addWarning:(PCWarning *)warning {
    warning.targetType = self.currentTargetType;
    
    [self.warnings addObject:warning];
    NSLog(@"WARNING: %@", warning.description);
    
    if (warning.relatedFile) {
        // Get warnings for the file
        NSMutableArray *warnings = self.warningsFiles[warning.relatedFile];
        if (!warnings) {
            warnings = [NSMutableArray array];
            self.warningsFiles[warning.relatedFile] = warnings;
        }
        
        [warnings addObject:warning];
    }
    [self.delegate warningsUpdated:self];
}

- (NSArray *)warningsForRelatedFile:(NSString *)relatedFile {
    return self.warningsFiles[relatedFile];
}

@end
