//
//  UIAlertView+JSExport.m
//  PCPlayer
//
//  Created by Brandon on 2014-03-18.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "UIAlertView+JSExport.h"
#import <objc/runtime.h>

static void *UIAlertViewManagedObjectCallbackKey = &UIAlertViewManagedObjectCallbackKey;

@interface UIAlertView (JSExportPrivate) <UIAlertViewDelegate>

@property (strong, nonatomic) JSManagedValue *managedCallbackValue;

@end

@implementation UIAlertView (JSExport)

+ (UIAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message completion:(JSValue *)completionFunction {
    if (!title) title = @"";
    if (!message) message = @"";

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    alertView.delegate = alertView;

    if (completionFunction) {
        JSManagedValue *callback = [JSManagedValue managedValueWithValue:completionFunction andOwner:self];
        alertView.managedCallbackValue = callback;
    }

    [alertView show];
    return alertView;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.managedCallbackValue) [self.managedCallbackValue.value callWithArguments:@[]];
}

- (JSManagedValue *)managedCallbackValue {
    return objc_getAssociatedObject(self, UIAlertViewManagedObjectCallbackKey);
}

- (void)setManagedCallbackValue:(JSManagedValue *)managedCallbackValue {
    objc_setAssociatedObject(self, UIAlertViewManagedObjectCallbackKey, managedCallbackValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
