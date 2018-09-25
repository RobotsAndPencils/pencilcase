//
//  NSOpenPanel+PCImport.m
//  SpriteBuilder
//
//  Created by Michael Beauregard on 15-03-09.
//
//

#import "NSOpenPanel+PCImport.h"
#import "PCResourceManager.h"
#import "PCResourceDirectory.h"

@implementation NSOpenPanel (PCImport)

+ (void)showImportResourcesDialog:(void (^)(BOOL success))completion toResourceDirectory:(PCResourceDirectory *)resourceDirectory {
    if (!resourceDirectory) {
        resourceDirectory = [PCResourceManager sharedManager].rootResourceDirectory;
    }

    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowsMultipleSelection:YES];
    [openPanel setAllowsOtherFileTypes:NO];
    [openPanel setCanChooseDirectories:YES];

    NSString *extensions = [[PCResourceManager allowedMediaFileExtensions] componentsJoinedByString:@"/"];
    NSArray *types = [extensions pathComponents];
    [openPanel setAllowedFileTypes:types];
    [openPanel setMessage:NSLocalizedString(@"Locate Media:", nil)];
    [openPanel setPrompt:NSLocalizedString(@"Select Media", nil)];

    NSWindow *window = [NSApplication sharedApplication].mainWindow;
    [openPanel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
        BOOL importSuccess = NO;
        NSArray *selectedFiles = [openPanel URLs];

        // only import files if there are files selected in the panel and pressed OK
        if (result == NSFileHandlingPanelOKButton && selectedFiles.count > 0) {
            NSArray *selectedFilesPaths = [selectedFiles valueForKey:@"path"];

            [[NSNotificationCenter defaultCenter] postNotificationName:PCDroppedFileNotification object:nil];
            importSuccess = [[PCResourceManager sharedManager] importResourcesAtAbsolutePaths:selectedFilesPaths intoDirectoryAtAbsolutePath:resourceDirectory.directoryPath appendSuffixIfFileExists:NO];
        }

        if (completion) {
            completion(importSuccess);
        }
    }];
}

@end
