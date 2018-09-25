//
//  CCBPSKLabelTTF.h
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-07-09.
//
//

#import <SpriteKit/SpriteKit.h>
#import "CCBTypes.h"
#import "PCFontConsuming.h"

@interface CCBPSKLabelTTF : SKSpriteNode <PCFontConsuming>

@property (nonatomic, copy) NSString *fontName;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic, retain) SKColor *fontColor;
@property (nonatomic, copy) NSString *string;

//Backwards compatibility
@property (nonatomic, assign) CCTextAlignment horizontalAlignment;
@property (nonatomic, assign) CCVerticalTextAlignment verticalAlignment;

@end
