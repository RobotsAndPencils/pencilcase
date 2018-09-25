//
//  PCTableViewCell.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-05-20.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCTableViewCell.h"
#import "PCTableCellInfo.h"
#import "CCFileUtils.h"
#import <RXCollections/RXCollection.h>

@interface PCTableViewCell ()

@property (strong, nonatomic) id viewLoader;

@end

@implementation PCTableViewCell

- (id)initWithCellInfo:(PCTableCellInfo *)cellInfo {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[cellInfo reuseIdentifier]];
    if (self) {
        self.viewLoader = [cellInfo createViewsForTableCell:self];
    }
    return self;
}

#pragma mark - Public

+ (instancetype)cellForCellInfo:(PCTableCellInfo *)info {
    return [[PCTableViewCell alloc] initWithCellInfo:info];
}

- (void)setupWithCellInfo:(PCTableCellInfo *)cellInfo {
    if (!self.viewLoader) return;
    [cellInfo loadValuesUsingViewMapping:self.viewLoader];
}

#pragma mark - Private

@end
