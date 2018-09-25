//
//  PCPublisher.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 3/3/2014.
//
//

#import <Cocoa/Cocoa.h>
#import "PCBlockTypes.h"

@class PCProjectSettings;
@class PCWarningGroup;

@interface PCPublisher : NSObject

@property (strong, nonatomic, readonly) PCWarningGroup *warnings;

+ (BOOL)xcodeIsInstalled;
+ (NSString *)xcodeVersion;

- (instancetype)initWithProjectSettings:(PCProjectSettings *)projectSettings warnings:(PCWarningGroup *)warnings;

- (void)publish:(void (^)(BOOL))completion statusBlock:(PCStatusBlock)statusBlock;
- (void)publishToURL:(NSURL *)url completion:(void (^)(BOOL))completion statusBlock:(PCStatusBlock)statusBlock;
- (void)run;
- (void)publishToXcode:(void (^)())completion;

@end

@interface PCPublisher (Testable)

- (NSString *)validBundleIDPartForForPencilCaseProjectName:(NSString *)pencilCaseName;
- (NSString *)validFilenameForPencilCaseProjectName:(NSString *)pencilCaseName;

@end
