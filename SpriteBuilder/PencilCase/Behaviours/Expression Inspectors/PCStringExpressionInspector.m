//
//  PCStringExpressionInspector.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-24.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCStringExpressionInspector.h"

@interface PCStringExpressionInspector ()

@property (weak, nonatomic) IBOutlet NSTextField *textField;

@end

@implementation PCStringExpressionInspector

@synthesize saveHandler = _saveHandler;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSView *)initialFirstResponder {
    return self.textField;
}

@end
