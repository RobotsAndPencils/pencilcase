//
//  InspectorRichText.h
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2/22/2014.
//
//

#import "InspectorValue.h"

FOUNDATION_EXPORT NSString * const PCSKTextViewSelectionDidChange;
FOUNDATION_EXPORT NSString * const PCSKTextViewSetEnabled;

@interface InspectorRichText : InspectorValue
@property (assign, nonatomic) BOOL enabled;

@property (weak, nonatomic) IBOutlet NSPopUpButton *fontlistPopupButton;

@property (weak, nonatomic) IBOutlet NSButton *boldButton;
@property (weak, nonatomic) IBOutlet NSButton *underlinedButton;
@property (weak, nonatomic) IBOutlet NSButton *italicsButton;

@property (weak, nonatomic) IBOutlet NSButton *leftAlignedButton;
@property (weak, nonatomic) IBOutlet NSButton *centerAlignedButton;
@property (weak, nonatomic) IBOutlet NSButton *rightAlignedButton;
@property (weak, nonatomic) IBOutlet NSButton *justifiedAlignedButton;

@property (weak, nonatomic) IBOutlet NSTextField *fontSizeField;
@property (weak, nonatomic) IBOutlet NSColorWell *textColorWell;
@end
