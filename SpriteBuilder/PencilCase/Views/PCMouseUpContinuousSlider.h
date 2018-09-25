//
//  PCMouseUpContinuousSlider.h
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-05-30.
//
//

/**
 *  This subclass calls mouseUpHandler when the user releases the mouse, even in continuous mode
 */
@interface PCMouseUpContinuousSlider : NSSlider

@property (nonatomic, copy) void(^mouseUpHandler)(NSEvent *);

@end
