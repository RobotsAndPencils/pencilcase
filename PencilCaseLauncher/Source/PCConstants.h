//
//  PCConstants.h 
//  PCPlayer
//
//  Created by Brandon Evans on 5/20/2015.
//  Copyright (c) 2015 Robots and Pencils Inc. All rights reserved.
//

#pragma mark - Notifications

// Custom events fired by your creation will use NSNotifications using PCEventNotification as the notification name.
// The name of the custom event fired can be found in the userInfo of the notification, under the key PSEventNotificationCustomEventName
extern NSString * const PCEventNotification;
extern NSString * const PCEventNotificationCustomEventName;

#pragma mark - File Versions

extern const NSUInteger PCLastSupportedFileVersion;
extern const NSUInteger PCFirstSupportedFileVersion;

extern const NSInteger PCLastFileVersionWithoutFileFormatVersionKey;

// Previously nodes were exposed in the global scope of the context using their author name.
// e.g. A node with the name MySoccerBall (as it appeared in the UI in the author) would be exposed with that exact name.
// This also means, though, that a node with the name Color would clobber the global Color object.
// Since the author name was only ever used by user-created JS, an alternative method was created to access them by name
// and they're no longer being exposed in this way.
extern const NSInteger PCFirstFileVersionWithoutExposingNodesByAuthorName;

extern const NSInteger PCFirstFileVersionWithScopedCardLoadEvent;

// Previously running sound actions would not wait for the sound to complete.
// https://github.com/RobotsAndPencils/PencilCase/pull/2127
extern const NSInteger PCFirstFileVersionExpectingCorrectSequentialSoundBehaviour;

extern const CGSize PCMaxTextureSize;
