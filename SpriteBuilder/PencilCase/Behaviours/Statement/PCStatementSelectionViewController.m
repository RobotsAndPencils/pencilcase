//
//  PCWhenSelectionViewController.m
//  MacTestApp
//
//  Created by Cody Rayment on 2014-11-15.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCStatementSelectionViewController.h"
#import "PCStatement.h"
#import "PCStatementCellView.h"

@interface PCStatementSelectionViewController () <NSTableViewDataSource, NSTableViewDelegate>

@property (weak, nonatomic) IBOutlet NSTableView *tableView;
@property (weak, nonatomic) IBOutlet NSSearchField *searchField;
@property (strong, nonatomic) NSArray *filteredStatements;

@end

@implementation PCStatementSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateStyle];
    [self search:nil];
}

#pragma mark - Private

- (void)updateStyle {
    if (self.style == PCStatementSelectStyleThen) {
        self.tableView.backgroundColor = [NSColor whiteColor];
    }
    else {
        self.tableView.backgroundColor = [NSColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:1];
    }
}

- (void)styleCell:(PCStatementCellView *)cellView {
    if (self.style == PCStatementSelectStyleThen) {
        cellView.backgroundView.backgroundColor = [NSColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
    }
    else {
        cellView.backgroundView.backgroundColor = [NSColor whiteColor];
    }
}

- (NSArray *)filterStatements:(NSString *)filter {
    NSArray *filters = [filter componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    filters = [filters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
    if (filters.count == 0) return self.statements;

    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    for (NSString *filter in filters) {
        NSPredicate *filterPredicate = [NSPredicate predicateWithBlock:^BOOL(PCStatement *statement, NSDictionary *bindings) {
            return [statement matchesSearch:filter];
        }];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ predicate, filterPredicate ]];
    }

    return [self.statements filteredArrayUsingPredicate:predicate];
}

#pragma mark - Actions

- (IBAction)search:(NSSearchField *)sender {
    if ([sender.stringValue length] > 0) {
        self.filteredStatements = [self filterStatements:sender.stringValue];
    }
    else {
        self.filteredStatements = self.statements;
    }

    [self.tableView reloadData];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.filteredStatements.count;
}

#pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    PCStatement *statement = self.filteredStatements[row];
    PCStatementCellView *cellView = [tableView makeViewWithIdentifier:@"Cell" owner:self];
    [self styleCell:cellView];
    cellView.textField.attributedStringValue = [statement attributedString];
    return cellView;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    PCStatement *statement = self.filteredStatements[row];
    PCStatementCellView *cellView = [tableView makeViewWithIdentifier:@"Cell" owner:self];
    cellView.translatesAutoresizingMaskIntoConstraints = NO;
    cellView.textField.attributedStringValue = [statement attributedString];
    if (cellView.widthConstraint) {
        [cellView removeConstraint:cellView.widthConstraint];
    }
    cellView.widthConstraint = [NSLayoutConstraint constraintWithItem:cellView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:tableView.bounds.size.width];
    [cellView addConstraint:cellView.widthConstraint];
    [cellView layoutSubtreeIfNeeded];
    return cellView.bounds.size.height;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger row = [self.tableView selectedRow];
    if (row < 0) return;
    PCStatement *statement = self.filteredStatements[row];
    if (self.selectionHandler) self.selectionHandler([[[statement class] alloc] init]);
}

@end
