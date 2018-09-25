//
//  PCBSKFingerPaintView.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-07-18.
//
//

#import <SpriteKit/SpriteKit.h>

@interface PCBSKFingerPaintView : SKSpriteNode

@property (assign, nonatomic) BOOL pressToShowColorPalette;
@property (assign, nonatomic) CGFloat lineWidth;
@property (strong, nonatomic) NSColor *lineColor;

@end
