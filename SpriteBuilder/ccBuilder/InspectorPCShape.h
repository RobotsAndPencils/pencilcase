//
//  InspectorPCShape.h
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-05-17.
//
//

#import <Foundation/Foundation.h>
#import "InspectorValue.h"

@interface InspectorPCShape : InspectorValue

@property (assign, nonatomic) NSInteger shapeType;
@property (assign, nonatomic) NSCellStateValue fill;
@property (assign, nonatomic) NSCellStateValue stroke;
@property (assign, nonatomic) NSColor *fillColor;
@property (assign, nonatomic) NSColor *strokeColor;
@property (assign, nonatomic) float strokeWidth;
@property (strong, nonatomic) IBOutlet NSImageView *mixedStateImageFill;
@property (strong, nonatomic) IBOutlet NSImageView *mixedStateImageBorder;

- (IBAction)selectPopUpButton:(id)sender;

@end
