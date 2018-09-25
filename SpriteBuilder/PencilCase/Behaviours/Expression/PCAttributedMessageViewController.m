//
//  PCAttributedMessageViewController.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-12-11.
//
//

#import "PCAttributedMessageViewController.h"

@interface PCAttributedMessageViewController ()

@property (strong, nonatomic) IBOutlet NSTextView *messageTextView;

@end

@implementation PCAttributedMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setMessage:(NSAttributedString *)message {
    [self view];
    [self.messageTextView.textStorage setAttributedString:message];
    [self.messageTextView.layoutManager ensureLayoutForTextContainer:self.messageTextView.textContainer];
}

@end
