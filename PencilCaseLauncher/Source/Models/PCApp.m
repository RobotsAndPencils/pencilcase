//
//  PCApp 
//  PCPlayer
//
//  Created by brandon on 2/13/2014.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCAppViewController.h"
#import "PCApp.h"
#import "PCCard.h"
#import "CCConfiguration.h"
#import "PCKeyValueStore.h"
#import "PCYapDatabaseBackingStore.h"
#import <RXCollections/RXCollection.h>
#import "PCConstants.h"

@interface PCApp ()

@property (copy, nonatomic) NSString *resourcesChecksum;
@property (strong, nonatomic) NSDictionary *templates;

@end

@interface PCApp ()

@property (strong, nonatomic) NSDictionary *fontNamesDictionary;

@end

@implementation PCApp

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    _cards = [NSMutableArray array];

    return self;
}

+ (instancetype)createWithURL:(NSURL *)url {
    NSURL *projectFileURL = [url URLByAppendingPathComponent:@"project.ccbproj"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[projectFileURL path]]) return nil;
    PCApp *app = [[PCApp alloc] init];
    app.deviceSettings = [[PCDeviceResolutionSettings alloc] init];
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[projectFileURL path]];
    app.name = settings[@"appName"];
    app.uuid = settings[@"uuid"];
    app.version = settings[@"appVersion"];
    app.fileName = [url lastPathComponent];
    app.resourcesChecksum = settings[@"resourcesChecksum"];
    app.url = url;
    app.tableCellTypes = settings[@"tableCellTypes"];
    app.fileFormatVersion = settings[@"fileFormatVersion"] ? : @(PCLastFileVersionWithoutFileFormatVersionKey);
    app.templates = [NSDictionary dictionaryWithContentsOfURL:[url URLByAppendingPathComponent:@"templates.plist"]];

    // Debugging settings
    app.enableDefaultREPLGesture = [settings[@"enableDefaultREPLGesture"] boolValue];
    app.showFPS = [settings[@"showFPS"] boolValue];
    app.showNodeCount = [settings[@"showNodeCount"] boolValue];
    app.showDrawCount = [settings[@"showDrawCount"] boolValue];
    app.showQuadCount = [settings[@"showQuadCount"] boolValue];
    app.showPhysicsBorders = [settings[@"showPhysicsBorders"] boolValue];
    app.showPhysicsFields = [settings[@"showPhysicsFields"] boolValue];

    [app findResourcesWithURL:url];
    NSString *basePath = app.url.path;
    NSString *slideListPath = [basePath stringByAppendingPathComponent:@"slideFileList.plist"];
    
    if ([settings objectForKey:@"defaultOrientation"]) {
        app.deviceSettings.deviceOrientation = [[settings objectForKey:@"defaultOrientation"] intValue];
    } else {
        app.deviceSettings.deviceOrientation = PCDeviceTargetOrientationLandscape;
    }
    
    if ([settings objectForKey:@"deviceTarget"]) {
        app.deviceSettings.deviceTarget = [[settings objectForKey:@"deviceTarget"] intValue];
    } else {
        app.deviceSettings.deviceTarget = PCDeviceTargetTypeTablet;
    }
    
    NSDictionary *slideListInfo = [NSDictionary dictionaryWithContentsOfFile:slideListPath];
    for (NSString *cardFilePath in slideListInfo[@"slideFiles"]) {
        [app.cards addObject:[PCCard cardWithPath:cardFilePath]];
    }

    NSString *thirdPartyInfoListPath = [basePath stringByAppendingPathComponent:@"thirdPartyInfo.plist"];
    NSDictionary *thirdPartyInfoDict = [NSDictionary dictionaryWithContentsOfFile:thirdPartyInfoListPath];
    app.iBeacons = thirdPartyInfoDict[@"iBeaconList"];
    
    // KeyPress
    NSString *keyPressedLookupPath = [basePath stringByAppendingString:@"/slideKeyPressLookup.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:keyPressedLookupPath]) {
        app.keyPressedCardLookup = [[NSDictionary dictionaryWithContentsOfFile:keyPressedLookupPath] mutableCopy];
    }
    return app;
}

+ (NSArray *)readApps {
    NSURL *appsURL = [self documentsURL];
    NSError *error = nil;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:appsURL includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    
    NSMutableArray *mutableApps = [[NSMutableArray alloc] init];
    for (NSURL *url in contents) {
        if ([[url pathExtension] isEqualToString:@"app"]) {
            PCApp *app = [PCApp createWithURL:url];
            if (app) {
                [mutableApps addObject:app];
            }
        }
    }
    
    return mutableApps;
}

+ (PCApp *)appWithUUID:(NSString *)uuid {
    PCApp *app = [[[self readApps] rx_filterWithBlock:^BOOL(PCApp *app) {
        return [app.uuid isEqualToString:uuid];
    }] firstObject];
    return app;
}

+ (NSURL *)documentsURL {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (BOOL)deleteApp:(PCApp *)app {
    NSURL *appsURL = [self documentsURL];
    NSURL *appURL = [appsURL URLByAppendingPathComponent:app.fileName];
    NSError *error;
    BOOL removed = [[NSFileManager defaultManager] removeItemAtURL:appURL error:&error];
    if (!removed) {
        NSLog(@"%@", error);
    }
    return removed;
}

+ (void)autoInstall {
    NSURL *appsURL = [self documentsURL];
    NSURL *autoInstallAppsURL = [[NSBundle mainBundle] URLForResource:@"AutoInstall" withExtension:nil];
    
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:autoInstallAppsURL includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    
    for (NSURL *url in contents) {
        if ([[url pathExtension] isEqualToString:@"app"]) {
            NSURL *installURL = [appsURL URLByAppendingPathComponent:[url lastPathComponent]];
            [[NSFileManager defaultManager] removeItemAtURL:installURL error:nil];
            [[NSFileManager defaultManager] moveItemAtURL:url toURL:installURL error:nil];
        }
    }
}

- (void)dealloc {
    [self.keyValueStore teardown];
}

- (void)setupKeyValueStore {
    if (!self.keyValueStore) {
        self.keyValueStore = [[PCKeyValueStore alloc] init];
    }
    PCYapDatabaseBackingStore *backingStore = [[PCYapDatabaseBackingStore alloc] init];
    [self.keyValueStore setupWithBackingStore:backingStore uuid:self.uuid];
    if (self.keyValueStore) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PCKeyValueStoreDidChange" object:self userInfo:@{ @"keyValueStore": self.keyValueStore }];
    }
}

- (void)tearDownKeyValueStore {
    [self.keyValueStore teardown];
}

- (void)findResourcesWithURL:(NSURL *)url {
    // Prefer the correct resolution for this device, but if it doesn't exist try the other one
    NSURL *iconURL = [url URLByAppendingPathComponent:@"icon.png"];
    BOOL iconExists = [[NSFileManager defaultManager] fileExistsAtPath:[iconURL path]];
    NSURL *iconRetinaURL = [url URLByAppendingPathComponent:@"icon@2x.png"];
    BOOL retinaIconExists = [[NSFileManager defaultManager] fileExistsAtPath:[iconRetinaURL path]];
    if ([UIScreen mainScreen].scale == 1.0) {
        if (iconExists) {
            self.iconImage = [UIImage imageWithContentsOfFile:[iconURL path]];
        }
        else if (retinaIconExists) {
            self.iconImage = [UIImage imageWithContentsOfFile:[iconRetinaURL path]];
        }
    }
    else {
        if (retinaIconExists) {
            self.iconImage = [UIImage imageWithContentsOfFile:[iconRetinaURL path]];
        }
        else if (iconExists) {
            self.iconImage = [UIImage imageWithContentsOfFile:[iconURL path]];
        }
    }

    NSURL *splashURL = [url URLByAppendingPathComponent:@"splash.png"];
    BOOL splashExists = [[NSFileManager defaultManager] fileExistsAtPath:[splashURL path]];
    NSURL *splashRetinaURL = [url URLByAppendingPathComponent:@"splash@2x.png"];
    BOOL retinaSplashExists = [[NSFileManager defaultManager] fileExistsAtPath:[splashRetinaURL path]];
    if ([UIScreen mainScreen].scale == 1.0) {
        if (splashExists) {
            self.splashScreenImage = [UIImage imageWithContentsOfFile:[splashURL path]];
        }
        else if (retinaSplashExists) {
            self.splashScreenImage = [UIImage imageWithContentsOfFile:[splashRetinaURL path]];
        }
    }
    else {
        if (retinaSplashExists) {
            self.splashScreenImage = [UIImage imageWithContentsOfFile:[splashRetinaURL path]];
        }
        else if (splashExists) {
            self.splashScreenImage = [UIImage imageWithContentsOfFile:[splashURL path]];
        }
    }
}

- (BOOL)resourcesSameAsApp:(PCApp *)app {
    return [self.resourcesChecksum isEqualToString:app.resourcesChecksum];
}

- (NSURL *)resourcesURL {
    return [self.url URLByAppendingPathComponent:@"resources"];
}

- (NSDictionary *)templateDictionaryWithName:(NSString *)name forClassName:(NSString *)className {
    NSArray *templates = self.templates[className];
    if (!templates) {
        NSLog(@"No templates for class: %@", className);
        return nil;
    }

    NSDictionary *template = [templates rx_detectWithBlock:^BOOL(NSDictionary *each) {
        return [each[@"name"] isEqualToString:name];
    }];
    if (!template) {
        NSLog(@"Unable to find template with name: %@", name);
    }

    return template;
}

- (NSArray *)fontFileURLs {
    NSString *fontPath = [[self.url path] stringByAppendingPathComponent:@"Fonts"];
    if (PCIsEmpty(fontPath) || ![[NSFileManager defaultManager] fileExistsAtPath:fontPath]) {
        PCLog(@"App fonts directory is missing for app: %@", self);
        return nil;
    }

    NSError *directoryContentsError;
    NSArray *fontFileURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:fontPath]
                                                         includingPropertiesForKeys:@[ ]
                                                                            options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                              error:&directoryContentsError];
    if (!fontFileURLs) {
        PCLog(@"Error getting contents of app font directory: %@", directoryContentsError);
    }

    return fontFileURLs;
}


- (NSDictionary *)fontNamesDictionary {
    if (_fontNamesDictionary == nil) {
        NSString *fontNamesPath = [[self.url path] stringByAppendingPathComponent:@"Fonts"];
        fontNamesPath = [fontNamesPath stringByAppendingPathComponent:@"fontNames.plist"];

        if ([[NSFileManager defaultManager] fileExistsAtPath:fontNamesPath]) {
            _fontNamesDictionary = [[NSDictionary alloc] initWithContentsOfFile:fontNamesPath];
        }
        else {
            _fontNamesDictionary = @{};
        }
    }

    return _fontNamesDictionary;
}

- (NSInteger)cardIndexForUUID:(NSUUID *)uuid {
    __block NSInteger index = NSNotFound;

    [self.cards enumerateObjectsUsingBlock:^(PCCard *card, NSUInteger cardIndex, BOOL *stop) {
        if ([card.uuid isEqual:uuid]) {
            index = cardIndex;
            *stop = YES;
        }
    }];

    return index;
}

@end
