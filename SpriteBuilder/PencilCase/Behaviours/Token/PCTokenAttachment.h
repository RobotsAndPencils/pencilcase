//
//  PCTokenAttachment.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-19.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PCToken.h"

/**
 * By using a subclass here we can use NSKeyedArchiving and get back attachments we can detect
 */
@interface PCTokenAttachment : NSTextAttachment

+ (NSAttributedString *)attachmentForToken:(PCToken *)token;

@end
