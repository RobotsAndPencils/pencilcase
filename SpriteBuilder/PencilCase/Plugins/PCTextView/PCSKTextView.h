//
//  PCSKTextView.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-14.
//
//

#import <SpriteKit/SpriteKit.h>
#import "PCFocusableNode.h"
#import "PCOverlayNode.h"
#import "PCFontConsuming.h"

@interface PCSKTextView : SKSpriteNode <PCFocusableNode, PCOverlayNode, PCFontConsuming>

@property (strong, nonatomic) NSTextView *textView;


/**
 Sets the font of the text view and updates the rich text data accordingly
 @param font the font to use
 */
- (void)setFont:(NSFont *)font;

@end
