//
//  InspectorPCShape.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-05-17.
//
//

#import "InspectorPCShape.h"
#import "CCBWriterInternal.h"
#import "PCNodeManager.h"

@interface InspectorPCShape ()

@property (weak, nonatomic) IBOutlet NSPopUpButton *shapeTypePopUpButton;
@property (weak, nonatomic) IBOutlet NSTextField *strokeWidthTextfield;

@end

@implementation InspectorPCShape

- (id)initWithSelection:(PCNodeManager *)s andPropertyName:(NSString *)pn andSetterName:(NSString *)sn andDisplayName:(NSString *)dn andExtra:(NSString *)e placeholderKey:(NSString *)placeholderKey {
    self = [super initWithSelection:s andPropertyName:pn andSetterName:sn andDisplayName:dn andExtra:e placeholderKey:placeholderKey];
    if (self) {
        
    }
    return self;
}

- (NSArray *)setupPropertyArrayForFontUpdating {
    NSString *shapeTypeName = [self.propertyName stringByAppendingString:@"shapeType"];
    NSString *strokeWidthName = [self.propertyName stringByAppendingString:@"strokeWidth"];
    return @[shapeTypeName, strokeWidthName];
}

- (void)updateFonts {
    NSString *shapeTypeName = [self.propertyName stringByAppendingString:@"shapeType"];
    NSString *strokeWidthName = [self.propertyName stringByAppendingString:@"strokeWidth"];
    [self setFontForControl:self.shapeTypePopUpButton property:shapeTypeName];
    [self setFontForControl:self.strokeWidthTextfield property:strokeWidthName];
    [self setFontColorForTextfield:self.strokeWidthTextfield property:strokeWidthName];
}

- (void)setShapeType:(NSInteger)shapeType {
    [self setEventPropertyParameterNamed:@"shapeType" value:@(shapeType)];
}

- (NSInteger)shapeType {
    [self.selection updateNodeManagerInspectorForProperty:@"shapeInfo"];
    NSNumber *shapeType = [self eventPropertyParameterNamed:@"shapeType"];
    return [shapeType integerValue];
}

- (void)setStrokeWidth:(float)strokeWidth {
    [self setEventPropertyParameterNamed:@"strokeWidth" value:@(strokeWidth)];
}

- (float)strokeWidth {
    return [[self eventPropertyParameterNamed:@"strokeWidth"] floatValue];
}

- (void)setStroke:(NSCellStateValue)stroke {
    [self setEventPropertyParameterNamed:@"stroke" value:@(stroke)];
}

- (NSCellStateValue)stroke {
    return [[self eventPropertyParameterNamed:@"stroke"] intValue];
}

- (void)setFill:(NSCellStateValue)fill {
    [self setEventPropertyParameterNamed:@"fill" value:@(fill)];
}

- (NSCellStateValue)fill {
    return [[self eventPropertyParameterNamed:@"fill"] intValue];
}

- (void)setStrokeColor:(NSColor *)strokeColor {
    
    CGFloat r, g, b, a;
    strokeColor = [strokeColor colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    [strokeColor getRed:&r green:&g blue:&b alpha:&a];
    
    [self setEventPropertyParameterNamed:@"strokeColor" value:[CCBWriterInternal serializeNSColor:strokeColor]];
    
    if ([self.selection determineMixedStateForProperty:self.propertyName]) [self.mixedStateImageBorder setHidden:NO];
    else [self.mixedStateImageBorder setHidden:YES];
}

- (NSColor *)strokeColor {
    NSArray* colorValue = [self eventPropertyParameterNamed:@"strokeColor"];
    NSColor *col = [NSColor colorWithDeviceRed:[colorValue[0] floatValue] green:[colorValue[1] floatValue] blue:[colorValue[2] floatValue] alpha:[colorValue[3] floatValue]];
    
    if ([self.selection determineMixedStateForProperty:self.propertyName]) [self.mixedStateImageBorder setHidden:NO];
    else [self.mixedStateImageBorder setHidden:YES];
    
    return  col;
}

- (void)setFillColor:(NSColor *)fillColor {
    CGFloat r, g, b, a;
    fillColor = [fillColor colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    [fillColor getRed:&r green:&g blue:&b alpha:&a];

    [self setEventPropertyParameterNamed:@"fillColor" value:[CCBWriterInternal serializeNSColor:fillColor]];
    
    if ([self.selection determineMixedStateForProperty:self.propertyName]) [self.mixedStateImageFill setHidden:NO];
    else [self.mixedStateImageFill setHidden:YES];
}

- (NSColor *)fillColor {
    NSArray* colorValue = [self eventPropertyParameterNamed:@"fillColor"];
    NSColor *col = [NSColor colorWithDeviceRed:[colorValue[0] floatValue] green:[colorValue[1] floatValue] blue:[colorValue[2] floatValue] alpha:[colorValue[3] floatValue]];
    
    if ([self.selection determineMixedStateForProperty:self.propertyName]) [self.mixedStateImageFill setHidden:NO];
    else [self.mixedStateImageFill setHidden:YES];
    
    return  col;
}

- (void)refresh {
    [self willChangeValueForKey:@"shapeType"];
    [self didChangeValueForKey:@"shapeType"];
    
    [self willChangeValueForKey:@"strokeWidth"];
    [self didChangeValueForKey:@"strokeWidth"];
    
    [self willChangeValueForKey:@"stroke"];
    [self didChangeValueForKey:@"stroke"];

    [self willChangeValueForKey:@"fill"];
    [self didChangeValueForKey:@"fill"];
    
    [self willChangeValueForKey:@"strokeColor"];
    [self didChangeValueForKey:@"strokeColor"];

    
    [self willChangeValueForKey:@"fillColor"];
    [self didChangeValueForKey:@"fillColor"];
}

- (IBAction)selectPopUpButton:(id)sender {
    [self setShapeType:[[sender selectedItem] tag]];
}
@end
