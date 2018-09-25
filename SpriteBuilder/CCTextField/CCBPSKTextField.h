//
//  CCBPSKTextField.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-22.
//
//

#import "SKControl.h"

@interface CCBPSKTextField : SKControl <NSTextFieldDelegate>

/**
 *  Creates a new text field with the specified sprite frame used as its background.
 *
 *  @param frame Sprite frame to use as the text fields background.
 *
 *  @return Returns a new text field.
 */
+ (id)textFieldWithTexture:(SKTexture *)texture;

/**
 *  Initializes a text field with the specified sprite frame used as its background.
 *
 *  @param frame Sprite frame to use as the text fields background.
 *
 *  @return Returns a new text field.
 */
- (id)initWithTexture:(SKTexture *)texture;

/** The sprite frame used to render the text field's background. */
@property (nonatomic, strong) SKTexture* backgroundSpriteFrame;

/** The font size of the text field, defined in the unit specified by the heightUnit component of the contentSizeType. */
@property (nonatomic,assign) float fontSize;

/* The font size of the text field in points. */
@property (nonatomic,readonly) float fontSizeInPoints;

/** Padding from the edge of the text field's background to the native text field component. */
@property (nonatomic,assign) float padding;

/** The text displayed by the text field. */
@property (nonatomic,strong) NSString* string;

/** Is the textfield a secure textfield. */
@property (assign, nonatomic) BOOL isSecureText;

@end
