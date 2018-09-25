//
//  PCTextFieldStepperCell.h
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-06-18.
//
//

#import <Cocoa/Cocoa.h>


@protocol PCDisableDragProtocol <NSObject>

- (void)setDragDisabled:(BOOL)disabled;

@end


@interface PCTextFieldStepperCell : NSTextFieldCell <PCDisableDragProtocol>

- (void)setDragDisabled:(BOOL)disabled;

@end
