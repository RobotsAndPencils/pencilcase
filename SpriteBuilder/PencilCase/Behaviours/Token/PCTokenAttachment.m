//
//  PCTokenAttachment.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-19.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCTokenAttachment.h"
#import "PCTokenAttachmentCell.h"

@implementation PCTokenAttachment

+ (NSAttributedString *)attachmentForToken:(PCToken *)token {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:token.displayName];
    NSFileWrapper *fileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:data];
    [fileWrapper setFilename:@"token.pctoken"];
    [fileWrapper setPreferredFilename:@"token.pctoken"];

    PCTokenAttachmentCell *cell = [PCTokenAttachmentCell tokenCellWithToken:token];

    PCTokenAttachment *textAttachment = [[PCTokenAttachment alloc] initWithFileWrapper:fileWrapper];
    [textAttachment setAttachmentCell:cell];

    NSMutableAttributedString *attachment = [[NSAttributedString attributedStringWithAttachment:textAttachment] mutableCopy];
    [attachment addAttribute:NSCursorAttributeName value:[NSCursor pointingHandCursor] range:NSMakeRange(0, [attachment length])];
    return attachment;
}

@end
