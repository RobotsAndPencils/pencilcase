//
//  PCTokenAttachmentCell.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-18.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PCToken.h"

/**
 * Represents a token and draws it along with all of it's recursive list of child tokens.
 */
@interface PCTokenAttachmentCell : NSTextAttachmentCell

@property (copy, nonatomic) PCToken *token;
@property (assign, nonatomic) BOOL hovered;
@property (assign, nonatomic) BOOL allowEditing;

+ (PCTokenAttachmentCell *)tokenCellWithToken:(PCToken *)token;

- (void)mouseMoved:(CGPoint)point;
- (void)mouseExited;
- (void)clickedLocation:(CGPoint)point inView:(NSView *)view didUpdateBlock:(dispatch_block_t)block;

@end
