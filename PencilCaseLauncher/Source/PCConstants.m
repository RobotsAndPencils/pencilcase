//
//  PCConstants.m 
//  PCPlayer
//
//  Created by Brandon Evans on 5/20/2015.
//  Copyright (c) 2015 Robots and Pencils Inc. All rights reserved.
//

#pragma mark - Notifications

NSString * const PCEventNotification = @"PCEventNotification";
NSString * const PCEventNotificationCustomEventName = @"PCEventNotificationCustomEventName";

#pragma mark - File Versions

const NSUInteger PCLastSupportedFileVersion = 16;
const NSUInteger PCFirstSupportedFileVersion = 9;

const NSInteger PCLastFileVersionWithoutFileFormatVersionKey = 8;
const NSInteger PCFirstFileVersionWithoutExposingNodesByAuthorName = 10;
const NSInteger PCFirstFileVersionWithScopedCardLoadEvent = 12;
const NSInteger PCFirstFileVersionExpectingCorrectSequentialSoundBehaviour = 16;

/// Max texture size that we support, @1x
const CGSize PCMaxTextureSize = (CGSize){1024, 1024};
