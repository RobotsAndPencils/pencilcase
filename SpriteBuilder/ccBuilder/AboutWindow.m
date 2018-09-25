/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#define BUNDLE_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
#define VERSION_STRING [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#import <MMMarkdown/MMMarkdown.h>

#import "AboutWindow.h"
#import "NSButton+CosmeticUtilities.h"
#import "NSColor+HexColors.h"

@interface AboutWindow()

@property (assign, nonatomic) BOOL loadedAcknowledgements;

@property (weak) IBOutlet NSView *mainView;
@property (strong) IBOutlet NSView *aboutView;
@property (strong) IBOutlet NSView *acknowledgmentsView;

@property (weak, nonatomic) IBOutlet NSTextField *aboutTitle;
@property (weak, nonatomic) IBOutlet NSTextField *versionLabel;
@property (weak, nonatomic) IBOutlet NSButton *websiteButton;

@property (weak, nonatomic) IBOutlet NSTextField *acknowledgmentsTitle;
@property (weak, nonatomic) IBOutlet NSTextField *acknowledgementsContent;
@property (weak, nonatomic) IBOutlet NSScrollView *acknowledgementsContentScrollView;
@property (weak) IBOutlet NSTextField *versionTextLabel;

@end

@implementation AboutWindow

- (void)windowDidLoad {
    [super windowDidLoad];
    [self.mainView addSubview:self.aboutView];
    [self updateUI];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public

- (void)show {
    [self updateUI];
    [self.window makeKeyAndOrderFront:self];
}

#pragma mark - Actions

- (IBAction)backToAboutView:(id)sender {
    [self.acknowledgmentsView removeFromSuperview];
    [self.mainView addSubview:self.aboutView];
}

- (IBAction)showAcknowledgementsView:(id)sender {
    [self.aboutView removeFromSuperview];
    [self.mainView addSubview:self.acknowledgmentsView];

    if (!self.loadedAcknowledgements) {
        [self loadAcknowledgements];
    }
}

- (IBAction)openWebsite:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/robotsandpencils/pencilcase"]];
}

- (IBAction)closeWidow:(id)sender {
    [self.window close];
}

#pragma mark - Private

- (void)updateUI {
    [self setupFonts];

    // Load version file into version text field
    NSString *versionPath = [[NSBundle mainBundle] pathForResource:@"Version" ofType:@"txt" inDirectory:@"Generated"];
    NSString *version = [NSString stringWithContentsOfFile:versionPath encoding:NSUTF8StringEncoding error:NULL];

    if (version) {
        [self.versionLabel setStringValue:version];
    } else {
        version = [NSString stringWithFormat:@"%@ (%@)", VERSION_STRING, BUNDLE_VERSION];
        [self.versionLabel setStringValue:version];
    }
}

- (void)setupFonts {
    self.aboutTitle.font = [NSFont fontWithName:@"Montserrat-Light" size:self.aboutTitle.font.pointSize];
    self.acknowledgmentsTitle.font = [NSFont fontWithName:@"Montserrat-Light" size:self.acknowledgmentsTitle.font.pointSize];

    [self.websiteButton pc_setTitleTextColor:[NSColor pc_colorFromHexRGB:@"00AAD9"]];
    NSColor *darkTextColor = [NSColor pc_darkLabelColor];
    self.versionTextLabel.textColor = darkTextColor;
    self.versionLabel.textColor = darkTextColor;
}

- (void)loadAcknowledgements {
    NSString *pathToAcknowledgements = [[NSBundle mainBundle] pathForResource:@"Acknowledgements" ofType:@"plist"];
    NSArray *acknowledgements = [NSArray arrayWithContentsOfFile:pathToAcknowledgements];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    NSDictionary *titleFontAttributes = @{ NSFontAttributeName : [NSFont boldSystemFontOfSize:12] };
    NSDictionary *defaultFontAttributes = @{ NSFontAttributeName : self.acknowledgementsContent.font };
    for (NSDictionary *acknowledgementDictionary in acknowledgements) {
        if (!acknowledgementDictionary[@"name"] && !acknowledgementDictionary[@"license"]) {
            PCLog(@"Invalid acknowledgements dictionary: %@", acknowledgementDictionary);
            continue;
        }

        //If this is not the first acknowledgement, add some space between this and the last one.
        if (attributedString.length) {
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n\n" attributes:defaultFontAttributes]];
        }

        NSAttributedString *titleString = [[NSAttributedString alloc] initWithString:acknowledgementDictionary[@"name"] attributes:titleFontAttributes];
        [attributedString appendAttributedString:titleString];

        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n" attributes:defaultFontAttributes]];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:acknowledgementDictionary[@"license"] attributes:defaultFontAttributes]];
    }

    self.acknowledgementsContent.attributedStringValue = attributedString;
    NSRect boundingRect = [attributedString boundingRectWithSize:NSMakeSize(CGRectGetWidth(self.acknowledgementsContent.frame), CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin];
    [self.acknowledgementsContentScrollView.documentView setFrameSize:NSMakeSize(CGRectGetWidth(self.acknowledgementsContentScrollView.frame), boundingRect.size.height)];

    self.loadedAcknowledgements = YES;
}

@end
