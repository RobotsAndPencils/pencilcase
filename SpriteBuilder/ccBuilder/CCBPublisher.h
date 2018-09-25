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

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "PCBlockTypes.h"

@class PCProjectSettings;
@class PCWarningGroup;


enum {
    kCCBPublishFormatSound_ios_caf,
    kCCBPublishFormatSound_ios_mp4,
};

enum {
    kCCBPublishFormatSound_android_ogg,
};

@class CCBPublisher;

@protocol CCBPublisherDelegate <NSObject>

- (void)publisher:(CCBPublisher *)publisher finishedWithWarnings:(PCWarningGroup *)warnings success:(BOOL)success;

@end


@interface CCBPublisher : NSObject


@property (assign, nonatomic) id<CCBPublisherDelegate> delegate;



@property (strong, readonly, nonatomic) NSArray *publishForResolutions;
@property (strong, readonly, nonatomic) PCProjectSettings *projectSettings;
@property (strong, readonly, nonatomic) PCWarningGroup *warnings;
@property (assign, readonly, nonatomic) PCPublisherTargetType targetType;
@property (copy, readonly, nonatomic) NSString *publishFormat;

- (instancetype)initWithProjectSettings:(PCProjectSettings *)settings warnings:(PCWarningGroup *)w;
- (void)publish:(PCStatusBlock)statusBlock;
- (BOOL)copyPublishDirectoryToURL:(NSURL *)url;
+ (NSString *)getXcodePath;
- (void)addRenamingRuleFrom:(NSString *)src to:(NSString *)dst;

@end
