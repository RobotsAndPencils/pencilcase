//
//  PCOpenSaveFilter.m
//  SpriteBuilder
//
//  Created by Michael Beauregard on 2015-01-07.
//
//

#import "PCOpenSaveFilter.h"

@implementation PCOpenSaveFilter

- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url {
    return [self panelShouldEnableURL:url];
}

- (BOOL)panelShouldEnableURL:(NSURL *)url {
    BOOL isDirectory;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:url.path isDirectory:&isDirectory];
    BOOL isPackage = [[NSWorkspace sharedWorkspace] isFilePackageAtPath:url.path];

    if (!exists) {
        return NO;
    }

    if (isPackage) {
        return self.allowFilePackageSelection;
    }

    if (isDirectory) {
        return self.allowDirectorySelection;
    }

    return self.allowFileSelection;
}

@end
