//
//  PCREPLViewController.h
//  PCPlayer
//
//  Created by Brandon on 2014-03-24.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;


@protocol PCREPLDelegate <NSObject>

- (void)replDidResignFirstResponder;
- (void)replShouldDismiss;

@end


@interface PCREPLViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField *textField;

@property (nonatomic, weak) id<PCREPLDelegate> delegate;
@property (nonatomic, copy) JSValue *(^textInputHandler)(NSString *);

- (void)printLine:(NSString *)text;

@end
