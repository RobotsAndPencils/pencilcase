//
//  PCPointExpressionInspector.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-27.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCPointExpressionInspector.h"

@interface PCPointExpressionInspector ()

@property (weak, nonatomic) IBOutlet NSStepper *firstValueStepper;
@property (weak, nonatomic) IBOutlet NSStepper *secondValueStepper;

@end

@implementation PCPointExpressionInspector

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
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.firstValueStepper.increment = self.increment;
    self.secondValueStepper.increment = self.increment;
}

- (BOOL)validateValue:(inout __autoreleasing id *)ioValue forKeyPath:(NSString *)inKeyPath error:(out NSError *__autoreleasing *)outError {
    if ([inKeyPath isEqualToString:@"self.firstValue"]
        || [inKeyPath isEqualToString:@"self.secondValue"]) {
        *ioValue = [@([(NSString *)(*ioValue) doubleValue]) stringValue];
    }
    return YES;
}

- (void)setIncrement:(double)increment {
    _increment = increment;
    self.firstValueStepper.increment = increment;
    self.secondValueStepper.increment = increment;
}

@end
