//
//  PCTokenAttachmentCell.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-18.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCTokenAttachmentCell.h"
#import "PCToken.h"
#import "BehavioursStyleKit.h"
#import <INPopoverController/INPopoverController.h>
#import "PCTokenSelectViewController.h"

// Note that changing this will require manually changing the height of the cell views in PCTokenSelectViewController.xib
const NSInteger PCTokenPadding = 4;

@interface PCTokenAttachmentCell ()

@property (strong, nonatomic) NSColor *hoverColor;
@property (assign, nonatomic) BOOL highlightSelectSubtoken;
@property (strong, nonatomic) NSArray *tokenStrings;

@end

@implementation PCTokenAttachmentCell

#pragma mark - Super

- (CGRect)cellFrameForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(NSRect)lineFrag glyphPosition:(NSPoint)position characterIndex:(NSUInteger)charIndex {
    CGRect rect = [super cellFrameForTextContainer:textContainer proposedLineFragment:lineFrag glyphPosition:position characterIndex:charIndex];
    rect.origin.y -= 3;
    return rect;
}

- (CGSize)cellSize {
    CGSize size = CGSizeMake(0, 0);
    for (NSAttributedString *string in self.tokenStrings) {
        size.width += PCTokenPadding + string.size.width + PCTokenPadding;
        size.height = fmax(size.height, string.size.height + PCTokenPadding / 2);
    }
    return size;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    __block CGFloat xOffset = cellFrame.origin.x;
    NSInteger count = [self.tokenStrings count];
    [self.tokenStrings enumerateObjectsUsingBlock:^(NSAttributedString *string, NSUInteger idx, BOOL *stop) {
        CGRect frame = cellFrame;
        frame.origin.x = xOffset;
        frame.size.width = [string size].width + PCTokenPadding * 2;

        BOOL sourceHighlight = self.hovered && self.hoverColor;
        BOOL insertMode = idx == count - 1 && self.allowEditing && self.highlightSelectSubtoken;
        BOOL leftConnected = idx > 0;
        BOOL rightConnected = idx < count - 1;

        [BehavioursStyleKit drawTokenBackgroundWithFrame:frame sourceHighlight:sourceHighlight rightConnected:rightConnected leftConnected:leftConnected insertNewMode:insertMode invalidToken:self.token.isInvalidReference];
        xOffset += frame.size.width;

        if (sourceHighlight) {
            NSMutableAttributedString *newString = [string mutableCopy];
            [newString addAttribute:NSForegroundColorAttributeName value:[BehavioursStyleKit darkBlueColor] range:NSMakeRange(0, [newString length])];
            string = newString;
        }

        CGRect textRect = CGRectInset(frame, PCTokenPadding, PCTokenPadding / 4);
        textRect.origin.y -= 1;
        [string drawInRect:textRect];
    }];
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.token forKey:@"PCToken"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.token = [aDecoder decodeObjectForKey:@"PCToken"];
    }
    return self;
}

#pragma mark - Public

+ (PCTokenAttachmentCell *)tokenCellWithToken:(PCToken *)token {
    PCTokenAttachmentCell *cell = [[PCTokenAttachmentCell alloc] init];
    cell.token = token;
    return cell;
}

#pragma mark - Private

- (void)updateFromToken {
    NSMutableArray *strings = [[NSMutableArray alloc] init];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    PCToken *token = self.token;
    while (token) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSCenterTextAlignment;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        NSDictionary *attributes = @{
                                     NSParagraphStyleAttributeName: paragraphStyle,
                                     NSFontAttributeName: [NSFont fontWithName:@"Menlo" size:12],
                                     NSForegroundColorAttributeName: [NSColor whiteColor],
                                     };


        NSAttributedString *tokenString = [[NSAttributedString alloc] initWithString:token.displayName attributes:attributes];
        [strings addObject:tokenString];
        [attributedString appendAttributedString:tokenString];
        token = token.childToken;
        if (token) {
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:attributes]];
        }
    }
    self.attributedStringValue = [attributedString copy];
    self.tokenStrings = strings;
}

#pragma mark Mouse

- (void)mouseMoved:(CGPoint)point {
    if ([[self leafToken].potentialChildTokens count] > 0) {
        CGFloat addSubtokenHoverWidth = 16;
        CGRect addSubtokenRect = CGRectMake([self cellSize].width - addSubtokenHoverWidth, 0, addSubtokenHoverWidth, [self cellSize].height);
        self.highlightSelectSubtoken = CGRectContainsPoint(addSubtokenRect, point);
    }
}

- (void)mouseExited {
    self.highlightSelectSubtoken = NO;
}

- (void)clickedLocation:(CGPoint)point inView:(NSView *)view didUpdateBlock:(dispatch_block_t)block {
    if (!self.allowEditing || !self.highlightSelectSubtoken) return;

    PCTokenSelectViewController *viewController = [[PCTokenSelectViewController alloc] init];
    viewController.tokens = [[self leafToken] potentialChildTokens];
    CGRect rect = CGRectMake(point.x, point.y, 10, 10);
    INPopoverController *popover = [[INPopoverController alloc] initWithContentViewController:viewController];
    popover.animates = NO;
    [popover presentPopoverFromRect:rect inView:view preferredArrowDirection:INPopoverArrowDirectionUp anchorsToPositionView:YES];

    __weak typeof(popover) weakPopover = popover;
    __weak typeof(self) weakSelf = self;
    [viewController setSelectionHandler:^(PCToken *token) {
        [weakPopover closePopover:self];
        if (token) {
            [weakSelf leafToken].childToken = token;
            [weakSelf updateFromToken];
            block();
        }
    }];
}

- (PCToken *)leafToken {
    PCToken *token = self.token;
    while (token.childToken) {
        token = token.childToken;
    }
    return token;
}

#pragma mark - Properties

- (void)setToken:(PCToken *)token {
    _token = token;
    [self updateFromToken];
}

- (void)setHovered:(BOOL)hovered {
    _hovered = hovered;
    if ([self.token wantsHover]) {
        [self.token setHovered:hovered];
        self.hoverColor = hovered ? [self.token hoverColor] : nil;
    }
}

@end
