//
//  PCGuide.h
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-11-24.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PCGuideOrientation) {
    PCGuideOrientationHorizontal = 0,
    PCGuideOrientationVertical
};

@interface PCGuide : NSObject

@property (nonatomic, assign) CGFloat position;
@property (nonatomic, assign) enum PCGuideOrientation orientation;
@property (nonatomic, assign) BOOL hasBeenDraggedOutsideGrabArea; // Used so that the disappearing item cursor doesn't appear until the guide has been dragged outside the ruler first

@end
