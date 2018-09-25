//
//  PCTextView.m
//  PCPlayer
//
//  Created by Cody Rayment on 2/3/2014.
//  Copyright (c) 2012 Robots and Pencils Inc. All rights reserved.
//

#import "PCTextView.h"
#import "PCOverlayView.h"
#import "SKNode+LifeCycle.h"

@interface PCTextView ()

@property (strong, nonatomic) UIView *container;

@end

@implementation PCTextView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.textView = [self createTextView];
    }
    return self;
}

- (void)pc_presentationDidStart {
    [super pc_presentationDidStart];
    [[PCOverlayView overlayView] addTrackingNode:self];
}

- (void)pc_dismissTransitionWillStart {
    [super pc_dismissTransitionWillStart];
    [[PCOverlayView overlayView] removeTrackingNode:self];
}

#pragma mark - Private

- (UITextView *)createTextView {
    self.container = [[UIView alloc] init];

    UITextView *textView = [[UITextView alloc] init];
    textView.textContainerInset = UIEdgeInsetsZero;
    textView.editable = NO;
    textView.scrollEnabled = NO;
    textView.backgroundColor = [UIColor clearColor];

    [self.container addSubview:textView];
    return textView;
}

- (void)updateTextViewFromRTF {
    NSData *data = [self.rtfContent dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *documentAttributes = @{
                                         NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType,
                                         };
    NSError *error = nil;
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:data options:documentAttributes documentAttributes:nil error:&error];
    self.textView.attributedText = attributedString;
    self.contentAttributedString = self.textView.attributedText;
}

#pragma mark - Properties

- (void)setRtfContent:(NSString *)rtfContent {
    if (![rtfContent isEqualToString:_rtfContent]) {
        _rtfContent = rtfContent;
        [self updateTextViewFromRTF];
    }
}

- (void)setString:(NSString *)string {
    self.textView.text = string;
    self.contentAttributedString = self.textView.attributedText;
}

- (NSString *)string {
    return self.textView.text;
}

#pragma mark - PCOverlayNode

- (UIView *)trackingView {
    return self.container;
}

- (void)viewUpdated:(BOOL)frameChanged {
    self.textView.frame = self.container.bounds;
}

@end
