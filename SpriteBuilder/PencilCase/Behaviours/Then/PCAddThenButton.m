//
//  PCAddThenButton.m
//  MacTestApp
//
//  Created by Cody Rayment on 2014-11-13.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCAddThenButton.h"
#import "BehavioursStyleKit.h"

@implementation PCAddThenButton

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [BehavioursStyleKit drawAddThenWithFrame:self.bounds];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(10, 10);
}

#pragma mark - Private

- (void)setup {
    [self addGestureRecognizer:[[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(clicked)]];
}

- (void)clicked {
    if (self.clickHandler) self.clickHandler();
}

@end
