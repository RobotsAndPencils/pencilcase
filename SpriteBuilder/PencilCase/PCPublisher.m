//
//  PCPublisher.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 3/3/2014.
//
//

#import "PCPublisher.h"
#import "PCWarningGroup.h"
#import "PCProjectSettings.h"
#import "CCBPublisher.h"
#import "AppDelegate.h"
#import "NSString+CamelCase.h"
#import <AFNetworking/AFNetworking.h>
#import "NSFileManager+PCHelpers.h"
#import "NSError+PencilCaseErrors.h"
#import <Underscore.m/Underscore.h>
#import <Underscore.m/Underscore+Functional.h>
#import "NSImage+PNGRepresentation.h"

static NSString *const PCRequiredXcodeBundleId = @"com.apple.dt.Xcode";

static NSString *const PCSupportedInterfaceOrientationsIphoneInfoKey = @"UISupportedInterfaceOrientations";
static NSString *const PCSupportedInterfaceOrientationsIpadInfoKey = @"UISupportedInterfaceOrientations~ipad";

static NSString *const PCSuppressSimulatorAlert = @"PCSuppressSimulatorAlert";

@interface PCPublisher () <CCBPublisherDelegate>

@property (strong, nonatomic) PCProjectSettings *projectSettings;
@property (strong, nonatomic) PCWarningGroup *warnings;
@property (strong, nonatomic) CCBPublisher *ccbPublisher;
@property (copy, nonatomic) void(^publishHandler)(BOOL success);

@end

@implementation PCPublisher

#pragma mark - Public

- (instancetype)initWithProjectSettings:(PCProjectSettings *)projectSettings warnings:(PCWarningGroup *)warnings {
    self = [super init];
    if (self) {
        _projectSettings = projectSettings;
        _warnings = warnings;
    }
    return self;
}

- (void)publish:(void (^)(BOOL))completion statusBlock:(PCStatusBlock)statusBlock {
    self.ccbPublisher = [[CCBPublisher alloc] initWithProjectSettings:self.projectSettings warnings:self.warnings];
    self.ccbPublisher.delegate = self;
    self.publishHandler = completion;
    [self.ccbPublisher publish:statusBlock];
}

- (void)publishToURL:(NSURL *)url completion:(void (^)(BOOL))completion statusBlock:(PCStatusBlock)statusBlock {
    [self publish:^(BOOL success) {
        if (success && url) {
            [self.ccbPublisher copyPublishDirectoryToURL:url];
        }
        if (completion) completion(success);
    } statusBlock:statusBlock];
}

+ (BOOL)xcodeIsInstalled {
    NSString *xcodeBundleId = PCRequiredXcodeBundleId;
    OSStatus result = LSFindApplicationForInfo(kLSUnknownCreator, (__bridge CFStringRef)(xcodeBundleId), NULL, NULL, NULL);
    return (result != kLSApplicationNotFoundErr);
}

+ (NSString *)xcodeVersion {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    task.arguments = @[ @"-c", @"xcodebuild -version | head -1 | awk '{print $2}'" ];
    task.standardOutput = [NSPipe pipe];

    [task launch];
    [task waitUntilExit];

    NSFileHandle *outHandle = [[task standardOutput] fileHandleForReading];
    NSData *data = [outHandle readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSLog(@"xcodebuild task finished with status: %@ stdout: %@", @([task terminationStatus]), outputString);
    return [outputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)run {
    // unfocus any nodes that are currently in focus
    [[AppDelegate appDelegate] menuDeselect:nil];
    NSAssert(self.ccbPublisher, @"publish first");
    [self launchSimulator];
}

- (void)publishToXcode:(void (^)())completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        NSString *bundleID = [NSString stringWithFormat:@"com.example.%@", [self validBundleIDPartForForPencilCaseProjectName:self.projectSettings.appName]];
        PCDeviceTargetType deviceTarget = self.projectSettings.deviceResolutionSettings.deviceTarget;
        PCDeviceTargetOrientation deviceOrientation = self.projectSettings.deviceResolutionSettings.deviceOrientation;

        [self exportProjectToPath:self.projectSettings.xcodeProjectExportPath projectName:self.projectSettings.appName bundleID:bundleID deviceTarget:deviceTarget deviceOrientation:deviceOrientation];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion();
        });
    });
}

// Attempts to match what Xcode does on new project creation dialog: http://cl.ly/image/1K2m070s3S22/Image%202015-10-21%20at%2012.21.48%20PM.png
- (NSString *)validBundleIDPartForForPencilCaseProjectName:(NSString *)pencilCaseName {
    if (pencilCaseName.length == 0) return @"my-project";

    NSString *validName = pencilCaseName;
    validName = [validName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    validName = [validName pc_stringByReplacingCharactersInSet:[[self validBundleIDCharacterSet] invertedSet] withString:@"-"];
    if (![[self validBundleIDFirstCharacterSet] characterIsMember:[validName characterAtIndex:0]]) {
        validName = [validName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"-"];
    }
    return validName;
}

- (NSString *)validFilenameForPencilCaseProjectName:(NSString *)pencilCaseName {
    return [pencilCaseName pc_stringByReplacingCharactersInSet:[self invalidFilenameCharacterSet] withString:@"-"];
}

- (NSCharacterSet *)validBundleIDCharacterSet {
    NSMutableCharacterSet *set = [NSMutableCharacterSet lowercaseLetterCharacterSet];
    [set formUnionWithCharacterSet:[NSCharacterSet uppercaseLetterCharacterSet]];
    [set formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
    return [set copy];
}

- (NSCharacterSet *)validBundleIDFirstCharacterSet {
    NSMutableCharacterSet *set = [NSMutableCharacterSet lowercaseLetterCharacterSet];
    [set formUnionWithCharacterSet:[NSCharacterSet uppercaseLetterCharacterSet]];
    return [set copy];
}

- (NSCharacterSet *)invalidFilenameCharacterSet {
    return [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*&|\"<>"];
}

#pragma mark - Private

- (NSString *)pathWithComponents:(NSArray *)componenets {
    NSString *path = @"";
    for (NSString *component in componenets) {
        path = [path stringByAppendingPathComponent:component];
    }
    return path;
}

- (NSString *)targetDeviceName {
    switch (self.projectSettings.deviceResolutionSettings.deviceTarget) {
        case PCDeviceTargetTypePhone:
            return @"iPhone 8 Plus";
            break;
        case PCDeviceTargetTypeTablet:
        default:
            return @"iPad (6th generation)";
            break;
    }
}

- (void)launchSimulator {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:PCSuppressSimulatorAlert]) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"The simulator can sometimes be a bit slow.";
        alert.informativeText = @"To see how your Creation will look and function on your device, test it out by exporting to Xcode and running on a real device.";
        alert.showsSuppressionButton = YES;
        [alert runModal];
        if (alert.suppressionButton.state == NSOnState) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PCSuppressSimulatorAlert];
        }
    }

    NSString *appPath = [[NSBundle mainBundle] pathForResource:@"EmbeddedPlayer" ofType:@"app" inDirectory:@"EmbeddedPlayer"];
    NSString *simPath = [[NSBundle mainBundle] pathForResource:@"run-in-sim" ofType:nil];
    NSTask *iosSimTask = [[NSTask alloc] init];
    iosSimTask.launchPath = simPath;
    NSMutableArray *arguments = [@[ [self targetDeviceName],
                                    @"com.robotsandpencils.PencilCaseEmbeddedPlayer",
                                    appPath,
                                    self.projectSettings.publishDirectory
                                    ] mutableCopy];

    NSInteger currentSlideIndex = [[AppDelegate appDelegate] currentSlideIndex];
    if (currentSlideIndex > 0) {
        [arguments addObjectsFromArray:@[[@(currentSlideIndex) stringValue]]];
    }
    
    iosSimTask.arguments = arguments;
    [iosSimTask launch];
}

- (void)exportProjectToPath:(NSString *)selectedPath projectName:(NSString *)destinationProjectName bundleID:(NSString *)destinationBundleID deviceTarget:(PCDeviceTargetType)deviceTarget deviceOrientation:(PCDeviceTargetOrientation)deviceOrientation {
    // We run into many issues if an invalid filename makes it into projects settings.
    destinationProjectName = [self validFilenameForPencilCaseProjectName:destinationProjectName];

    // always generate the project within a folder named after the project
    NSString *destinationPath = [selectedPath stringByAppendingPathComponent:destinationProjectName];

    NSString *srcProjectPath = [[NSBundle mainBundle] pathForResource:@"ExportProjectTemplate" ofType:nil];
    NSString *srcProjectName = @"Project Template";
    NSString *srcProjectWrapperPath = [NSString stringWithFormat:@"%@/%@.xcodeproj", destinationPath, srcProjectName];
    NSString *dstProjectWrapperPath = [NSString stringWithFormat:@"%@/%@.xcodeproj", destinationPath, destinationProjectName];

    // Remove existing output path
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dstProjectWrapperPath]) {
        // Create output directory structure and copy the project template

        [fileManager removeItemAtPath:destinationPath error:&error];

        if (![fileManager copyItemAtPath:srcProjectPath toPath:destinationPath error:&error]) {
            PCLog(@"Failed to copy template project from '%@' to '%@': %@", srcProjectPath, destinationPath, error);
            [self.warnings addWarningWithDescription:@"Failed to export Xcode project" isFatal:YES relatedFile:destinationPath];
            return;
        }

        // Rename project file
        if (![fileManager moveItemAtPath:srcProjectWrapperPath toPath:dstProjectWrapperPath error:&error]) {
            PCLog(@"Failed to rename project from '%@' to '%@': %@", srcProjectWrapperPath, dstProjectWrapperPath, error);
            [self.warnings addWarningWithDescription:@"Failed to export Xcode project" isFatal:YES relatedFile:dstProjectWrapperPath];
            return;
        }

        NSString *srcSchemePath = [dstProjectWrapperPath stringByAppendingPathComponent:[NSString stringWithFormat:@"xcshareddata/xcschemes/%@.xcscheme", srcProjectName]];
        NSString *dstSchemePath = [dstProjectWrapperPath stringByAppendingPathComponent:[NSString stringWithFormat:@"xcshareddata/xcschemes/%@.xcscheme", destinationProjectName]];
        if (![fileManager moveItemAtPath:srcSchemePath toPath:dstSchemePath error:&error]) {
            PCLog(@"Failed to rename scheme from '%@' to '%@': %@", srcSchemePath, dstSchemePath, error);
            [self.warnings addWarningWithDescription:@"Failed to export Xcode project" isFatal:YES relatedFile:destinationPath];
            return;
        }

        // Rename project references
        NSString *infoPlistFilePath = [destinationPath stringByAppendingPathComponent:@"Info.plist"];
        NSArray *filesToSearchAndReplace = @[
            [dstProjectWrapperPath stringByAppendingPathComponent:@"project.pbxproj"],
            [dstProjectWrapperPath stringByAppendingPathComponent:@"project.xcworkspace/contents.xcworkspacedata"],
            [destinationPath stringByAppendingPathComponent:@"main.m"],
            [destinationPath stringByAppendingPathComponent:@"AppDelegate.h"],
            [destinationPath stringByAppendingPathComponent:@"AppDelegate.m"],
            infoPlistFilePath,
            dstSchemePath,
        ];
        NSDictionary *replacements = @{
            srcProjectName :  destinationProjectName,
            @"com.example.BundleID" : destinationBundleID,

            // the project template is intentionally configured to target iPad so that it contains
            // the string "TARGETED_DEVICE_FAMILY = 2" which can easily be changed using the following
            // replacement:
            @"TARGETED_DEVICE_FAMILY = 2" : [NSString stringWithFormat:@"TARGETED_DEVICE_FAMILY = %@", @(deviceTarget == PCDeviceTargetTypePhone ? 1 : 2)],
        };

        for (NSString *path in filesToSearchAndReplace) {
            NSData *data = [fileManager contentsAtPath:path];
            NSString *contents = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            for (NSString *target in replacements) {
                NSString *replacement = replacements[target];
                contents = [contents stringByReplacingOccurrencesOfString:target withString:replacement];
            }

            data = [contents dataUsingEncoding:NSUTF8StringEncoding];
            [fileManager createFileAtPath:path contents:data attributes:nil];
        }
        
        // Update the info.plist with the correct orientation settings
        NSMutableDictionary *infoPlist = [NSMutableDictionary dictionaryWithContentsOfFile:infoPlistFilePath];
        NSArray *supportedOrientations;
        switch (deviceOrientation) {
            case PCDeviceTargetOrientationLandscape:
                supportedOrientations = @[@"UIInterfaceOrientationLandscapeLeft", @"UIInterfaceOrientationLandscapeRight"];
                if (deviceTarget == PCDeviceTargetTypePhone) {
                    // UIImagePickerController does not support landscape-only apps (will crash). This is not an issue for
                    // iPad since the picker is displayed within a popover, but iPhone needs to globally support portrait
                    // to avoid the crash then constrains to landscape in -[PCAppViewController supportedInterfaceOrientations]
                    // per the following SO answer: http://stackoverflow.com/a/19630858/516581
                    supportedOrientations = [supportedOrientations arrayByAddingObject:@"UIInterfaceOrientationPortrait"];
                }
                break;
            case PCDeviceTargetOrientationPortrait:
            default:
                supportedOrientations = @[@"UIInterfaceOrientationPortrait"];
                break;
        }

        infoPlist[PCSupportedInterfaceOrientationsIphoneInfoKey] = supportedOrientations;
        infoPlist[PCSupportedInterfaceOrientationsIpadInfoKey] = supportedOrientations;
        [infoPlist writeToFile:infoPlistFilePath atomically:YES];
    }

    // Publish into the exported project
    NSString *fileName = [@"MyProject" stringByAppendingPathExtension:PCCreationExtension];
    NSString *publishPath = [destinationPath stringByAppendingPathComponent:fileName];
    NSURL *publishURL = [NSURL fileURLWithPath:publishPath];
    [self.ccbPublisher copyPublishDirectoryToURL:publishURL];
}

#pragma mark - CCBPublisherDelegate

- (void)publisher:(CCBPublisher *)publisher finishedWithWarnings:(PCWarningGroup *)warnings success:(BOOL)success {
    if (self.publishHandler) self.publishHandler(success);
}

@end
