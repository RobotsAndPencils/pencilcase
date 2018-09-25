//
//  NSAttributedString+TextAttachments.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 15-01-19.
//
//

#import "NSAttributedString+TextAttachments.h"

@implementation NSAttributedString (TextAttachments)

- (NSArray *)textAttachments {
    NSMutableArray *attachments = [NSMutableArray array];
    NSRange totalRange = NSMakeRange(0, self.length);
    if (totalRange.length > 0) {
        NSUInteger marker = 0;
        do {
            NSRange effectiveRange;
            NSDictionary *attributes = [self attributesAtIndex:marker longestEffectiveRange:&effectiveRange inRange:totalRange];
            NSTextAttachment *attachment = attributes[NSAttachmentAttributeName];
            if (attachment != nil) {
                [attachments addObject:attachment];
            }
            marker = effectiveRange.location + effectiveRange.length;
        }
        while (marker < totalRange.length);
    }
    return attachments;
}

@end
