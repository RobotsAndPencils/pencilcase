//
//  PCSKTextView.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-14.
//
//

#import "PCSKTextView.h"
#import "PCView.h"
#import "PCOverlayView.h"
#import "PCFocusRingView.h"
#import "InspectorRichText.h"

// Categories
#import "SKNode+LifeCycle.h"
#import "SKNode+NodeInfo.h"

@interface PCSKTextView () <NSTextViewDelegate>

@property (strong, nonatomic) PCView *container;
@property (strong, nonatomic) NSClipView *clipView;
@property (copy, nonatomic) NSString *rtfContent;
@property (strong, nonatomic) PCFocusRingView *focusRingView;
@property (assign, nonatomic, getter=isFocused) BOOL focused;

@end

@implementation PCSKTextView

@synthesize endFocusHandler = _endFocusHandler;

#pragma mark - SKSpriteNode

- (id)init {
    self = [super init];
    if (self) {
        NSRect startFrame = NSMakeRect(0, 0, 100, 100);
        _container = [[PCView alloc] initWithFrame:startFrame];
        _container.wantsLayer = YES;
        
        _clipView = [[NSClipView alloc] initWithFrame:_container.bounds];
        _clipView.drawsBackground = NO;
        _clipView.translatesAutoresizingMaskIntoConstraints = NO;
        _clipView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
        
        _textView = [[NSTextView alloc] initWithFrame:_clipView.bounds];
        _textView.wantsLayer = YES;
        _textView.translatesAutoresizingMaskIntoConstraints = NO;
        [_textView setFont:[NSFont fontWithName:@"Helvetica" size:17]];
        [_textView setDrawsBackground:NO];
        
        _clipView.documentView = _textView;
        [_container addSubview:_clipView];
        
        [self setEditable:NO];
    }
    return self;
}

- (PCEditorResizeBehaviour)editorResizeBehaviour {
    return PCEditorResizeBehaviourContentSize;
}

#pragma mark Life Cycle

- (void)pc_didEnterScene {
    [super pc_didEnterScene];
    [[PCOverlayView overlayView] addTrackingNode:self];
}

- (void)pc_willExitScene {
    [super pc_willExitScene];
    [self endFocus];
    [[PCOverlayView overlayView] removeTrackingNode:self];
}

#pragma mark - Private

- (void)setAlpha:(CGFloat)alpha {
    [super setAlpha:alpha];
    [self.container.layer setOpacity:alpha];
}

- (void)setEditable:(BOOL)editable {
    if (editable) {
        [[PCOverlayView overlayView] enableInteractionInUIKitWindow];
        [self.textView setDelegate:self];
    }
    else {
        [[PCOverlayView overlayView] disableInteractionInUIKitWindow];
        [self updateRTFContentFromTextView];
        [self.textView setDelegate:nil];
    }
    NSMutableDictionary *enabled = [NSMutableDictionary dictionary];
    [enabled setObject:@(editable) forKey:@"enabled"];
    [[NSNotificationCenter defaultCenter] postNotificationName:PCSKTextViewSetEnabled object:nil userInfo:enabled];
    
    [self.textView setEditable:editable];
    [self.textView setSelectable:editable];
    [self.textView setSelectedRange:NSMakeRange(0, 0)];
    self.textView.acceptsTouchEvents = editable;
    if (self.textView.isEditable) {
        [self.textView setSelectedRange:NSMakeRange(0, [[self.textView string] length])];
        [self.textView.window makeFirstResponder:self.textView];
    }
}

- (void)updateTextViewFromRTF {
    NSData *data = [self.rtfContent dataUsingEncoding:NSUTF8StringEncoding];
    NSRange fullRange = NSMakeRange(0, [[self.textView string] length]);
    [self.textView replaceCharactersInRange:fullRange withRTF:data];
}

- (void)updateRTFContentFromTextView {
    NSRange fullRange = NSMakeRange(0, [[self.textView string] length]);
    NSData *data = [self.textView RTFFromRange:fullRange];
    NSString *rtf = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self setRtfContent:rtf];
    
}

- (void)setFont:(NSFont *)font {
    self.textView.font = font;
    [self updateRTFContentFromTextView];
}

#pragma mark - Public 

- (NSDictionary *)fontNamesAndSizes {
    NSAttributedString *text = self.textView.attributedString;
    NSMutableDictionary *results = [@{} mutableCopy];
    
    [text enumerateAttributesInRange:NSMakeRange(0, text.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSFont *font = attrs[NSFontAttributeName];
        if (!font) return;
        // Save the font names and sizes into a set
        if (!results[font.fontName]) results[font.fontName] = [[NSMutableSet alloc] init];
        NSMutableSet *fontSizes = results[font.fontName];
        [fontSizes addObject:@(font.pointSize)];
    }];
    
    return results;
}

#pragma mark - Properties

- (void)setRtfContent:(NSString *)rtfContent {
    if (![rtfContent isEqual:_rtfContent]) {
        _rtfContent = rtfContent;
        [self setExtraProp:rtfContent forKey:@"rtfContent"];
        [self updateTextViewFromRTF];
    }
}

#pragma mark - NSTextViewDelegate

- (void)textViewDidChangeSelection:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:PCSKTextViewSelectionDidChange object:nil];
}

- (void)textDidEndEditing:(NSNotification *)notification {
    if (self.endFocusHandler) self.endFocusHandler();
}

#pragma mark - PCFocusableNode

- (void)focus {
    self.focusRingView = [[PCFocusRingView alloc] init];
    [[PCOverlayView overlayView] addContentView:self.focusRingView withUpdateBlock:nil];
    [[PCOverlayView overlayView] disableNestingForTrackingNode:self];
    self.focused = YES;
    [self setEditable:YES];
}

- (void)endFocus {
    [self setEditable:NO];
    [self.focusRingView removeFromSuperview];
    self.focusRingView = nil;
    [[PCOverlayView overlayView] enableNestingForTrackingNode:self];
    self.focused = NO;
}

- (BOOL)selectionOfNodesShouldEndFocus:(NSArray *)nodes {
    return YES;
}

#pragma mark - PCOverlayNode

- (NSView<PCOverlayTrackingView> *)trackingView {
    return self.container;
}

- (void)viewUpdated:(BOOL)frameChanged {
    if (frameChanged) {
        NSRect textRect = (NSRect){{0,0},self.container.frame.size};
        self.textView.frame = textRect;
        self.clipView.frame = textRect;
    }
    if (self.isFocused) {
        [[PCOverlayView overlayView] updateView:self.focusRingView fromNode:self];
    }
}

@end
