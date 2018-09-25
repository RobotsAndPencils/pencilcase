//
//  PCTableNode.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-05-08.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <PencilCaseLauncher/PCJSContext.h>
#import "PCTableNode.h"
#import "PCTableCellInfo.h"
#import "PCTableViewCell.h"
#import "PCOverlayView.h"

#import "SKNode+LifeCycle.h"

@interface PCTableNode () <UITableViewDataSource>

@property (strong, nonatomic) UIView *container;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic, readwrite) NSArray *cells;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation PCTableNode

- (void)pc_presentationDidStart {
    [super pc_presentationDidStart];
    [self setup];
    self.tableView.frame = self.container.bounds;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [[PCOverlayView overlayView] addTrackingNode:self];
}

- (void)pc_dismissTransitionWillStart {
    [super pc_dismissTransitionWillStart];
    [[PCOverlayView overlayView] removeTrackingNode:self];
}

- (void)setup {
    self.container = [[UIView alloc] init];
    self.tableView = [[UITableView alloc] initWithFrame:self.container.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = self.backgroundColor;
    self.tableView.separatorInset = UIEdgeInsetsZero;

    if (self.enableRefreshControl) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:self.refreshControl];
    }

    [self.container addSubview:self.tableView];
    [self updateUIUserInteractionEnabled:self.userInteractionEnabled];
}

- (void)endRefreshing {
    [self.refreshControl endRefreshing];
}

- (void)addCellWithInfo:(PCTableCellInfo *)cellInfo {
    self.cells = [self.cells arrayByAddingObject:cellInfo];
    [self.tableView reloadData];
}

- (void)removeCellAtIndex:(NSUInteger)cellIndex {
    if (cellIndex >= self.cells.count) {
        return;
    }

    NSMutableArray *mutableCells = [self.cells mutableCopy];
    [mutableCells removeObjectAtIndex:cellIndex];
    self.cells = [mutableCells copy];
    [self.tableView reloadData];
}

- (void)removeAllCells {
    self.cells = @[];
    [self.tableView reloadData];
}

- (void)refresh {
    NSDictionary *notificationUserInfo = @{
        PCJSContextEventNotificationEventNameKey : @"tablePulledToRefresh",
        PCJSContextEventNotificationArgumentsKey: @[ self ]
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:self userInfo:notificationUserInfo];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.cells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCTableCellInfo *cellInfo = self.cells[indexPath.row];
    PCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[cellInfo reuseIdentifier]];
    if (!cell) {
        cell = [PCTableViewCell cellForCellInfo:cellInfo];
    }
    [cell setupWithCellInfo:cellInfo];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCTableCellInfo *cellInfo = self.cells[indexPath.row];
    return [cellInfo height];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PCTableCellInfo *cellInfo = self.cells[indexPath.row];
    NSDictionary *notificationUserInfo = @{
            PCJSContextEventNotificationEventNameKey : @"cellSelected",
            PCJSContextEventNotificationArgumentsKey : @[ cellInfo.uuid ?: @"", @(indexPath.row) ]
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:self userInfo:notificationUserInfo];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    PCTableCellInfo *cellInfo = self.cells[indexPath.row];
    NSDictionary *notificationUserInfo = @{
            PCJSContextEventNotificationEventNameKey : @"cellInfoButtonPressed",
            PCJSContextEventNotificationArgumentsKey : @[ cellInfo.uuid ?: @"", @(indexPath.row) ]
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:self userInfo:notificationUserInfo];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - PCOverlayNode

- (UIView *)trackingView {
    return self.container;
}

- (void)viewUpdated:(BOOL)frameChanged {
    self.tableView.frame = self.container.bounds;
}

#pragma mark - Properties

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];
    [self updateUIUserInteractionEnabled:userInteractionEnabled];
}

- (void)updateUIUserInteractionEnabled:(BOOL)userInteractionEnabled {
    self.tableView.userInteractionEnabled = userInteractionEnabled;
}

@end
