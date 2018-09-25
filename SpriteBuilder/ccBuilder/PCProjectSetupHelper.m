//
//  CCBProjCreator.m
//  SpriteBuilder
//
//  Created by Viktor on 10/11/13.
//
//

#import "PCProjectSetupHelper.h"
#import "AppDelegate.h"

@implementation PCProjectSetupHelper

+ (BOOL)createDefaultProjectAtPath:(NSString *)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *zipFile = [[NSBundle mainBundle] pathForResource:@"RBKPROJECTNAME" ofType:@"zip" inDirectory:@"Generated"];
    
    // Check that zip file exists
    if (![fileManager fileExistsAtPath:zipFile]) {
        [[AppDelegate appDelegate] modalDialogTitle:@"Failed to Create Project" message:@"The default PencilCase project is missing from this build. Make sure that you build PencilCase using 'Scripts/RBKBuildDistribution.sh <versionstr>' the first time you build the program."];
        return NO;
    }

    // Unzip resources
    NSTask *zipTask = [[NSTask alloc] init];
    [zipTask setCurrentDirectoryPath:[fileName stringByDeletingLastPathComponent]];
    [zipTask setLaunchPath:@"/usr/bin/unzip"];
    NSArray *args = [NSArray arrayWithObjects:@"-o", zipFile, nil];
    [zipTask setArguments:args];
    [zipTask launch];
    [zipTask waitUntilExit];
    
    // Rename ccbproj
    [fileManager moveItemAtPath:[[fileName stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"PROJECTNAME.ccbproj"] toPath:fileName error:NULL];
    
    return [fileManager fileExistsAtPath:fileName];
}

@end
