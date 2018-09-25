//
//  PCNumberExpressionInspector.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-27.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCNumberExpressionInspector.h"

@interface PCNumberExpressionInspector ()

@property (weak, nonatomic) IBOutlet NSStepper *stepper;
@property (strong, nonatomic) IBOutlet NSNumberFormatter *formatter;

@end

@implementation PCNumberExpressionInspector

@synthesize saveHandler = _saveHandler;

- (NSView *)initialFirstResponder {
    return nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.allowFloats = YES;
        self.maxValue = DBL_MAX;
        self.minValue = -1.7E308; // DBL_MIN; breaks :(
        self.increment = 1;
        self.number = [NSNumber numberWithDouble:0];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.formatter.allowsFloats = self.allowFloats;
    self.stepper.increment = self.increment;
}

- (void)setIncrement:(CGFloat)increment {
    _increment = increment;
    self.stepper.increment = increment;
}

@end
