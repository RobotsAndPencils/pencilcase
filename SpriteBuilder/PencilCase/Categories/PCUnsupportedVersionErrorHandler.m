//
//  PCUnsupportedVersionErrorHandler.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2015-02-17.
//
//

#import "PCUnsupportedVersionErrorHandler.h"
#import <Sparkle/Sparkle.h>

@implementation PCUnsupportedVersionErrorHandler

- (BOOL)attemptRecoveryFromError:(NSError *)error optionIndex:(NSUInteger)recoveryOptionIndex {
    Class updaterClass = NSClassFromString(@"SUUpdater");
    if (!updaterClass) return NO;

    [[updaterClass sharedUpdater] checkForUpdates:self];
    return YES;
}

@end
