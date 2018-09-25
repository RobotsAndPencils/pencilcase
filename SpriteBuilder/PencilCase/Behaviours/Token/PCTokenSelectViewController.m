//
//  PCTokenSelectViewController.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-02.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCTokenSelectViewController.h"
#import "PCToken.h"
#import "NSAttributedString+TextAttachments.h"

@interface PCTokenSelectViewController () <NSTableViewDataSource, NSTableViewDelegate>

@property (weak, nonatomic) IBOutlet NSTableView *tableView;

@end

@implementation PCTokenSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSAttributedString *)attributedStringForToken:(PCToken *)token {
    NSMutableAttributedString *string = [[token attributedString] mutableCopy];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSLeftTextAlignment;
    [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [string length])];
    return [string copy];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.tokens.count;
}

#pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    PCToken *token = self.tokens[row];
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"Cell" owner:self];
    cellView.textField.attributedStringValue = [self attributedStringForToken:token];
    return cellView;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    PCToken *token = self.tokens[row];
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"Cell" owner:self];
    NSAttributedString *attributedString = [self attributedStringForToken:token];
    cellView.textField.attributedStringValue = attributedString;

    NSArray *attachments = [attributedString textAttachments];
    NSTextAttachment *attachment = attachments.firstObject;
    id<NSTextAttachmentCell> attachmentCell = attachment.attachmentCell;

    CGFloat height;
    // There should always be an attachment cell for tokens, but check here just in case
    // If there isn't one, the result will just be a table view cell that clips the token's background a bit
    if (attachmentCell) {
        height = attachmentCell.cellSize.height;
    }
    else {
        height = cellView.bounds.size.height;
    }

    [cellView addConstraint:[NSLayoutConstraint constraintWithItem:cellView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:tableView.bounds.size.width]];
    [cellView layoutSubtreeIfNeeded];

    return height;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger row = [self.tableView selectedRow];
    if (row < 0) return;
    PCToken *token = self.tokens[row];
    if (self.selectionHandler) self.selectionHandler(token);
}

@end
